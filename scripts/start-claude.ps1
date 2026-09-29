param (
    [switch]$Continue,
    [switch]$DangerouslySkipPermissions,
    [string]$Prompt = ""
)

$argsList = @()

if ($DangerouslySkipPermissions) {
    $argsList += "--dangerously-skip-permissions"
    Write-Warning "Đang khởi động Claude Code với quyền bị bỏ qua theo lựa chọn explicit."
}

if ($Continue) {
    $argsList += "-c"
}

if ($Prompt) {
    $argsList += $Prompt
}

if (-not $DangerouslySkipPermissions) {
    Write-Host "Khởi động Claude Code với permission mode mặc định." -ForegroundColor Green
}
claude @argsList
