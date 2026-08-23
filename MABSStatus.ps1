<# 
.SYNOPSIS
Displays real-time status of the MABS system:
JSON count, blog count, LM Studio status, model status,
Eleventy status, Git remote status, last publish timestamp.
#>

param(
    [string]$JsonFolder = ".\BlogData",
    [string]$BlogsFolder = ".\GeneratedBlogs",
    [string]$SiteFolder = ".\mercor-affiliate-blog\_site"
)

Write-Output "▶ MABS Status Dashboard"
Write-Output "==============================="

# ---------------------------------------------------------
# JSON Count
# ---------------------------------------------------------

if (Test-Path $JsonFolder) {
    $jsonCount = (Get-ChildItem $JsonFolder -Filter *.json).Count
    Write-Output "JSON Files: $jsonCount"
} else {
    Write-Output "JSON Files: Folder missing"
}

# ---------------------------------------------------------
# Blog Count
# ---------------------------------------------------------

if (Test-Path $BlogsFolder) {
    $blogCount = (Get-ChildItem $BlogsFolder -Filter *.md).Count
    Write-Output "Generated Blogs: $blogCount"
} else {
    Write-Output "Generated Blogs: Folder missing"
}

# ---------------------------------------------------------
# Last Publish Timestamp
# ---------------------------------------------------------

$gitLog = git log -1 --pretty=format:"%ad" --date=iso 2>$null

if ($gitLog) {
    Write-Output "Last Publish: $gitLog"
} else {
    Write-Output "Last Publish: No commits found"
}

# ---------------------------------------------------------
# LM Studio Status
# ---------------------------------------------------------

$lmPath = "C:\Users\LMTest\.lmstudio\bin\lms.exe"

if (Test-Path $lmPath) {
    Write-Output "LM Studio CLI: Available"
} else {
    Write-Output "LM Studio CLI: Missing"
}

# ---------------------------------------------------------
# Model Status (using 'ls')
# ---------------------------------------------------------

$model = "qwen2.5-coder-1.5b-instruct"

try {
    $models = & $lmPath ls
    if ($models -match $model) {
        Write-Output "Model Status: $model available"
    } else {
        Write-Output "Model Status: $model missing"
    }
}
catch {
    Write-Output "Model Status: LM Studio not accessible"
}

# ---------------------------------------------------------
# Eleventy Status
# ---------------------------------------------------------

try {
    $eleventy = npx @11ty/eleventy --version
    Write-Output "Eleventy: Installed"
}
catch {
    Write-Output "Eleventy: Not installed"
}

# ---------------------------------------------------------
# Git Remote Status
# ---------------------------------------------------------

try {
    $remote = git remote -v
    if ($remote -match "origin") {
        Write-Output "Git Remote: origin configured"
    } else {
        Write-Output "Git Remote: origin missing"
    }
}
catch {
    Write-Output "Git Remote: Git not accessible"
}

# ---------------------------------------------------------
# Site Folder Status
# ---------------------------------------------------------

if (Test-Path $SiteFolder) {
    $siteCount = (Get-ChildItem $SiteFolder -Recurse).Count
    Write-Output "Site Output Files: $siteCount"
} else {
    Write-Output "Site Output Files: Folder missing"
}

Write-Output "==============================="
Write-Output "MABS Status Check Complete"
