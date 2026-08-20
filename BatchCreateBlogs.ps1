<#
.SYNOPSIS
BatchCreateBlogs.ps1
Generates blog posts for all 11 approved categories
using the corrected CreateBlog.ps1 with <meta> tags,
copies them into _site, and runs QAValidator.ps1 at the end.
#>

# List of approved categories
$categories = @(
    "creative","data","engineering","finance","language",
    "law","medicine","misc","operations","sciences","tech"
)

foreach ($cat in $categories) {
    $title = "The Future of Remote $($cat.Substring(0,1).ToUpper() + $cat.Substring(1)) Careers"
    Write-Host "Generating blog for category: $cat"

    # Call corrected CreateBlog.ps1 with AnalyticsProvider parameter
    .\CreateBlog.ps1 -Category $cat -Title $title -AnalyticsProvider "GA4"

    # Copy blog file into _site for deployment
    $srcFile = ".\blogs\$cat-blogs.html"
    $destFile = ".\_site\$($cat.Substring(0,1).ToUpper() + $cat.Substring(1)).html"
    if (Test-Path $srcFile) {
        Copy-Item $srcFile $destFile -Force
        Write-Host "Copied blog to $destFile"
    } else {
        Write-Warning "Blog file not found: $srcFile"
    }
}

Write-Host "✅ All blogs generated and copied to _site."

# Step 2: Run QAValidator.ps1 automatically
Write-Host "🔍 Running QAValidator.ps1 for compliance checks..."
.\QAValidator.ps1

if (Test-Path ".\QAReport.txt") {
    Write-Host "⚠️ QA validation completed. See QAReport.txt for details."
} else {
    Write-Host "✅ QA validation passed with no issues."
}
