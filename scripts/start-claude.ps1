param (
    [switch]$Continue,
    [string]$Prompt = ""
)

$argsList = @("--dangerously-skip-permissions")

if ($Continue) {
    $argsList += "-c"
}

if ($Prompt) {
    $argsList += $Prompt
}

Write-Host "Khởi động Claude Code ở chế độ bỏ qua quyền..." -ForegroundColor Green
claude @argsList
