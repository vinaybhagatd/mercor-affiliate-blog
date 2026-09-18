#!/usr/bin/env pwsh
<#
.SYNOPSIS
  FixFrontMatter.ps1 — Repairs missing or invalid front matter in Markdown posts.

.DESCRIPTION
  Scans src\posts\ for .md files and ensures each has valid YAML front matter.
  - Adds category and tags if missing.
  - Ensures tags include the category.
  - Preserves existing fields if valid.
  - Normalizes category/tags to lowercase.
  - Logs all outcomes (fixed, inserted, already valid) into logs\FixFrontMatterReport.txt
#>

$repoRoot   = "C:\Users\LMTest\promotional\mercor-affiliate-blog"
$postsPath  = Join-Path $repoRoot "src\posts"
$logsPath   = Join-Path $repoRoot "logs"
$reportFile = Join-Path $logsPath "FixFrontMatterReport.txt"

# Ensure logs folder exists
if (-not (Test-Path $logsPath)) { New-Item -ItemType Directory -Path $logsPath | Out-Null }

Write-Host "=== FixFrontMatter.ps1 started ===" -ForegroundColor Cyan
"=== Run started: $(Get-Date) ===" | Out-File -FilePath $reportFile -Encoding UTF8

Get-ChildItem -Path $postsPath -Recurse -Filter *.md | ForEach-Object {
    $file = $_.FullName
    $content = Get-Content $file -Raw
    $logEntry = ""

    if ($content -match "(?s)^---(.*?)---") {
        $yamlBlock = $matches[1]
        $fixed = $false

        # Ensure category
        if ($yamlBlock -notmatch "(?m)^category:") {
            $yamlBlock += "`ncategory: general"
            $fixed = $true
            $logEntry += "Added category to $($_.Name)`n"
        }

        # Ensure tags
        if ($yamlBlock -notmatch "(?m)^tags:") {
            $yamlBlock += "`ntags: [general]"
            $fixed = $true
            $logEntry += "Added tags to $($_.Name)`n"
        } else {
            $categoryMatch = [regex]::Match($yamlBlock, "(?m)^category:\s*(\w+)")
            if ($categoryMatch.Success) {
                $categoryNorm = $categoryMatch.Groups[1].Value.Trim().ToLower()
                $tagsMatch = [regex]::Match($yamlBlock, "(?m)^tags:\s*

\[(.*?)\]

")
                if ($tagsMatch.Success) {
                    $tagsNorm = $tagsMatch.Groups[1].Value.Split(',') | ForEach-Object { $_.Trim().ToLower() }
                    if (-not ($tagsNorm -contains $categoryNorm)) {
                        $yamlBlock = $yamlBlock -replace "(?m)^tags:\s*

\[(.*?)\]

", "tags: [$($tagsNorm -join ', '), $categoryNorm]"
                        $fixed = $true
                        $logEntry += "Appended category to tags in $($_.Name)`n"
                    }
                }
            }
        }

        if ($fixed) {
            $newContent = $content -replace "(?s)^---(.*?)---", "---$yamlBlock`n---"
            Set-Content -Path $file -Value $newContent -Encoding UTF8
            Write-Host "✔ Updated $($_.Name)" -ForegroundColor Green
            $logEntry | Out-File -FilePath $reportFile -Encoding UTF8 -Append
        } else {
            Write-Host "✔ Already valid: $($_.Name)" -ForegroundColor DarkGray
            "Already valid: $($_.Name)" | Out-File -FilePath $reportFile -Encoding UTF8 -Append
        }
    } else {
        # No front matter block at all — insert template
        $template = @"
---
title: "$($_.BaseName)"
description: "Auto-generated description"
category: general
tags: [general]
thumbnail: /assets/images/thumbnails/default.png
affiliate: "https://example.com/product"
keywords: ["keyword1","keyword2"]
layout: post.njk
---
"@
        $newContent = $template + "`n" + $content
        Set-Content -Path $file -Value $newContent -Encoding UTF8
        Write-Host "✔ Inserted template into $($_.Name)" -ForegroundColor Yellow
        "Inserted template into $($_.Name)" | Out-File -FilePath $reportFile -Encoding UTF8 -Append
    }
}

"=== Run complete: $(Get-Date) ===`n" | Out-File -FilePath $reportFile -Encoding UTF8 -Append
Write-Host "=== FixFrontMatter.ps1 complete ===" -ForegroundColor Cyan
