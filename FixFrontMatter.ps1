<#
.SYNOPSIS
  Repairs and normalizes front matter in blog posts.
.DESCRIPTION
  Ensures each Markdown file has valid YAML front matter,
  inserts missing categories from canonical list,
  and sanitizes headers for Eleventy compatibility.
#>

param(
  [string]$PostsDir = "C:\Users\LMTest\promotional\mercor-affiliate-blog\src\posts"
)

# ✅ Canonical categories (from Eleventy collections)
$allowedCategories = @(
    "creative","data","engineering","finance","language",
    "law","medicine","misc","operations","sciences","tech"
)

# Round‑robin assignment index
$categoryIndex = 0

function Get-NextCategory {
    $cat = $allowedCategories[$categoryIndex % $allowedCategories.Count]
    $categoryIndex++
    return $cat
}

Write-Host "=== FixFrontMatter.ps1 started ===" -ForegroundColor Cyan

$files = Get-ChildItem $PostsDir -Filter *.md -ErrorAction SilentlyContinue
foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw

    # ✅ Ensure front matter delimiters
    if (-not ($content -match "^---")) {
        $content = "---`n" + $content
    }
    if (-not ($content -match "(?m)^---$")) {
        $content += "`n---"
    }

    # ✅ Insert missing category
    if (-not ($content -match "category:\s*(\w+)")) {
        $newCategory = Get-NextCategory
        Write-Host "Inserted missing category [$newCategory] into $($file.Name)" -ForegroundColor Yellow
        $content = $content -replace "(?m)^---", "---`ncategory: $newCategory"
    }

    # ✅ Normalize operator spacing and sanitize headers
    $content = $content -replace "\+ =", "+="
    $content = $content -replace "^\|", ""   # remove stray pipes at start
    $content = $content -replace "using\s+", "# using " # invalid 'using' → comment

    # ✅ Save back
    Set-Content -Path $file.FullName -Value $content -Encoding UTF8
}

Write-Host "=== FixFrontMatter.ps1 complete. Categories normalized and missing ones auto‑inserted. ===" -ForegroundColor Green
