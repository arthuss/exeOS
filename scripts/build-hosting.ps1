param(
    [string]$LandingPageSource = '..\landingpage',
    [switch]$SkipFlutterBuild
)

$ErrorActionPreference = 'Stop'

function Resolve-AbsolutePath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [Parameter(Mandatory = $true)]
        [string]$BasePath
    )

    if ([System.IO.Path]::IsPathRooted($Path)) {
        return [System.IO.Path]::GetFullPath($Path)
    }

    return [System.IO.Path]::GetFullPath((Join-Path $BasePath $Path))
}

function Assert-ChildPath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Parent,
        [Parameter(Mandatory = $true)]
        [string]$Child,
        [Parameter(Mandatory = $true)]
        [string]$Label
    )

    $normalizedParent = $Parent.TrimEnd('\') + '\'
    if (-not $Child.StartsWith($normalizedParent, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "$Label path escapes the expected parent directory: $Child"
    }
}

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$landingSourcePath = Resolve-AbsolutePath -Path $LandingPageSource -BasePath $repoRoot
$buildWebPath = [System.IO.Path]::GetFullPath((Join-Path $repoRoot 'build\web'))
$hostingPath = [System.IO.Path]::GetFullPath((Join-Path $repoRoot 'build\hosting'))
$webFeedsPath = [System.IO.Path]::GetFullPath((Join-Path $repoRoot 'web\feeds'))
$wellKnownSourcePath = [System.IO.Path]::GetFullPath((Join-Path $repoRoot '.well-known\assetlinks.json'))
$appShellPath = [System.IO.Path]::GetFullPath((Join-Path $hostingPath 'app.html'))
$landingIndexPath = [System.IO.Path]::GetFullPath((Join-Path $landingSourcePath 'index.html'))

Assert-ChildPath -Parent $repoRoot -Child $buildWebPath -Label 'Flutter web build'
Assert-ChildPath -Parent $repoRoot -Child $hostingPath -Label 'Hosting output'
Assert-ChildPath -Parent $repoRoot -Child $webFeedsPath -Label 'Web feeds'

if (-not (Test-Path -LiteralPath $landingSourcePath -PathType Container)) {
    throw "Landingpage source folder not found: $landingSourcePath"
}

if (-not (Test-Path -LiteralPath $landingIndexPath -PathType Leaf)) {
    throw "Landingpage index.html not found: $landingIndexPath"
}

if (-not (Test-Path -LiteralPath $wellKnownSourcePath -PathType Leaf)) {
    throw "Missing .well-known/assetlinks.json at $wellKnownSourcePath"
}

Push-Location $repoRoot
try {
    Write-Host 'Syncing hub feeds into exeOS\web\feeds ...'
    & (Join-Path $PSScriptRoot 'sync-hub-feeds.ps1')

    if (-not $SkipFlutterBuild) {
        $flutterArgs = @('build', 'web', '--release')
        if ($env:EXEOS_FIREBASE_API_KEY) {
            $flutterArgs += "--dart-define=EXEOS_FIREBASE_API_KEY=$($env:EXEOS_FIREBASE_API_KEY)"
        }

        $displayArgs = $flutterArgs | ForEach-Object {
            if ($_ -like '--dart-define=EXEOS_FIREBASE_API_KEY=*') {
                '--dart-define=EXEOS_FIREBASE_API_KEY=***'
            } else {
                $_
            }
        }
        Write-Host "Running: flutter $($displayArgs -join ' ')"
        & flutter @flutterArgs
        if ($LASTEXITCODE -ne 0) {
            throw 'flutter build web failed.'
        }
    }

    if (-not (Test-Path -LiteralPath $buildWebPath -PathType Container)) {
        throw "Flutter web build output missing: $buildWebPath"
    }

    if (Test-Path -LiteralPath $hostingPath) {
        Remove-Item -LiteralPath $hostingPath -Recurse -Force
    }
    New-Item -ItemType Directory -Path $hostingPath | Out-Null

    Get-ChildItem -LiteralPath $buildWebPath -Force | Copy-Item -Destination $hostingPath -Recurse -Force

    $flutterIndexPath = Join-Path $hostingPath 'index.html'
    if (-not (Test-Path -LiteralPath $flutterIndexPath -PathType Leaf)) {
        throw "Flutter build did not produce index.html at $flutterIndexPath"
    }

    Move-Item -LiteralPath $flutterIndexPath -Destination $appShellPath -Force

    if (Test-Path -LiteralPath $webFeedsPath -PathType Container) {
        $hostingFeedsPath = Join-Path $hostingPath 'feeds'
        if (Test-Path -LiteralPath $hostingFeedsPath) {
            Remove-Item -LiteralPath $hostingFeedsPath -Recurse -Force
        }
        New-Item -ItemType Directory -Path $hostingFeedsPath -Force | Out-Null
        Get-ChildItem -LiteralPath $webFeedsPath -Force | Copy-Item -Destination $hostingFeedsPath -Recurse -Force
    }

    Get-ChildItem -LiteralPath $landingSourcePath -Force | Copy-Item -Destination $hostingPath -Recurse -Force

    $wellKnownTargetPath = Join-Path $hostingPath '.well-known'
    New-Item -ItemType Directory -Path $wellKnownTargetPath -Force | Out-Null
    Copy-Item -LiteralPath $wellKnownSourcePath -Destination (Join-Path $wellKnownTargetPath 'assetlinks.json') -Force

    Write-Host "Prepared Firebase Hosting output at $hostingPath"
    Write-Host 'Root landing: index.html'
    Write-Host 'Flutter shell: app.html'
}
finally {
    Pop-Location
}
