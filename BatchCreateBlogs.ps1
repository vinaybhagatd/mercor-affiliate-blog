<#
.SYNOPSIS
BatchCreateBlogs.ps1
Generates blog files for all categories in HTML format, copies them into _site,
updates index.html with links to each blog, and runs QAValidator.ps1.
#>

# Define categories
$categories = @(
    "creative", "data", "engineering", "finance", "language",
    "law", "medicine", "misc", "operations", "sciences", "tech"
)

Write-Host "Starting batch blog generation..."

foreach ($cat in $categories) {
    $title = "The Future of Remote $($cat.Substring(0,1).ToUpper() + $cat.Substring(1)) Careers"
    Write-Host "Generating blog for category: $cat"

    # Generate blog HTML file directly
    $blogFile = ".\blogs\$cat-blogs.html"
    .\CreateBlog.ps1 -Category $cat -Title $title -OutputDirectory ".\blogs"

    # Copy blog into _site with proper filename
    $siteFile = ".\_site\$($cat.Substring(0,1).ToUpper() + $cat.Substring(1)).html"
    Copy-Item $blogFile $siteFile -Force

    # Build link line for homepage
    $linkLine = "    <li><a href='$($cat.Substring(0,1).ToUpper() + $cat.Substring(1)).html'>$title</a></li>"

    # Insert into index.html under the correct category list
    $indexPath = ".\_site\index.html"
    $indexContent = Get-Content $indexPath

    $pattern = "(?<=<h2>Latest Remote $($cat.Substring(0,1).ToUpper() + $cat.Substring(1)) Posts</h2>\s*<ul class=""category-list"">)"
    $updatedContent = $indexContent -replace $pattern, "$linkLine`r`n"

    $updatedContent | Set-Content $indexPath
}

Write-Host "All blogs generated and copied to _site. Homepage index.html updated."

# Run QA validation
Write-Host "Running QAValidator.ps1..."
.\QAValidator.ps1
Write-Host "QA validation complete."
