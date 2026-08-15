param(
    [string]$ManifestPath = ".\BulkFix.psd1"
)

# Read the manifest
$manifest = Import-PowerShellDataFile -Path $ManifestPath

# Parse current version
$currentVersion = [Version]$manifest.ModuleVersion

# Increment patch version (you can change to minor/major if needed)
$newVersion = [Version]::new($currentVersion.Major, $currentVersion.Minor, $currentVersion.Build + 1)

Write-Host "Bumping ModuleVersion from $currentVersion to $newVersion"

# Update the manifest file
(Get-Content $ManifestPath) -replace "ModuleVersion\s*=\s*'[^']+'", "ModuleVersion = '$newVersion'" |
    Set-Content $ManifestPath -Encoding UTF8

