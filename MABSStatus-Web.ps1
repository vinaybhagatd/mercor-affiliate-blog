<# 
.SYNOPSIS
Generates a local HTML dashboard showing MABS system status.
#>

param(
    [string]$JsonFolder = ".\BlogData",
    [string]$BlogsFolder = ".\GeneratedBlogs",
    [string]$SiteFolder = ".\mercor-affiliate-blog\_site",
    [string]$OutputFile = ".\MABSStatus.html"
)

# Collect data
if (Test-Path $JsonFolder) {
    $jsonCount = (Get-ChildItem $JsonFolder -Filter *.json).Count
} else {
    $jsonCount = "Folder missing"
}

if (Test-Path $BlogsFolder) {
    $blogCount = (Get-ChildItem $BlogsFolder -Filter *.md).Count
} else {
    $blogCount = "Folder missing"
}

$gitLog = git log -1 --pretty=format:"%ad" --date=iso 2>$null
if (-not $gitLog) { $gitLog = "No commits found" }

$lmPath = "C:\Users\LMTest\.lmstudio\bin\lms.exe"
$lmStatus = if (Test-Path $lmPath) { "Available" } else { "Missing" }

$model = "qwen2.5-coder-1.5b-instruct"
try {
    $models = & $lmPath ls
    $modelStatus = if ($models -match $model) { "$model available" } else { "$model missing" }
} catch {
    $modelStatus = "LM Studio not accessible"
}

try {
    $eleventy = npx @11ty/eleventy --version
    $eleventyStatus = "Installed"
} catch {
    $eleventyStatus = "Not installed"
}

try {
    $remote = git remote -v
    $gitRemoteStatus = if ($remote -match "origin") { "origin configured" } else { "origin missing" }
} catch {
    $gitRemoteStatus = "Git not accessible"
}

if (Test-Path $SiteFolder) {
    $siteCount = (Get-ChildItem $SiteFolder -Recurse).Count
} else {
    $siteCount = "Folder missing"
}

# Build HTML
$html = @"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>MABS Status Dashboard</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; background: #0f172a; color: #e5e7eb; }
        h1 { color: #38bdf8; }
        .card { background: #1e293b; padding: 16px; margin-bottom: 12px; border-radius: 8px; }
        .label { font-weight: bold; color: #a5b4fc; }
        .value { margin-left: 8px; }
    </style>
</head>
<body>
    <h1>MABS Status Dashboard</h1>

    <div class="card">
        <span class="label">JSON Files:</span>
        <span class="value">$jsonCount</span>
    </div>

    <div class="card">
        <span class="label">Generated Blogs:</span>
        <span class="value">$blogCount</span>
    </div>

    <div class="card">
        <span class="label">Site Output Files:</span>
        <span class="value">$siteCount</span>
    </div>

    <div class="card">
        <span class="label">Last Publish:</span>
        <span class="value">$gitLog</span>
    </div>

    <div class="card">
        <span class="label">LM Studio CLI:</span>
        <span class="value">$lmStatus</span>
    </div>

    <div class="card">
        <span class="label">Model Status:</span>
        <span class="value">$modelStatus</span>
    </div>

    <div class="card">
        <span class="label">Eleventy:</span>
        <span class="value">$eleventyStatus</span>
    </div>

    <div class="card">
        <span class="label">Git Remote:</span>
        <span class="value">$gitRemoteStatus</span>
    </div>
</body>
</html>
"@

$html | Out-File $OutputFile -Encoding UTF8

Write-Output "MABS web status dashboard generated at: $OutputFile"
