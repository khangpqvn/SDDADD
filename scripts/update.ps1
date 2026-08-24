# Script cập nhật SDD + ADD template cho repository đã adopt (Windows PowerShell).
# Cách dùng: .\scripts\update.ps1 <template-path> [-DryRun] [-ForceGovernance]
param (
    [Parameter(Mandatory=$false, Position=0)]
    [string]$TemplatePath,

    [Parameter(Mandatory=$false)]
    [switch]$DryRun,

    [Parameter(Mandatory=$false)]
    [switch]$ForceGovernance,

    [Parameter(Mandatory=$false)]
    [switch]$Help
)

if ($Help -or [string]::IsNullOrWhiteSpace($TemplatePath)) {
    Write-Host ""
    Write-Host "=== SDD + ADD Template Updater (PowerShell) ===" -ForegroundColor Cyan
    Write-Host "Cập nhật skills, docs và shared protocols từ template gốc."
    Write-Host ""
    Write-Host "Cách dùng:" -ForegroundColor White
    Write-Host "  .\scripts\update.ps1 <template-path> [-DryRun] [-ForceGovernance]"
    Write-Host ""
    Write-Host "Flags:" -ForegroundColor White
    Write-Host "  -DryRun           Báo cáo thay đổi, không ghi file."
    Write-Host "  -ForceGovernance  Backup và overwrite AGENTS.md, CLAUDE.md, CONSTITUTION.md."
    Write-Host ""
    Write-Host "Ví dụ:" -ForegroundColor Yellow
    Write-Host "  .\scripts\update.ps1 C:\Projects\sddadd-template"
    Write-Host "  .\scripts\update.ps1 ..\sddadd-template -DryRun"
    Write-Host ""
    exit 0
}

if (-not (Test-Path -Path $TemplatePath)) {
    Write-Host ""
    Write-Host "[ERROR] Không tìm thấy template: $TemplatePath" -ForegroundColor Red
    Write-Host ""
    exit 1
}

