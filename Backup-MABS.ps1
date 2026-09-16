<#
.SYNOPSIS
  Creates a dated backup archive of critical MABS files.
.DESCRIPTION
  Collects automation scripts, layouts, configs, and guardrails into a ZIP file.
#>

$projectRoot = "C:\Users\LMTest\promotional\mercor-affiliate-blog"
$backupRoot  = Join-Path $projectRoot "backups"

# Ensure backup folder exists
if (-not (Test-Path $backupRoot)) {
    New-Item -ItemType Directory -Path $backupRoot | Out-Null
}

# Timestamped archive name
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$zipName   = "MABS-Backup-$timestamp.zip"
$zipPath   = Join-Path $backupRoot $zipName

# Critical files and folders to back up
$itemsToBackup = @(
    # Automation scripts
    "CreateBlog.ps1",
    "BatchCreateBlogs.ps1",
    "ContentFiller.ps1",
    "Fix-LandingPage.ps1",
    "Verify-LandingPageFix.ps1",
    "Diagnose-LandingPage.ps1",
    "FixFrontMatter.ps1",

    # Layouts and configs
    ".eleventy.js",
    "src\_layouts\base.njk",
    "src\_layouts\post.njk",
    "src\categories\category.njk",
    "src\index.njk",
    "src\categories\index.njk",
    "src\styles.css",

    # Guardrails
    "QAValidator.ps1",
    "PSScriptAnalyzerSettings.psd1",
    "Format-Scripts.ps1",
    "BulkFix-Scripts.ps1"
)

# Resolve full paths
$fullPaths = @()
foreach ($item in $itemsToBackup) {
    $path = Join-Path $projectRoot $item
    if (Test-Path $path) {
        $fullPaths += $path
    } else {
        Write-Host "⚠️ Skipping missing item: $item"
    }
}

# Create ZIP archive
if ($fullPaths.Count -gt 0) {
    Compress-Archive -Path $fullPaths -DestinationPath $zipPath -Force
    Write-Host "✅ Backup created: $zipPath"
} else {
    Write-Host "❌ No files found to back up."
}
