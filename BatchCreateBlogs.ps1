<#
.SYNOPSIS
  Generate blog posts in Markdown format for MABS.
.DESCRIPTION
  - Uses existing Eleventy-compatible template
  - Outputs posts into src\posts\
  - Ensures valid YAML front matter
  - No external JSON dependency
#>

$ErrorActionPreference = "Stop"

Write-Host "=== BatchCreateBlogs.ps1 started ===" -ForegroundColor Cyan

# Output directory
$OutputDir = "src\posts"
if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir | Out-Null
}

# Example post metadata (replace with your own automation source)
$posts = @(
    @{
        Slug = "remote-creative-jobs"
        Title = "Remote Creative Jobs"
        Description = "Latest creative opportunities for remote workers."
        Category = "creative"
        Thumbnail = "/assets/images/thumbnails/creative.png"
        Content = "Explore remote creative opportunities across design, writing, and media."
    },
    @{
        Slug = "finance-apps"
        Title = "Best Finance Apps"
        Description = "Manage your money smarter with these apps."
        Category = "finance"
        Thumbnail = "/assets/images/thumbnails/finance.png"
        Content = "Track expenses and grow wealth with these finance tools."
    }
)

foreach ($post in $posts) {
    $fileName = Join-Path $OutputDir "$($post.Slug).md"

    $frontMatter = @"
---
title: $($post.Title)
description: $($post.Description)
tags: [$($post.Category)]
thumbnail: $($post.Thumbnail)
layout: layouts/post.njk
date: $(Get-Date -Format "yyyy-MM-dd")
---
"@

    $finalContent = $frontMatter + "`n" + $post.Content

    Set-Content -Path $fileName -Value $finalContent -Encoding UTF8

    Write-Host "✅ Generated $fileName" -ForegroundColor Green
}

Write-Host "=== BatchCreateBlogs.ps1 complete ===" -ForegroundColor Cyan
