# GenerateAndPublishBlog.ps1
# Full automation: LM Studio → Eleventy → GitHub Pages

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

# Step 2: Detect or load model
$model = & $lmStudioPath ps | Select-String "LOADED" | ForEach-Object { ($_ -split '\s+')[0] }
if (-not $model) {
    Write-Host "No model loaded. Loading default model md-coder-qwen3-8b..."
    & $lmStudioPath load md-coder-qwen3-8b | Out-Null
    $model = "md-coder-qwen3-8b"
}

# Step 3: Run prompt
$output = & $lmStudioPath chat $model -p $Prompt

# Step 4: Validate category
$validCategories = @("creative","data","engineering","finance","language","law","medicine","misc","operations","sciences","tech")
if ($validCategories -notcontains $Category) {
    Write-Warning "Invalid category '$Category'. Defaulting to 'misc'."
    $Category = "misc"
}

# Step 5: Build filename + front matter
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

# Step 6: Save file
$frontMatter + "`n" + $output | Out-File -FilePath $filePath -Encoding UTF8
Write-Host "✅ Blog post saved to $filePath"

# Step 7: Git checks
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

# Step 8: Commit and push new post
git add $filePath
git commit -m "Automated post $timestamp [$Category]"
git push origin main

Write-Host "✅ Blog post committed and pushed to GitHub Pages"
