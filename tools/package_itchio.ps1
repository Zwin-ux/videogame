param(
    [string]$GodotPath = "C:\Users\mzwin\Downloads\Godot_v4.6.1-stable_win64.exe\Godot_v4.6.1-stable_win64_console.exe",
    [string]$Preset = "Windows Desktop",
    [string]$Version = "0.1.0-alpha"
)

$ErrorActionPreference = "Stop"

$ProjectRoot = Split-Path -Parent $PSScriptRoot
$DistRoot = Join-Path $ProjectRoot "dist\itchio"
$BuildRoot = Join-Path $DistRoot "windows"
$ExportPath = Join-Path $BuildRoot "KillerQueen.exe"
$ZipPath = Join-Path $DistRoot ("KillerQueen-{0}-windows.zip" -f $Version)
$ReadmeSource = Join-Path $ProjectRoot "release\itchio\WINDOWS-README.txt"
$ReadmeTarget = Join-Path $BuildRoot "README.txt"

if (-not (Test-Path $GodotPath)) {
    throw "Godot console binary not found at $GodotPath"
}

if (-not (Test-Path (Join-Path $ProjectRoot "export_presets.cfg"))) {
    throw "export_presets.cfg is missing. Create the export preset before packaging."
}

if (-not (Test-Path $ReadmeSource)) {
    throw "Itch README template missing at $ReadmeSource"
}

if (Test-Path $BuildRoot) {
    Remove-Item $BuildRoot -Recurse -Force
}
New-Item -ItemType Directory -Path $BuildRoot -Force | Out-Null

Write-Host "Exporting $Preset to $ExportPath"
& $GodotPath --headless --path $ProjectRoot --export-release $Preset $ExportPath
if ($LASTEXITCODE -ne 0) {
    throw "Godot export failed with exit code $LASTEXITCODE"
}

Copy-Item $ReadmeSource $ReadmeTarget -Force

if (Test-Path $ZipPath) {
    Remove-Item $ZipPath -Force
}

Compress-Archive -Path (Join-Path $BuildRoot "*") -DestinationPath $ZipPath -Force

Write-Host ""
Write-Host "Itch.io package ready:"
Write-Host "  EXE: $ExportPath"
Write-Host "  ZIP: $ZipPath"
Write-Host ""
Write-Host "Suggested Butler command:"
Write-Host "  butler push `"$ZipPath`" your-itch-name/killer-queen:windows-alpha"