$ScriptDir   = Split-Path -Parent $MyInvocation.MyCommand.Definition
$TargetDir   = (Resolve-Path (Join-Path $ScriptDir "..")).Path
$TemplateDir = (Resolve-Path $TemplatePath).Path
$Timestamp   = (Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ")
$StagingDir  = Join-Path $TargetDir ".sdd\updates"

# Đọc template version.
$TemplateVer  = "unknown"
$TemplateVerFile = Join-Path $TemplateDir ".sdd\template-version.md"
if (Test-Path $TemplateVerFile) {
    $line = (Get-Content $TemplateVerFile | Where-Object { $_ -match '^template-version:' } | Select-Object -First 1)
    if ($line) { $TemplateVer = ($line -split ':\s*')[1].Trim() }
}

$InstalledVer = "unknown"
$InstalledVerFile = Join-Path $TargetDir ".sdd\template-version.md"
if (Test-Path $InstalledVerFile) {
    $line = (Get-Content $InstalledVerFile | Where-Object { $_ -match '^template-version:' } | Select-Object -First 1)
    if ($line) { $InstalledVer = ($line -split ':\s*')[1].Trim() }
}

Write-Host ""
Write-Host "=== SDD + ADD Template Update ===" -ForegroundColor Cyan
Write-Host "   Template source : $TemplateDir"
Write-Host "   Repository      : $TargetDir"
Write-Host "   Installed ver.  : $InstalledVer"
Write-Host "   Template ver.   : $TemplateVer"
if ($DryRun)          { Write-Host "   Mode: DRY RUN — không ghi file" -ForegroundColor Yellow }
if ($ForceGovernance) { Write-Host "   Mode: FORCE GOVERNANCE — overwrite với backup" -ForegroundColor Yellow }
Write-Host ""

$script:Updated = 0
$script:Staged  = 0

# ─── Hàm tiện ích ────────────────────────────────────────────────────────────

function Overwrite-File {
    param ([string]$SrcRel, [string]$DestRel = $SrcRel)
    $Src  = Join-Path $TemplateDir $SrcRel
    $Dest = Join-Path $TargetDir   $DestRel

    if (-not (Test-Path $Src)) {
        Write-Host "  [!] Không có file nguồn, bỏ qua: $SrcRel" -ForegroundColor Yellow
        return
    }

    if ($DryRun) {
        if ((Test-Path $Dest) -and ((Get-FileHash $Src).Hash -eq (Get-FileHash $Dest).Hash)) {
            Write-Host "  [=] Không đổi : $DestRel"
        } else {
            Write-Host "  [~] Sẽ update : $DestRel" -ForegroundColor Green
            $script:Updated++
        }
        return
    }

    $DestParent = Split-Path -Parent $Dest
    if (-not (Test-Path $DestParent)) { New-Item -ItemType Directory -Path $DestParent -Force | Out-Null }
    Copy-Item -Path $Src -Destination $Dest -Force
    Write-Host "  [+] Updated   : $DestRel" -ForegroundColor Green
    $script:Updated++
}

function Stage-GovernanceFile {
    param ([string]$SrcRel)
    $Src    = Join-Path $TemplateDir $SrcRel
    $Dest   = Join-Path $TargetDir   $SrcRel
    $Staged = Join-Path $StagingDir  $SrcRel

    if (-not (Test-Path $Src)) { return }

    if ($ForceGovernance) {
        if (Test-Path $Dest) {
            $Backup = "$Dest.bak-$($Timestamp -replace ':', '-')"
            if (-not $DryRun) { Copy-Item -Path $Dest -Destination $Backup -Force }
            Write-Host "  [B] Backup    : $SrcRel -> $(Split-Path -Leaf $Backup)" -ForegroundColor Yellow
        }
        Overwrite-File $SrcRel
        return
    }

    if ($DryRun) {
        Write-Host "  [S] Sẽ stage  : $SrcRel -> .sdd\updates\$SrcRel" -ForegroundColor Cyan
        $script:Staged++
        return
    }

    $StagedParent = Split-Path -Parent $Staged
    if (-not (Test-Path $StagedParent)) { New-Item -ItemType Directory -Path $StagedParent -Force | Out-Null }
    Copy-Item -Path $Src -Destination $Staged -Force
    Write-Host "  [S] Staged    : .sdd\updates\$SrcRel" -ForegroundColor Cyan
    $script:Staged++
}

# ─── 1. Safe-overwrite: skills và shared protocols ───────────────────────────

Write-Host "Bước 1: Cập nhật .claude\skills\ (safe overwrite)..." -ForegroundColor Blue
$SkillsSource = Join-Path $TemplateDir ".claude\skills"
if (Test-Path $SkillsSource) {
    Get-ChildItem -Path $SkillsSource -Recurse -File | ForEach-Object {
        $Rel = $_.FullName.Substring($TemplateDir.Length).TrimStart('\')
        Overwrite-File $Rel
    }
} else {
    Write-Host "  [!] Không có .claude\skills\ trong template." -ForegroundColor Yellow
}

# ─── 2. Safe-overwrite: docs và scripts hạ tầng ──────────────────────────────

Write-Host ""
Write-Host "Bước 2: Cập nhật docs\ và scripts hạ tầng..." -ForegroundColor Blue
@(
    "docs\sdd-add-guide.md",
    "docs\architecture-profile-guide.md",
    "docs\multi-agent-orchestration-guide.md",
    "scripts\self-heal.sh",
    "scripts\update.sh",
    "scripts\update.ps1"
) | ForEach-Object { Overwrite-File $_ }

# ─── 3. Review-required: governance files ────────────────────────────────────

Write-Host ""
Write-Host "Bước 3: Governance files (staged để review)..." -ForegroundColor Blue
@("CONSTITUTION.md", "AGENTS.md", "CLAUDE.md", ".agentignore") | ForEach-Object {
    Stage-GovernanceFile $_
}

# ─── 4. Cập nhật template-version.md ─────────────────────────────────────────

Write-Host ""
Write-Host "Bước 4: Cập nhật .sdd\template-version.md..." -ForegroundColor Blue
if (-not $DryRun) {
    $AdoptedAt = ""
    if (Test-Path $InstalledVerFile) {
        $al = (Get-Content $InstalledVerFile | Where-Object { $_ -match '^adopted-at:' } | Select-Object -First 1)
        if ($al) { $AdoptedAt = ($al -split ':\s*',2)[1].Trim() }
    }
    if ([string]::IsNullOrWhiteSpace($AdoptedAt)) { $AdoptedAt = $Timestamp }

    $TemplateSource = ""
    if (Test-Path $InstalledVerFile) {
        $sl = (Get-Content $InstalledVerFile | Where-Object { $_ -match '^template-source:' } | Select-Object -First 1)
        if ($sl) { $TemplateSource = ($sl -split ':\s*',2)[1].Trim() }
    }
    if ([string]::IsNullOrWhiteSpace($TemplateSource)) { $TemplateSource = $TemplateDir }

    $Content = @"
# SDD + ADD Template Version

template-version: $TemplateVer
adopted-at: $AdoptedAt
last-updated: $Timestamp
template-source: $TemplateSource

---

## Hướng dẫn

File này được ``scripts/adopt.sh`` / ``adopt.ps1`` tạo khi áp dụng template lần đầu và được ``scripts/update.sh`` / ``update.ps1`` cập nhật sau mỗi lần update.

- ``template-version``: version template tại thời điểm adopt / update gần nhất.
- ``adopted-at``: timestamp lần adopt đầu tiên (ISO-8601).
- ``last-updated``: timestamp lần update gần nhất (ISO-8601).
- ``template-source``: URL hoặc path của template gốc (tuỳ chọn, để trace nguồn).

Không sửa file này thủ công. Dùng ``/sdd-template-update`` để kiểm tra và cập nhật template.
"@
    Set-Content -Path $InstalledVerFile -Value $Content -Encoding utf8
    Write-Host "  [+] Updated   : .sdd\template-version.md (v$TemplateVer)" -ForegroundColor Green
} else {
    Write-Host "  [~] Sẽ update : .sdd\template-version.md (v$TemplateVer)" -ForegroundColor Green
}

# ─── Báo cáo ─────────────────────────────────────────────────────────────────

Write-Host ""
Write-Host "=== Update hoàn tất ===" -ForegroundColor Green
Write-Host "  Updated  : $($script:Updated) file(s)"
Write-Host "  Staged   : $($script:Staged) governance file(s) tại .sdd\updates\"

if ($script:Staged -gt 0 -and -not $DryRun) {
    Write-Host ""
    Write-Host "Bước tiếp theo:" -ForegroundColor Cyan
    Write-Host "  1. Dùng '/sdd-template-update --review' để AI so sánh staged files với bản hiện tại."
    Write-Host "  2. Merge thủ công các thay đổi phù hợp."
    Write-Host "  3. Xoá .sdd\updates\ sau khi merge xong."
}
Write-Host ""
