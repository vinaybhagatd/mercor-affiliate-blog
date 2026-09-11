<#
.SYNOPSIS
  Batch creates blog posts with canonical template.

.DESCRIPTION
  Generates Markdown blog posts in src/posts/ using the successful
  MABS template format and CSS conventions. Ensures valid YAML front matter
  with affiliate link, description, category, layout, and keywords.
  Body includes headline, intro, 🌟 Why This Matters, SEO keywords,
  and CTA section.
#>

$repoRoot = "C:\Users\LMTest\promotional\mercor-affiliate-blog"
$postsPath = Join-Path $repoRoot "src\posts"
$canonicalLink = "https://t.mercor.com/a2rcw"

Write-Host "=== BatchCreateBlogs.ps1 started ==="

# Define posts to generate
$posts = @(
    @{ Title = "Finance Apps"; Slug = "finance-apps"; Category = "creative"; Description = "Exploring top finance apps for productivity and growth"; Keywords = "finance, apps, productivity, creative" },
    @{ Title = "Remote Creative Jobs"; Slug = "remote-creative-jobs"; Category = "creative"; Description = "Opportunities in remote creative work"; Keywords = "remote jobs, creative, freelancing, design" }
    # Add more posts here as needed
)

foreach ($post in $posts) {
    $filePath = Join-Path $postsPath ("{0}.md" -f $post.Slug)

    $frontMatter = @"
---
title: $($post.Title)
description: $($post.Description)
category: $($post.Category)
layout: post
affiliate: $canonicalLink
keywords: $($post.Keywords)
---
"@

    $body = @"
# $($post.Title)

🌟 Why This Matters

This section explains why $($post.Title) is important for readers, tying into their goals and challenges.

## Key Insights
- Practical tips and examples
- Story-driven context
- Emotional resonance

## SEO Keywords
$($post.Keywords)

## Call to Action
Ready to explore more? [Click here]($canonicalLink) to access exclusive resources.
"@

    $content = $frontMatter + "`n" + $body
    Set-Content -Path $filePath -Value $content -Encoding UTF8

    Write-Host "✅ Generated $filePath"
}

Write-Host "=== BatchCreateBlogs.ps1 complete ==="
