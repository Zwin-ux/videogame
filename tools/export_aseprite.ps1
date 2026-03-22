param(
    [string]$AsepritePath = ""
)

$sourceRoot = Join-Path $PSScriptRoot "..\\art\\source"
$exportRoot = Join-Path $PSScriptRoot "..\\art\\export"

$candidates = @()
if ($AsepritePath) {
    $candidates += $AsepritePath
}

$envPath = [Environment]::GetEnvironmentVariable("ASEPRITE_PATH", "User")
if ($env:ASEPRITE_PATH) {
    $candidates += $env:ASEPRITE_PATH
}
if ($envPath) {
    $candidates += $envPath
}

$command = Get-Command aseprite -ErrorAction SilentlyContinue
if ($command) {
    $candidates += $command.Source
}

$candidates += @(
    "$env:USERPROFILE\\Tools\\Aseprite\\aseprite.exe",
    "$env:USERPROFILE\\Tools\\Aseprite\\build\\bin\\aseprite.exe",
    "$env:ProgramFiles\\Aseprite\\aseprite.exe",
    "${env:ProgramFiles(x86)}\\Aseprite\\aseprite.exe"
)

$aseprite = $candidates | Where-Object { $_ -and (Test-Path $_) } | Select-Object -First 1
if (-not $aseprite) {
    Write-Error "Aseprite executable not found. Install Aseprite or pass -AsepritePath."
    exit 1
}

if (-not (Test-Path $sourceRoot)) {
    Write-Error "Source folder not found: $sourceRoot"
    exit 1
}

New-Item -ItemType Directory -Force -Path $exportRoot | Out-Null

$files = Get-ChildItem -Path $sourceRoot -Filter *.aseprite -File -Recurse
if (-not $files) {
    Write-Host "No .aseprite files found in $sourceRoot"
    exit 0
}

foreach ($file in $files) {
    $name = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)
    $sheet = Join-Path $exportRoot "$name.png"
    $data = Join-Path $exportRoot "$name.json"

    $process = Start-Process -FilePath $aseprite -ArgumentList @(
        "--batch",
        $file.FullName,
        "--sheet",
        $sheet,
        "--data",
        $data,
        "--format",
        "json-array",
        "--list-tags"
    ) -Wait -NoNewWindow -PassThru

    if ($process.ExitCode -ne 0) {
        Write-Error "Failed to export $($file.FullName)"
        exit $process.ExitCode
    }

    Write-Host "Exported $name"
}
