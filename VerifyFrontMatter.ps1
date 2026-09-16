<#
.SYNOPSIS
  Verifies front matter in blog posts.

.DESCRIPTION
  Scans all Markdown files in the posts directory and reports
  missing or invalid YAML front matter blocks or fields.
  Validates against the stable template enforced by FixFrontMatter.ps1:
    - Title
    - Description
    - Category (must be canonical)
    - Layout
    - Affiliate
    - Keywords
    - Tags (must mirror category)
    - Thumbnail
  No date field required.
#>

param(
  [string]$PostsDir = "C:\Users\LMTest\promotional\mercor-affiliate-blog\src\posts"
)

# ✅ Canonical categories
$allowedCategories = @(
    "creative","data","engineering","finance","language",
    "law","medicine","misc","operations","sciences","tech"
)

Write-Host "=== VerifyFrontMatter.ps1 started ===" -ForegroundColor Cyan

$files = Get-ChildItem $PostsDir -Filter *.md -ErrorAction SilentlyContinue
foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw
    $issues = @()

    # Check delimiters
    if ($content -notmatch "^---") {
        $issues += "❌ Missing opening front matter delimiter"
    }
    if ($content -notmatch "(?m)^---$") {
        $issues += "❌ Missing closing front matter delimiter"
    }

    # Title
    if ($content -notmatch "title:\s*") {
        $issues += "❌ Missing title"
    }

    # Description
    if ($content -notmatch "description:\s*") {
        $issues += "❌ Missing description"
    }

    # Category
    if ($content -notmatch "category:\s*(\w+)") {
        $issues += "❌ Missing category"
    } else {
        $null = $content -match "category:\s*(\w+)"
        $category = $Matches[1]
        if ($allowedCategories -notcontains $category) {
            $issues += "⚠️ Invalid category [$category]"
        }
    }

    # Layout
    if ($content -notmatch "layout:\s*") {
        $issues += "❌ Missing layout"
    }

    # Affiliate
    if ($content -notmatch "affiliate:\s*") {
        $issues += "❌ Missing affiliate link"
    }

    # Keywords
    if ($content -notmatch "keywords:\s*") {
        $issues += "❌ Missing keywords"
    }

    # Tags
    if ($content -notmatch "tags:\s*") {
        $issues += "❌ Missing tags"
    } else {
        if ($content -match "category:\s*(\w+)") {
            $cat = $Matches[1]
            if ($content -notmatch "tags:\s*

\[$cat\]

") {
                $issues += "⚠️ Tags do not match category [$cat]"
            }
        }
    }

    # Thumbnail
    if ($content -notmatch "thumbnail:\s*") {
        $issues += "❌ Missing thumbnail"
    }

    # Date check (must NOT exist)
    if ($content -match "date:\s*") {
        $issues += "⚠️ Date field present (should be removed)"
    }

    # Report results
    if ($issues.Count -gt 0) {
        Write-Host "File: $($file.Name)" -ForegroundColor Yellow
        $issues | ForEach-Object { Write-Host "   $_" -ForegroundColor Red }
    } else {
        Write-Host "✔ $($file.Name) front matter valid" -ForegroundColor Green
    }
}

Write-Host "=== VerifyFrontMatter.ps1 complete. ===" -ForegroundColor Cyan
