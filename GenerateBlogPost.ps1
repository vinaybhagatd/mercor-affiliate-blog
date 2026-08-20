# GenerateBlogPost.ps1
# Automates LM Studio prompt → Eleventy blog post

param(
    [string]$Prompt = "Write a 50-word story about a remote creative professional.",
    [string]$Category = "tech"  # default category
)

$lmStudioPath = "C:\Users\LMTest\.lmstudio\bin\lms.exe"
$blogPath     = "C:\Users\LMTest\promotional\mercor-affiliate-blog\content\posts"

# Step 1: Detect loaded model
$model = & $lmStudioPath ps | Select-String "LOADED" | ForEach-Object { ($_ -split '\s+')[0] }

if (-not $model) {
    Write-Host "No model loaded. Loading default model md-coder-qwen3-8b..."
    & $lmStudioPath load md-coder-qwen3-8b
    $model = "md-coder-qwen3-8b"
}

if (-not $model) {
    Write-Error "No model loaded. Please load a model first with: $lmStudioPath load <model-name>"
    exit 1
}

# Step 2: Run prompt
$output = & $lmStudioPath chat $model -p $Prompt

# Step 3: Enforce Eleventy categories
$validCategories = @("creative","data","engineering","finance","language","law","medicine","misc","operations","sciences","tech")
if ($validCategories -notcontains $Category) {
    Write-Warning "Invalid category '$Category'. Defaulting to 'misc'."
    $Category = "misc"
}

# Step 4: Build filename + front matter
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

# Step 5: Save file
$frontMatter + "`n" + $output | Out-File -FilePath $filePath -Encoding UTF8

Write-Host "✅ Blog post saved to $filePath"
