<#
.SYNOPSIS
BatchCreateBlogs.ps1
Generates blog files for all categories in HTML format, copies them into _site,
creates/updates index.html with links to each blog, and runs QAValidator.ps1.
#>

# Define categories
$categories = @(
    "creative","data","engineering","finance","language",
    "law","medicine","misc","operations","sciences","tech"
)

Write-Host "Starting batch blog generation..."

# Ensure _site directory exists
$siteDir = ".\_site"
if (-not (Test-Path $siteDir)) {
    New-Item -ItemType Directory -Path $siteDir | Out-Null
}

# Ensure index.html scaffold exists
$indexPath = "$siteDir\index.html"
if (-not (Test-Path $indexPath)) {
    $scaffold = @"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Mercor Affiliate Blog</title>
    <link rel="stylesheet" href="styles.css">
</head>
<body>
"@
    foreach ($cat in $categories) {
        $scaffold += "<h2>Latest Remote $($cat.Substring(0,1).ToUpper() + $cat.Substring(1)) Posts</h2>`r`n"
        $scaffold += "<ul class=""category-list""></ul>`r`n`r`n"
    }
    $scaffold += "</body>`r`n</html>"
    Set-Content $indexPath $scaffold -Encoding UTF8
}

foreach ($cat in $categories) {
    $title = "The Future of Remote $($cat.Substring(0,1).ToUpper() + $cat.Substring(1)) Careers"
    Write-Host "Generating blog for category: $cat"

    # Generate blog HTML file directly
    $blogFile = ".\blogs\$cat-blogs.html"
    .\CreateBlog.ps1 -Category $cat -Title $title -OutputDirectory ".\blogs"

    # Copy blog into _site with proper filename
    $siteFile = "$siteDir\$($cat.Substring(0,1).ToUpper() + $cat.Substring(1)).html"
    Copy-Item $blogFile $siteFile -Force

    # Build link line for homepage
    $linkLine = "    <li><a href='$($cat.Substring(0,1).ToUpper() + $cat.Substring(1)).html'>$title</a></li>"

    # Insert into index.html under the correct category list using regex
    $indexContent = Get-Content $indexPath -Raw
    $pattern = "(?<=<h2>Latest Remote $($cat.Substring(0,1).ToUpper() + $cat.Substring(1)) Posts</h2>\s*<ul class=""category-list"">)"
    $updatedContent = [System.Text.RegularExpressions.Regex]::Replace($indexContent, $pattern, "$linkLine`r`n")
    Set-Content $indexPath $updatedContent
}

Write-Host "All blogs generated and copied to _site. Homepage index.html updated."

# Run QA validation
Write-Host "Running QAValidator.ps1..."
.\QAValidator.ps1
Write-Host "QA validation complete."
