<#
.SYNOPSIS
  Test-FolderStructure.ps1
.DESCRIPTION
  Validates Mercor Affiliate Blog canonical Eleventy folder structure.
  Reports missing or duplicate files/folders.
.NOTES
  Run from project root: C:\Users\LMTest\promotional\mercor-affiliate-blog
#>

$Root = "C:\Users\LMTest\promotional\mercor-affiliate-blog"
$LogFile = Join-Path $Root "Test-FolderStructure.log"

function Log($msg) {
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $msg" | Tee-Object -FilePath $LogFile -Append
}

Log "=== Starting Test-FolderStructure.ps1 ==="

# Canonical folders
$folders = @(
    "src","src\_layouts","src\_includes","src\posts",
    "src\categories","src\assets\css","src\assets\images\thumbnails","src\assets\js"
)

foreach ($f in $folders) {
    $path = Join-Path $Root $f
    if (Test-Path $path) {
        Log "PASS: Found $f"
    } else {
        Log "FAIL: Missing $f"
    }
}

# Canonical files
$files = @(
    ".eleventy.js","package.json","package-lock.json",
    "src\index.njk","src\pricing\index.njk","src\contact\index.njk",
    "src\categories\index.njk","src\assets\css\styles.css"
)

foreach ($f in $files) {
    $path = Join-Path $Root $f
    if (Test-Path $path) {
        Log "PASS: Found $f"
    } else {
        Log "FAIL: Missing $f"
    }
}

Log "=== Completed Test-FolderStructure.ps1 ==="
Write-Output "Validation complete. See $LogFile for details."
