param (
    [string] $Category, [string] $Title, [string] $OutputDir = ".\blogs", [string] $DataFile = ".\blogData.csv"   # default to CSV, but can be .json too
)

# Load data depending on file extension
$ext = [System.IO.Path]::GetExtension($DataFile).ToLower()

if ($ext -eq ".json") {
    $data = -Path 
    $row = $data.$Category
    if (-not $row) { Write-Error "No data found for category '$Category' in $DataFile"; exit 1 }
    $tools = $row.tools -join ", "
    $skills = $row.skills -join ", "
    $salary = $row.salary
    $growth = $row.growth
}
elseif ($ext -eq ".csv") {
    $data = Import-Csv $DataFile
    $row = $data | Where-Object { $_.Category -eq $Category }
    if (-not $row) { Write-Error "No data found for category '$Category' in $DataFile"; exit 1 }
    $tools = ($row.Tools -split ";") -join ", "
    $skills = ($row.Skills -split ";") -join ", "
    $salary = $row.Salary
    $growth = $row.Growth
}
else {
    Write-Error "Unsupported data file format: $ext"
    exit 1
}

# Ensure output directory exists
if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir | Out-Null
}

$blogFile = Join-Path $OutputDir "$Category-blogs.md"

# Build blog content
$blogContent = @"
layout  post
title   $Title
categories  $Category
thumbnail   /assets/images/thumbnails/$Category.png

???? $Category Headline
Professionals in $Category play a vital role in shaping remote work opportunities.

Day in the Life
Typical daily tasks include project collaboration, client communication, and problem-solving.

Tools Used
$tools

Skills Required
$skills

Salary Range
$salary

Growth Path
$growth

Want Better Remote $Category Opportunities?
{% include cta-$Category.html %}

Explore Remote $Category Roles Today!

### Disclosure
Disclosure: Some of the links in this post are affiliate links. This means if you click and purchase, we may earn a commission at no extra cost to you. We only recommend products we trust and use ourselves.
"@

Set-Content -Path $blogFile -Value $blogContent -Encoding UTF8
Write-Output "Blog file created: $blogFile"

