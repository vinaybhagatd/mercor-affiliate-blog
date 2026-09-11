<#
.SYNOPSIS
  Bulk repair utility for blog posts.
.DESCRIPTION
  - Scans src/posts/*.md files
  - Inserts missing categories from canonical list
  - Inserts missing affiliate links from affiliate-links.md
  - Normalizes front matter delimiters and sanitizes headers
  - Logs all repair actions to BulkFixReport.txt
  - Can be run standalone outside the pipeline
#>

param(
  [string]$PostsDir = "C:\Users\LMTest\promotional\mercor-affiliate-blog\src\posts",
  [string]$AffiliateFile = "C:\Users\LMTest\promotional\mercor-affiliate-blog\affiliate-links.md",
  [string]$ReportFile = "BulkFixReport.txt"
)

$ErrorActionPreference = "Stop"

# --- Logging function ---
function Log {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $Message" | Out-File -FilePath $ReportFile -Append
    Write-Host $Message
}

# Reset report
Clear-Content $ReportFile -ErrorAction SilentlyContinue
Log "=== BulkFix-Posts.ps1 started ==="

# ✅ Canonical categories
$allowedCategories = @(
    "creative","data","engineering","finance","language",
    "law","medicine","misc","operations","sciences","tech"
)

# ✅ Build category→affiliate link map
$affiliateLinks = @{}
if (Test-Path $AffiliateFile) {
    $lines = Get-Content $AffiliateFile
    foreach ($cat in $allowedCategories) {
        $pattern = "Apply for Remote $($cat.Substring(0,1).ToUpper() + $cat.Substring(1)) Roles"
        $match = $lines | Where-Object { $_ -match $pattern }
        if ($match -match '\((https:\/\/t\.mercor\.com\/[A-Za-z0-9]+)\)') {
            $affiliateLinks[$cat] = $matches[1]
        }
    }
}

# Round‑robin category assignment
$categoryIndex = 0
function Get-NextCategory {
    $cat = $allowedCategories[$categoryIndex % $allowedCategories.Count]
    $categoryIndex++
    return $cat
}

# --- Repair posts ---
$files = Get-ChildItem $PostsDir -Filter *.md -ErrorAction SilentlyContinue
foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw
    $modified = $false
    $cat = $null

    # ✅ Ensure front matter delimiters
    if (-not ($content -match "^---")) {
        $content = "---`n" + $content
        Log "[BulkFix] Added missing front matter start delimiter to $($file.Name)"
        $modified = $true
    }
    if (-not ($content -match "(?m)^---$")) {
        $content += "`n---"
        Log "[BulkFix] Added missing front matter end delimiter to $($file.Name)"
        $modified = $true
    }

    # ✅ Insert missing category
    if (-not ($content -match "category:\s*(\w+)")) {
        $newCategory = Get-NextCategory
        Log "[BulkFix] Inserted missing category [$newCategory] into $($file.Name)"
        $content = $content -replace "(?m)^---", "---`ncategory: $newCategory"
        $cat = $newCategory
        $modified = $true
    } else {
        $cat = $matches[1]
    }

    # ✅ Insert missing affiliate link (YAML front matter style)
    if (-not ($content -match "affiliate:\s*(https:\/\/t\.mercor\.com\/[A-Za-z0-9]+)")) {
        if ($cat -and $affiliateLinks.ContainsKey($cat)) {
            $link = $affiliateLinks[$cat]
            Log "[BulkFix] Inserted missing affiliate link [$link] into $($file.Name)"
            $content = $content -replace "(?m)^category:\s*\w+", "category: $cat`naffiliate: $link"
            $modified = $true
        }
    }

    # ✅ Sanitize headers
    $content = $content -replace "\+ =", "+="
    $content = $content -replace "^\|", ""   # remove stray pipes
    $content = $content -replace "using\s+", "# using "

    if ($modified) {
        Set-Content -Path $file.FullName -Value $content -Encoding UTF8
        Log "[BulkFix] Saved repaired file $($file.Name)"
    }
}

Log "=== BulkFix-Posts.ps1 complete. All posts repaired. ==="
Write-Host "=== BulkFix-Posts.ps1 complete. All posts repaired. ===" -ForegroundColor Green
