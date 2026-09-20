<#
<#
<#
<#
<#
<#
<#
.SYNOPSIS
  Batch creates blog posts with canonical template.

.DESCRIPTION
  Generates Markdown blog posts in src/posts/ using the successful
  MABS template format and CSS conventions. Ensures valid YAML front matter
  with affiliate link, description, category, layout, keywords, tags, and thumbnail.
  Body content is written in the blended style of Molly Keyser and Sam Browne:
 - Story-driven narrative arc
 - Punchy and emotional tone
 - Persuasive marketing style
 - Clear frameworks and actionable takeaways
 - Recruiter-friendly insights
#>

$repoRoot = "C:\Users\LMTest\promotional\mercor-affiliate-blog"
$postsPath = Join-Path $repoRoot "src\posts"
$canonicalLink = "https://t.mercor.com/a2rcw"

Write-Host "=== BatchCreateBlogs.ps1 started ==="

# Define posts to generate (one per category)
$posts = @(
    @{ Title = "Creative Careers"; Slug = "creative-careers"; Category = "creative"; Description = "Exploring creative career paths"; Keywords = "creative, design, art" },
    @{ Title = "Data Insights"; Slug = "data-insights"; Category = "data"; Description = "Harnessing data for smarter decisions"; Keywords = "data, analytics, insights" },
    @{ Title = "Engineering Futures"; Slug = "engineering-futures"; Category = "engineering"; Description = "Innovations shaping engineering"; Keywords = "engineering, innovation, design" },
    @{ Title = "Finance Strategies"; Slug = "finance-strategies"; Category = "finance"; Description = "Smart finance strategies for growth"; Keywords = "finance, investment, growth" },
    @{ Title = "Language Learning"; Slug = "language-learning"; Category = "language"; Description = "Effective language learning methods"; Keywords = "language, learning, communication" },
    @{ Title = "Law and Policy"; Slug = "law-policy"; Category = "law"; Description = "Understanding law and policy"; Keywords = "law, policy, regulation" },
    @{ Title = "Medicine Advances"; Slug = "medicine-advances"; Category = "medicine"; Description = "Latest advances in medicine"; Keywords = "medicine, health, innovation" },
    @{ Title = "Miscellaneous Trends"; Slug = "misc-trends"; Category = "misc"; Description = "Exploring diverse topics"; Keywords = "misc, trends, general" },
    @{ Title = "Operations Excellence"; Slug = "operations-excellence"; Category = "operations"; Description = "Optimizing operations for success"; Keywords = "operations, management, efficiency" },
    @{ Title = "Science Discoveries"; Slug = "science-discoveries"; Category = "sciences"; Description = "Breakthroughs in science"; Keywords = "science, research, discovery" },
    @{ Title = "Tech Innovations"; Slug = "tech-innovations"; Category = "tech"; Description = "Latest innovations in technology"; Keywords = "tech, innovation, future" }
)

foreach ($post in $posts) {
    $filePath = Join-Path $postsPath ("{0}.md" -f $post.Slug)

    # ✅ Stable front matter template (no date)
    $frontMatter = @""
---
title: $($post.Title)
description: $($post.Description)
category: $($post.Category)
layout: post
affiliate: $canonicalLink
keywords: $($post.Keywords)
tags: [$($post.Category)]
thumbnail: "/assets/images/thumbnails/$($post.Category).png"
---
"@"

    # ✅ Body content in Molly Keyser + Sam Browne blended style
    $body = @""
# $($post.Title)

🌟 Why This Matters

Imagine yourself facing the challenges of $($post.Title). This isn’t just about information — it’s about transformation. Readers want clarity, confidence, and a roadmap they can trust. That’s why this post speaks directly to their goals and frustrations, blending emotional resonance with practical frameworks.

## Key Insights
- Story-driven examples that connect emotionally
- Clear frameworks that recruiters and professionals can apply
- Actionable steps that move readers from confusion to clarity
- Persuasive takeaways that inspire immediate action

## SEO Keywords
$($post.Keywords)

## Call to Action
Your next step matters. [Click here]($canonicalLink) to access exclusive resources, tools, and opportunities that will help you put these insights into practice today.
"@"

    $content = $frontMatter + "`n" + $body
    Set-Content -Path $filePath -Value $content -Encoding UTF8

    Write-Host "✅ Generated $filePath"
}

Write-Host "=== BatchCreateBlogs.ps1 complete ==="
#>
}
#>
}
#>
}
#>
}
#>
}
#>
}