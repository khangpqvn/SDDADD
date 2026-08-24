# Script tích hợp SDD + ADD bằng Windows PowerShell.
param (
    [Parameter(Mandatory=$false, Position=0)]
    [string]$TargetPath,

    [Parameter(Mandatory=$false)]
    [switch]$Force,

    [Parameter(Mandatory=$false)]
    [switch]$Help
)

function Copy-FileSafely {
    param (
        [string]$SrcRel,
        [string]$DestRel
    )
    $Src = Join-Path $script:TemplateDir $SrcRel
    $Dest = Join-Path $script:TargetDir $DestRel
    $DestParent = Split-Path -Parent $Dest

    if (-not (Test-Path -Path $Src)) {
        Write-Host "  [!] Không tìm thấy tệp nguồn, bỏ qua: $SrcRel" -ForegroundColor Yellow
        return
    }

    if (-not (Test-Path -Path $DestParent)) {
        New-Item -ItemType Directory -Path $DestParent -Force | Out-Null
    }

    if ((Test-Path -Path $Dest) -and (-not $script:Force)) {
        Write-Host "  [=] Tệp đã tồn tại, giữ nguyên: $DestRel" -ForegroundColor Yellow
        return
    }

    Copy-Item -Path $Src -Destination $Dest -Force
    Write-Host "  [+] Đã sao chép: $DestRel" -ForegroundColor Green
}

function Copy-FolderSafely {
    param (
        [string]$SrcFolderRel,
        [string]$DestFolderRel
    )
    $SrcFolder = Join-Path $script:TemplateDir $SrcFolderRel
    $DestFolder = Join-Path $script:TargetDir $DestFolderRel

    if (-not (Test-Path -Path $SrcFolder)) {
        return
    }

    if (-not (Test-Path -Path $DestFolder)) {
        New-Item -ItemType Directory -Path $DestFolder -Force | Out-Null
    }

    Copy-Item -Path "$SrcFolder\*" -Destination $DestFolder -Recurse -Force
    Write-Host "  [+] Đã sao chép nội dung thư mục: $DestFolderRel\" -ForegroundColor Green
}

if ($Help -or [string]::IsNullOrWhiteSpace($TargetPath)) {
    Write-Host ""
    Write-Host "=== Công cụ tích hợp SDD + ADD bằng PowerShell (Windows) ===" -ForegroundColor Cyan
    Write-Host "Tích hợp hạ tầng SDD + ADD vào repository có sẵn mà không cần phụ thuộc ngoài."
    Write-Host ""
    Write-Host "Cách dùng:" -ForegroundColor White
    Write-Host "  .\scripts\adopt.ps1 -TargetPath <duong-dan-repo-dich> [-Force]"
    Write-Host "  .\scripts\adopt.ps1 <duong-dan-repo-dich>"
    Write-Host ""
    Write-Host "Ví dụ:" -ForegroundColor Yellow
    Write-Host "  .\scripts\adopt.ps1 C:\Projects\my-legacy-app"
    Write-Host "  .\scripts\adopt.ps1 ..\my-existing-app"
    Write-Host ""
    exit 0
}

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$script:TemplateDir = (Resolve-Path (Join-Path $ScriptDir "..")).Path
$script:Force = $Force

if (-not (Test-Path -Path $TargetPath)) {
    Write-Host ""
    Write-Host "[ERROR] Không tìm thấy thư mục đích: $TargetPath" -ForegroundColor Red
    Write-Host ""
    exit 1
}

$script:TargetDir = (Resolve-Path -Path $TargetPath).Path

Write-Host ""
Write-Host "=== Khởi tạo tích hợp SDD + ADD ===" -ForegroundColor Cyan
Write-Host "   Nguồn template: $script:TemplateDir"
Write-Host "   Thư mục đích: $script:TargetDir"
Write-Host ""

Write-Host "Bước 1: Sao chép slash commands trong .claude\skills\..." -ForegroundColor Blue
Copy-FolderSafely ".claude\skills" ".claude\skills"
Copy-FileSafely ".claude\skills\_shared\ai-review-protocol.md" ".claude\skills\_shared\ai-review-protocol.md"
Copy-FileSafely ".claude\skills\_shared\architecture-profile-protocol.md" ".claude\skills\_shared\architecture-profile-protocol.md"

Write-Host ""
Write-Host "Bước 2: Sao chép governance và context hygiene..." -ForegroundColor Blue
Copy-FileSafely "CONSTITUTION.md" "CONSTITUTION.md"
Copy-FileSafely "AGENTS.md" "AGENTS.md"
Copy-FileSafely "CLAUDE.md" "CLAUDE.md"
Copy-FileSafely ".agentignore" ".agentignore"

