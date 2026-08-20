# GenerateAndPublishBlog.ps1
# Full automation: LM Studio → Eleventy → GitHub Pages
# With suffix detection, escape cleanup, and empty-output guard

param(
    [string]$Prompt = "Write a 50-word story about a remote creative professional.",
    [string]$Category = "misc"
)

$lmStudioPath = "C:\Users\LMTest\.lmstudio\bin\lms.exe"
$blogPath     = "C:\Users\LMTest\promotional\mercor-affiliate-blog\content\posts"
$repoPath     = "C:\Users\LMTest\promotional\mercor-affiliate-blog"

# Step 1: Ensure blog directory exists
if (-not (Test-Path $blogPath)) {
    Write-Host "Blog posts folder missing. Creating $blogPath..."
    New-Item -ItemType Directory -Path $blogPath -Force | Out-Null
}

# Step 2: Detect or load model (with suffix)
$modelLine = & $lmStudioPath ps | Select-String "LOADED"
if ($modelLine) {
    $model = ($modelLine -split '\s+')[0]
} else {
    Write-Host "No model loaded. Loading default model md-coder-qwen3-8b..."
    & $lmStudioPath load md-coder-qwen3-8b | Out-Null
    # Re-check with suffix
    $modelLine = & $lmStudioPath ps | Select-String "LOADED"
    $model = ($modelLine -split '\s+')[0]
}

# Step 3: Run prompt
try {
    $output = & $lmStudioPath chat $model -p $Prompt 2>$null
} catch {
    Write-Warning "Non-fatal LM Studio CLI error suppressed."
    $output = ""
}

# Step 4: Clean output (remove ANSI escape codes)
$cleanOutput = $output -replace '\x1B

\[[0-9;]*[A-Za-z]', ''

# Step 5: Guard against empty output
if (-not $cleanOutput.Trim()) {
    Write-Error "Model output was empty. Aborting commit."
    exit 1
}

# Step 6: Validate category
$validCategories = @("creative","data","engineering","finance","language","law","medicine","misc","operations","sciences","tech")
if ($validCategories -notcontains $Category) {
    Write-Warning "Invalid category '$Category'. Defaulting to 'misc'."
    $Category = "misc"
}

# Step 7: Build filename + front matter
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$fileName  = "post-$timestamp.md"
$filePath  = Join-Path $blogPath $fileName

$frontMatter = @"
---
title: "Generated Post $timestamp"
date: $(Get-Date -Format "yyyy-MM-ddTHH:mm:ss")
category: $Category
layout: post
---
"@

# Step 8: Save file
$frontMatter + "`n" + $cleanOutput | Out-File -FilePath $filePath -Encoding UTF8
Write-Host "✅ Blog post saved to $filePath"

# Step 9: Git checks
if (-not (Test-Path (Join-Path $repoPath ".git"))) {
    Write-Error "No Git repo found at $repoPath. Initialize with 'git init' and add remote before running."
    exit 1
}

Set-Location $repoPath
$gitStatus = git status --porcelain
if ($gitStatus) {
    Write-Host "⚠️ Repo has uncommitted changes. Committing them first..."
    git add .
    git commit -m "Pre-automation cleanup $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
}

# Step 10: Commit and push new post
git add $filePath
git commit -m "Automated post $timestamp [$Category]"
git push origin main

Write-Host "✅ Blog post committed and pushed to GitHub Pages"
