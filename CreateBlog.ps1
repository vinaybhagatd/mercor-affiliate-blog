<#
<# <# <# <# <# .SYNOPSIS #> #> #> #> #>
CreateBlog.ps1
Generates a single blog post in HTML format for a given category and title.
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$Category,

    [Parameter(Mandatory = $true)]
    [string]$Title,

    [string]$OutputDirectory = ".\blogs"
)

# Ensure output directory exists
if (-not (Test-Path $OutputDirectory)) {
    New-Item -ItemType Directory -Path $OutputDirectory | Out-Null
}

# Build filename (HTML instead of MD)
$filename = Join-Path $OutputDirectory "$Category-blogs.html"

# Generate HTML content
$htmlContent = @"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>$Title</title>
</head>
<body>
    <h1>$Title</h1>
    <p>Welcome to the $Category category blog. This post explores the future of remote $Category careers.</p>

    <h2>Key Insights</h2>
    <ul>
        <li>Remote work opportunities in $Category are expanding globally.</li>
        <li>AI and automation are reshaping $Category workflows.</li>
        <li>Freelance and contract roles in $Category are becoming mainstream.</li>
    </ul>

    <h2>Conclusion</h2>
    <p>The $Category field is evolving rapidly. Staying adaptable and leveraging remote-first tools will be critical for success.</p>
</body>
</html>
"@

# Write HTML file
Set-Content -Path $filename -Value $htmlContent -Encoding UTF8

Write-Host "Blog created: $filename"






