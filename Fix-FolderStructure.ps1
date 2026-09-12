<#
.SYNOPSIS
  Fix-FolderStructure.ps1
.DESCRIPTION
  Reorganizes Mercor Affiliate Blog folders into canonical Eleventy structure.
  Includes guardrails: backups, existence checks, logging, safe moves.
  Reports stray duplicates (non-destructive by default).
.NOTES
  Run from project root: C:\Users\LMTest\promotional\mercor-affiliate-blog
#>

$Root   = "C:\Users\LMTest\promotional\mercor-affiliate-blog"
$Backup = Join-Path $Root "mercor_backups\FolderStructureBackup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
$LogFile = Join-Path $Root "Fix-FolderStructure.log"

New-Item -ItemType Directory -Force -Path $Backup | Out-Null

function Log($msg) {
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $msg" | Tee-Object -FilePath $LogFile -Append
}

Log "=== Starting Fix-FolderStructure.ps1 ==="

# Guardrail: Ensure script runs from correct root
if (-not (Test-Path (Join-Path $Root ".eleventy.js"))) {
    Log "ERROR: .eleventy.js not found in $Root. Aborting."
    exit 1
}

# Create canonical folders if missing
$folders = @(
    "src","src\_layouts","src\_includes","src\posts",
    "src\categories","src\assets\css","src\assets\images\thumbnails","src\assets\js"
)
foreach ($f in $folders) {
    $path = Join-Path $Root $f
    if (-not (Test-Path $path)) {
        New-Item -ItemType Directory -Force -Path $path | Out-Null
        Log "Created folder: $f"
    }
}

# Safe move with backup
function SafeMove($src,$dest) {
    if (Test-Path $src) {
        $backupDest = Join-Path $Backup (Split-Path $src -Leaf)
        Copy-Item $src $backupDest -Recurse -Force
        Move-Item $src $dest -Force
        Log "Moved $src -> $dest (backup at $backupDest)"
    } else {
        Log "Skipped missing: $src"
    }
}

# Move layouts
SafeMove (Join-Path $Root "post.njk") (Join-Path $Root "src\_layouts")
SafeMove (Join-Path $Root "category.njk") (Join-Path $Root "src\_layouts")
SafeMove (Join-Path $Root "base.njk") (Join-Path $Root "src\_layouts")

# Move posts
SafeMove (Join-Path $Root "blogs") (Join-Path $Root "src\posts")

# Move categories
SafeMove (Join-Path $Root "categories") (Join-Path $Root "src\categories")

# Move index
SafeMove (Join-Path $Root "index.md") (Join-Path $Root "src")

# Move assets
SafeMove (Join-Path $Root "assets\style.css") (Join-Path $Root "src\assets\css\styles.css")
SafeMove (Join-Path $Root "assets\images\thumbnails") (Join-Path $Root "src\assets\images\thumbnails")

# Duplicate cleanup (report-only mode)
$canonicalFolders = @(
    "src","src\_layouts","src\_includes","src\posts",
    "src\categories","src\assets","src\assets\css","src\assets\images\thumbnails","src\assets\js"
)
$canonicalFiles = @(
    ".eleventy.js","package.json","package-lock.json",
    "src\index.njk","src\pricing\index.njk","src\contact\index.njk",
    "src\categories\index.njk","src\assets\css\styles.css"
)

$allFolders = Get-ChildItem -Path $Root -Directory
foreach ($folder in $allFolders) {
    $relativePath = $folder.FullName.Substring($Root.Length+1)
    if (-not ($canonicalFolders -contains $relativePath)) {
        Log "Would DELETE Folder: $relativePath"
    }
}

$allFiles = Get-ChildItem -Path $Root -File
foreach ($file in $allFiles) {
    $relativePath = $file.FullName.Substring($Root.Length+1)
    if (-not ($canonicalFiles -contains $relativePath)) {
        Log "Would DELETE File: $relativePath"
    }
}

Log "=== Completed Fix-FolderStructure.ps1 ==="
Write-Output "Folder structure fixed. See $LogFile for details."
