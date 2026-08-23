<# 
.SYNOPSIS
Generates blog content using LM Studio with dynamic section injection from blogData.json.
Always enforces Sam Browne + Molly Keyser writing style.
#>

param(
    [string]$JsonFile = ".\blogData.json",
    [string]$OutputDir = ".\GeneratedBlogs"
)

$lmstudioExe = "C:\Users\LMTest\.lmstudio\bin\lms.exe"
$model = "qwen2.5-coder-1.5b-instruct"

# Load JSON
$blogData = Get-Content $JsonFile -Raw | ConvertFrom-Json

# Style directive
$styleDirective = @"
Always write in the blended style of Sam Browne + Molly Keyser:
- Story-driven narrative arc
- Punchy and emotional tone
- Persuasive marketing style
- Structured, recruiter-friendly insights
- Clear frameworks and actionable takeaways
- No emojis
"@

# Build dynamic Markdown template from JSON
$markdownTemplate = @"
---
layout: $($blogData.layout)
title: ""$($blogData.title)""
description: ""$($blogData.description)""
canonical: ""$($blogData.canonical)""
og_title: ""$($blogData.og_title)""
og_description: ""$($blogData.og_description)""
og_image: ""$($blogData.og_image)""
twitter_title: ""$($blogData.twitter_title)""
twitter_description: ""$($blogData.twitter_description)""
twitter_image: ""$($blogData.twitter_image)""
date: ""$($blogData.date)""
tags: [""$($blogData.tags[0])""]
thumbnail: ""$($blogData.thumbnail)""
permalink: ""$($blogData.permalink)""
analytics: ""$($blogData.analytics)""
---

# The Future of Remote $($blogData.tags[0]) Careers

## Persona & Context
$($blogData.sections.persona_context)

## Salary Range
- Entry Level: $($blogData.sections.salary_range.entry_level)
- Mid Level: $($blogData.sections.salary_range.mid_level)
- Senior Level: $($blogData.sections.salary_range.senior_level)

## Growth Path
$($blogData.sections.growth_path)

## Day in the Life
$($blogData.sections.day_in_life)

## Tools Used
- $($blogData.sections.tools_used[0])
- $($blogData.sections.tools_used[1])
- $($blogData.sections.tools_used[2])

## Skills Required
- $($blogData.sections.skills_required[0])
- $($blogData.sections.skills_required[1])
- $($blogData.sections.skills_required[2])

## Lead Magnet CTA
$($blogData.sections.lead_magnet_cta)

## Recommended Resources
- $($blogData.sections.recommended_resources[0])
- $($blogData.sections.recommended_resources[1])

## Disclosure
$($blogData.sections.disclosure)
"@

# Final prompt sent to LM Studio
$finalPrompt = "$styleDirective`n`n$markdownTemplate"

# Ensure output directory exists
if (-not (Test-Path $OutputDir)) { New-Item -ItemType Directory -Path $OutputDir }

# Run LM Studio
$content = & $lmstudioExe chat --model $model --text $finalPrompt

# Save output
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$outFile = Join-Path $OutputDir "Blog-$timestamp.md"
$content | Out-File $outFile -Encoding UTF8

Write-Host "✅ Blog generated using dynamic JSON template: $outFile"
