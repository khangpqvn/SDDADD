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

Write-Host "Starting Claude Code with Skip Permissions mode..." -ForegroundColor Green
claude @argsList
