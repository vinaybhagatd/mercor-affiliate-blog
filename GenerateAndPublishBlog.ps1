<# 
.SYNOPSIS
Generates, validates, builds, and publishes MABS blogs using JSON-driven templates.
Integrates severity-based QA (errors block, warnings pass).
#>

param(
    [string]$JsonFolder = ".\BlogData",
    [string]$OutputDir = ".\GeneratedBlogs",
    [string]$SiteDir = ".\mercor-affiliate-blog\_site"
)

# Step 1: Generate blogs from all JSON files
Write-Host "▶ Starting JSON-driven blog generation..."

$jsonFiles = Get-ChildItem $JsonFolder -Filter *.json

foreach ($json in $jsonFiles) {

    Write-Host "▶ Generating blog for: $($json.Name)"

    .\ContentFiller.ps1 -JsonFile $json.FullName -OutputDir $OutputDir

    $latestFile = Get-ChildItem $OutputDir | Sort-Object LastWriteTime -Descending | Select-Object -First 1

    Write-Host "▶ Running QA for: $($latestFile.Name)"

    .\QAValidator.ps1 -InputFile $latestFile.FullName
}

# Step 2: Check if any QA errors exist
$qaOutput = Get-Content ".\QAValidator.log" -ErrorAction SilentlyContinue

if ($qaOutput -match "❌ QA Failed") {
    Write-Host "❌ Publishing aborted due to QA errors."
    exit 1
}

Write-Host "✅ All blogs passed QA. Proceeding to Eleventy build."

# Step 3: Eleventy build
Write-Host "▶ Running Eleventy build..."
npx @11ty/eleventy --input $OutputDir --output $SiteDir

Write-Host "✅ Eleventy build completed."

# Step 4: GitHub Pages deployment
Write-Host "▶ Deploying to GitHub Pages..."

git add .
git commit -m "Automated MABS publish $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
git push origin main

Write-Host "✅ MABS blog system published successfully."
