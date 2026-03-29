param(
    [string]$HubRepo = "G:\workspaces\AndroidStudioProjects\Wallpaper-management-hub",
    [string]$TargetRepo = "G:\workspaces\AndroidStudioProjects\exeOS"
)

$ErrorActionPreference = "Stop"

$source = Join-Path $HubRepo "dist\feeds"
$target = Join-Path $TargetRepo "web\feeds"

if (-not (Test-Path $source)) {
    throw "Feed source not found: $source. Build hub feeds first."
}

if (Test-Path $target) {
    Remove-Item -LiteralPath $target -Recurse -Force
}

New-Item -ItemType Directory -Path $target | Out-Null
Copy-Item -Path (Join-Path $source "*") -Destination $target -Recurse -Force

$fileCount = (Get-ChildItem -Path $target -Recurse -File).Count
Write-Host "Synced $fileCount feed files from $source to $target"
