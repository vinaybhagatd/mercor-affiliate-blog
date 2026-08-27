<#
.SYNOPSIS
Bulk regeneration of Mercor Affiliate Blog posts with correct category distribution.

.DESCRIPTION
This script regenerates BlogData_X.md files across all 11 categories.
It enforces PowerShell best practices: quoted wildcards, proper operator spacing,
sanitized headers, and valid front matter for Eleventy.
#>

# ================================
# Config
# ================================
$OutputDir   = "C:\Users\LMTest\promotional\mercor-affiliate-blog\src\GeneratedBlogs"
$ThumbDir    = "/assets/images/thumbnails"
$Categories  = @(
    "creative","engineering","data","finance","operations",
    "medicine","law","sciences","language","misc","tech"
)

# Ensure output directory exists
if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir | Out-Null
}

# ================================
# Regeneration Loop
# ================================
for ($i = 0; $i -lt $Categories.Count; $i++) {
    $category = $Categories[$i]
    $fileNum  = $i + 1
    $fileName = "BlogData_$fileNum.md"
    $filePath = Join-Path $OutputDir $fileName

    # Generate front matter + content
    $content = @"
---
title: "Sample $category Post"
date: $(Get-Date -Format "yyyy-MM-ddTHH:mm:ss")
category: $category
thumbnail: $ThumbDir/blogdata_$fileNum.png
layout: post
---

This is a sample post for the **$category** category.
Generated automatically by BulkRegenerateBlogs.ps1.
"@

    # Write file
    Set-Content -Path $filePath -Value $content -Encoding UTF8
    Write-Host "Regenerated $fileName with category '$category'"
}

# ================================
# Post-Generation Validation
# ================================
Write-Host "`nRunning QA validation..."
$files = Get-ChildItem -Path $OutputDir -Filter "*.md"

foreach ($file in $files) {
    $lines = Get-Content $file.FullName
    if ($lines[0] -ne "---") {
        Write-Warning "File $($file.Name) missing front matter start delimiter."
    }
    if (-not ($lines -match "category:")) {
        Write-Warning "File $($file.Name) missing category field."
    }
}

Write-Host "`nBulk regeneration complete. All categories populated."
