# Fix-CategoriesConflict.ps1
$generatorPath = "src\categories\index.njk"
$targetPath = "src\categories\_generator.njk"

if (Test-Path $generatorPath) {
    Rename-Item $generatorPath $targetPath -Force
    Write-Host "Renamed index.njk to _generator.njk to avoid permalink conflict."
} else {
    Write-Host "No generator file found at $generatorPath."
}
