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

$resolvedTargetRepo = (Resolve-Path -LiteralPath $TargetRepo).Path
$resolvedTarget = Join-Path $resolvedTargetRepo "web\feeds"
if (-not $resolvedTarget.StartsWith($resolvedTargetRepo.TrimEnd('\') + '\', [System.StringComparison]::OrdinalIgnoreCase)) {
    throw "Refusing to sync outside target repo: $resolvedTarget"
}

New-Item -ItemType Directory -Path $resolvedTarget -Force | Out-Null

$robocopyArgs = @(
    $source,
    $resolvedTarget,
    '/MIR',
    '/R:2',
    '/W:1',
    '/NFL',
    '/NDL',
    '/NJH',
    '/NJS',
    '/NP'
)

& robocopy @robocopyArgs | Out-Null
$robocopyExit = $LASTEXITCODE
if ($robocopyExit -ge 8) {
    throw "robocopy failed with exit code $robocopyExit while syncing feeds."
}

$fileCount = (Get-ChildItem -Path $resolvedTarget -Recurse -File).Count
Write-Host "Synced $fileCount feed files from $source to $resolvedTarget"