Write-Host ""
Write-Host "Bước 3: Khởi tạo hạ tầng đặc tả .sdd\..." -ForegroundColor Blue
Copy-FileSafely ".sdd\README.md" ".sdd\README.md"
Copy-FileSafely ".sdd\architecture-profile.md" ".sdd\architecture-profile.md"
Copy-FileSafely ".sdd\shared_context.md" ".sdd\shared_context.md"
Copy-FileSafely ".sdd\mcp-config.yaml" ".sdd\mcp-config.yaml"
Copy-FileSafely ".sdd\constraints\global.md" ".sdd\constraints\global.md"
Copy-FileSafely ".sdd\constraints\business.md" ".sdd\constraints\business.md"
Copy-FileSafely ".sdd\constraints\safety.md" ".sdd\constraints\safety.md"

$SddFeatures = Join-Path $script:TargetDir ".sdd\features"
if (-not (Test-Path -Path $SddFeatures)) { New-Item -ItemType Directory -Path $SddFeatures -Force | Out-Null }
Copy-FileSafely ".sdd\features\.gitkeep" ".sdd\features\.gitkeep"

$SddReviews = Join-Path $script:TargetDir ".sdd\reviews"
if (-not (Test-Path -Path $SddReviews)) { New-Item -ItemType Directory -Path $SddReviews -Force | Out-Null }
Copy-FileSafely ".sdd\reviews\.gitkeep" ".sdd\reviews\.gitkeep"

$SddRfcs = Join-Path $script:TargetDir ".sdd\rfcs"
if (-not (Test-Path -Path $SddRfcs)) { New-Item -ItemType Directory -Path $SddRfcs -Force | Out-Null }
Copy-FileSafely ".sdd\rfcs\.gitkeep" ".sdd\rfcs\.gitkeep"

Write-Host ""
Write-Host "Bước 4: Sao chép tài liệu và script hỗ trợ..." -ForegroundColor Blue
Copy-FileSafely "docs\sdd-add-guide.md" "docs\sdd-add-guide.md"
Copy-FileSafely "docs\architecture-profile-guide.md" "docs\architecture-profile-guide.md"
Copy-FileSafely "docs\multi-agent-orchestration-guide.md" "docs\multi-agent-orchestration-guide.md"
Copy-FileSafely "scripts\self-heal.sh" "scripts\self-heal.sh"
Copy-FileSafely "scripts\update.ps1" "scripts\update.ps1"

Write-Host ""
Write-Host "Bước 5: Ghi template version..." -ForegroundColor Blue
$TemplateVer = "unknown"
$TemplateSrcVerFile = Join-Path $script:TemplateDir ".sdd\template-version.md"
if (Test-Path $TemplateSrcVerFile) {
    $line = (Get-Content $TemplateSrcVerFile | Where-Object { $_ -match '^template-version:' } | Select-Object -First 1)
    if ($line) { $TemplateVer = ($line -split ':\s*')[1].Trim() }
}
$AdoptedAt = (Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ")
$VersionFileDest = Join-Path $script:TargetDir ".sdd\template-version.md"
$VersionContent = @"
# SDD + ADD Template Version

template-version: $TemplateVer
adopted-at: $AdoptedAt
last-updated: $AdoptedAt
template-source: $script:TemplateDir

---

## Hướng dẫn

File này được ``scripts/adopt.sh`` / ``adopt.ps1`` tạo khi áp dụng template lần đầu và được ``scripts/update.sh`` / ``update.ps1`` cập nhật sau mỗi lần update.

- ``template-version``: version template tại thời điểm adopt / update gần nhất.
- ``adopted-at``: timestamp lần adopt đầu tiên (ISO-8601).
- ``last-updated``: timestamp lần update gần nhất (ISO-8601).
- ``template-source``: URL hoặc path của template gốc (tuỳ chọn, để trace nguồn).

Không sửa file này thủ công. Dùng ``/sdd-template-update`` để kiểm tra và cập nhật template.
"@
Set-Content -Path $VersionFileDest -Value $VersionContent -Encoding utf8
Write-Host "  [+] Đã ghi: .sdd\template-version.md (v$TemplateVer, adopted $AdoptedAt)" -ForegroundColor Green

Write-Host ""
Write-Host "=== Tích hợp SDD + ADD hoàn tất. ===" -ForegroundColor Green
Write-Host "Repository đích '$script:TargetDir' đã có SDD + ADD."
Write-Host ""
Write-Host "Bước tiếp theo trong repository đích:" -ForegroundColor White
Write-Host "  1. Mở repository đích trong Claude Code hoặc AI IDE."
Write-Host "  2. Chạy '/sdd-adopt' để khảo sát và đề xuất Architecture Profile theo tech stack thực tế."
Write-Host "  3. Human Director review Architecture Profile; chỉ duyệt binding và command có evidence."
Write-Host "  4. Bắt đầu feature bằng '/sdd-context --feature=<slug>'."
Write-Host "  5. Đảo ngược Spec cho module cũ bằng '/sdd-adopt --reverse-feature=<slug> --path=<module-path>'."
Write-Host "  6. Review AI recommendation trước mọi công việc downstream."
Write-Host ""
