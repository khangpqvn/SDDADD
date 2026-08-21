# SDD + ADD Native Adoption Script for Windows PowerShell
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
        Write-Host "  [!] Source file missing, skipped: $SrcRel" -ForegroundColor Yellow
        return
    }

    if (-not (Test-Path -Path $DestParent)) {
        New-Item -ItemType Directory -Path $DestParent -Force | Out-Null
    }

    if ((Test-Path -Path $Dest) -and (-not $script:Force)) {
        Write-Host "  [=] File already exists, preserved: $DestRel" -ForegroundColor Yellow
        return
    }

    Copy-Item -Path $Src -Destination $Dest -Force
    Write-Host "  [+] Copied: $DestRel" -ForegroundColor Green
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
    Write-Host "  [+] Copied folder contents: $DestFolderRel\" -ForegroundColor Green
}

if ($Help -or [string]::IsNullOrWhiteSpace($TargetPath)) {
    Write-Host ""
    Write-Host "=== SDD + ADD Native Migration & Adoption Tool (Windows PowerShell) ===" -ForegroundColor Cyan
    Write-Host "Integrate SDD + ADD framework into an existing repository natively."
    Write-Host ""
    Write-Host "Usage:" -ForegroundColor White
    Write-Host "  .\scripts\adopt.ps1 -TargetPath <target-repo-path> [-Force]"
    Write-Host "  .\scripts\adopt.ps1 <target-repo-path>"
    Write-Host ""
    Write-Host "Examples:" -ForegroundColor Yellow
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
    Write-Host "[ERROR] Target directory does not exist: $TargetPath" -ForegroundColor Red
    Write-Host ""
    exit 1
}

$script:TargetDir = (Resolve-Path -Path $TargetPath).Path

Write-Host ""
Write-Host "=== SDD + ADD Native Adoption Initialized ===" -ForegroundColor Cyan
Write-Host "   Template Source: $script:TemplateDir"
Write-Host "   Target Directory: $script:TargetDir"
Write-Host ""

Write-Host "Step 1: Copying .claude/skills/ slash commands..." -ForegroundColor Blue
Copy-FolderSafely ".claude\skills" ".claude\skills"
Copy-FileSafely ".claude\skills\_shared\ai-review-protocol.md" ".claude\skills\_shared\ai-review-protocol.md"

Write-Host ""
Write-Host "Step 2: Copying Layer 1 Governance Files..." -ForegroundColor Blue
Copy-FileSafely "CONSTITUTION.md" "CONSTITUTION.md"
Copy-FileSafely "AGENTS.md" "AGENTS.md"
Copy-FileSafely "CLAUDE.md" "CLAUDE.md"

Write-Host ""
Write-Host "Step 3: Initializing .sdd/ specification framework..." -ForegroundColor Blue
Copy-FileSafely ".sdd\README.md" ".sdd\README.md"
Copy-FileSafely ".sdd\shared_context.md" ".sdd\shared_context.md"

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
Write-Host "Step 4: Copying Documentation..." -ForegroundColor Blue
Copy-FileSafely "docs\sdd-add-guide.md" "docs\sdd-add-guide.md"

Write-Host ""
Write-Host "=== SDD + ADD Native Migration Successful! ===" -ForegroundColor Green
Write-Host "Target repo at '$script:TargetDir' is now SDD + ADD enabled."
Write-Host ""
Write-Host "Next steps for the target project:" -ForegroundColor White
Write-Host "  1. Open the target repo in Claude Code or your AI IDE."
Write-Host "  2. Run '/sdd-adopt' inside the target project to customize governance for its specific tech stack."
Write-Host "  3. Start a new feature using '/sdd-context --feature=<slug>'."
Write-Host "  4. To reverse-engineer spec for a legacy module: '/sdd-adopt --reverse-feature=<slug> --path=<module-path>'"
Write-Host "  5. Review the generated AI recommendation before starting downstream work."
Write-Host ""
