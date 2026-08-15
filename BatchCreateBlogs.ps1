<#
.SYNOPSIS
BatchCreateBlogs.ps1 - Generates blog posts for all 11 categories using CreateBlog.ps1 with default titles, copies them into _site
with correct filenames, and runs QAValidator.ps1 afterwards.#>

# List of approved categories
$categories = @(
    "creative", "data", "engineering", "finance", "language", "law", "medicine", "misc", "operations", "sciences", "tech"
)

foreach ($cat in $categories) {
    # Build default title
    $title = "The Future of Remote $($cat.Substring(0, 1).ToUpper() + $cat.Substring(1)) Careers"

    Write-Output "Generating blog for category: $cat"

    # Path of blog file created in blogs folder
    $blogFile = ".\blogs\$cat-blogs.md"

    # Run CreateBlog.ps1
    .\CreateBlog.ps1 -Category $cat -Title $title

    # Ensure _site directory exists
    if (-not (Test-Path ".\_site")) {
        New-Item -ItemType Directory -Path ".\_site" | Out-Null
    }

    # Copy into _site with capitalized filename (e.g., Tech.md, Finance.md)
    $siteFile = ".\_site\$($cat.Substring(0, 1).ToUpper() + $cat.Substring(1)).md"
    Copy-Item $blogFile $siteFile -Force

    Write-Output "Copied blog to $siteFile"
}

Write-Output "All blogs generated and copied to _site. Running QAValidator.ps1..."

# Run QAValidator.ps1 automatically
$qaValidatorPath = ".\QAValidator.ps1"
if (Test-Path $qaValidatorPath) {
    & $qaValidatorPath -SiteDir ".\_site" -OutputFile ".\QAReport.txt"
}
else {
    Write-Warning "QAValidator.ps1 not found. Skipping validation."
}
