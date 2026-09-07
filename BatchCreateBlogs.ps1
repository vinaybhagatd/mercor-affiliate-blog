<#
.SYNOPSIS
  Generates new blog posts for MABS with valid YAML front matter and category-specific Mercor affiliate link.
.DESCRIPTION
  Reads affiliate-links.md to build a category→link map dynamically.
  Creates Markdown files in src/posts with proper Eleventy front matter:
    - title (category-aware)
    - date
    - category (from canonical list)
    - description (category-aware)
  Appends category-aware body content and category-specific Mercor affiliate link.
#>

param(
  [string]$PostsDir = "C:\Users\LMTest\promotional\mercor-affiliate-blog\src\posts",
  [string]$AffiliateFile = "C:\Users\LMTest\promotional\mercor-affiliate-blog\affiliate-links.md",
  [int]$Count = 5
)

# Canonical categories
$categories = @("creative","data","engineering","finance","language",
                "law","medicine","misc","operations","sciences","tech")

# Category-aware titles
$titleMap = @{
    "creative"    = @("Unlocking Creative Potential","Design Thinking in Action","Art Meets Innovation")
    "data"        = @("Data Trends Shaping 2026","Big Data Simplified","Analytics for Smarter Decisions")
    "engineering" = @("Engineering Breakthroughs","Building Smarter Systems","Innovations in Mechanical Design")
    "finance"     = @("Finance Tips for Growth","Smart Investing Strategies","Future of Digital Banking")
    "language"    = @("Mastering New Languages","Language Learning Hacks","The Power of Words")
    "law"         = @("Legal Insights for 2026","Understanding Modern Law","Compliance Made Simple")
    "medicine"    = @("Medical Advances","Healthcare Innovations","Wellness and Preventive Care")
    "misc"        = @("Miscellaneous Insights","Random Ideas Worth Sharing","Exploring Diverse Topics")
    "operations"  = @("Operations Excellence","Streamlining Workflows","Efficiency in Practice")
    "sciences"    = @("Scientific Discoveries","Exploring the Universe","Breakthroughs in Biology")
    "tech"        = @("Tech Innovations","Future of Computing","AI and Automation Trends")
}

# Category-aware descriptions
$descMap = @{
    "creative"    = @("Exploring creativity in everyday life.","Fresh ideas to inspire innovation.","Design and imagination at work.")
    "data"        = @("Turning raw data into insights.","Simplifying analytics for everyone.","Exploring trends in big data.")
    "engineering" = @("Engineering solutions for modern challenges.","Innovations driving mechanical progress.","Smart systems for a smarter world.")
    "finance"     = @("Tips for financial growth.","Exploring digital banking.","Smart investing strategies.")
    "language"    = @("Learning languages made easy.","The role of words in culture.","Unlocking communication potential.")
    "law"         = @("Legal compliance simplified.","Insights into modern law.","Understanding regulations in 2026.")
    "medicine"    = @("Healthcare breakthroughs.","Preventive care strategies.","Medical innovations shaping the future.")
    "misc"        = @("Exploring diverse ideas.","Miscellaneous insights worth sharing.","Random thoughts with impact.")
    "operations"  = @("Efficiency tips for workflows.","Operations strategies for success.","Streamlining processes effectively.")
    "sciences"    = @("Discoveries changing the world.","Exploring scientific breakthroughs.","Science insights for everyday life.")
    "tech"        = @("Innovations in computing.","AI trends reshaping industries.","Future of automation and tech.")
}

# Category-aware body content
$bodyMap = @{
    "creative"    = "Creativity fuels innovation and problem-solving. In this post, we explore how imagination can drive new solutions and inspire design thinking."
    "data"        = "Data is the backbone of modern decision-making. Here we look at how analytics and big data trends are shaping industries in 2026."
    "engineering" = "Engineering is about building smarter, stronger, and more efficient systems. This post highlights breakthroughs in mechanical and civil engineering."
    "finance"     = "Finance is evolving rapidly with digital banking and smart investing. We explore strategies for growth and financial resilience."
    "language"    = "Language connects cultures and people. This post discusses effective learning techniques and the power of communication."
    "law"         = "Law underpins society and governance. We examine compliance, modern regulations, and how legal frameworks adapt to change."
    "medicine"    = "Medicine continues to advance with new treatments and preventive care. This post highlights innovations improving health outcomes."
    "misc"        = "Miscellaneous ideas often spark unexpected insights. Here we share diverse thoughts and creative explorations."
    "operations"  = "Operations excellence is about efficiency and workflow optimization. This post explores strategies for streamlining processes."
    "sciences"    = "Science drives discovery and innovation. We highlight breakthroughs in biology, physics, and space exploration."
    "tech"        = "Technology is reshaping industries with AI and automation. This post explores innovations in computing and future trends."
}

# ✅ Parse affiliate-links.md to build category→link map
$affiliateLinks = @{}
if (Test-Path $AffiliateFile) {
    $lines = Get-Content $AffiliateFile
    foreach ($cat in $categories) {
        $pattern = "Apply for Remote $($cat.Substring(0,1).ToUpper() + $cat.Substring(1)) Roles"
        $match = $lines | Where-Object { $_ -match $pattern }
        if ($match -match '\((https:\/\/t\.mercor\.com\/[A-Za-z0-9]+)\)') {
            $affiliateLinks[$cat] = $matches[1]
        }
    }
}

# Ensure posts directory exists
if (-not (Test-Path $PostsDir)) {
    New-Item -ItemType Directory -Path $PostsDir | Out-Null
}

for ($i = 1; $i -le $Count; $i++) {
    $category = Get-Random -InputObject $categories
    $title = Get-Random -InputObject $titleMap[$category]
    $description = Get-Random -InputObject $descMap[$category]
    $bodyContent = $bodyMap[$category]
    $affiliateLink = $affiliateLinks[$category]
    $date = Get-Date -Format "yyyy-MM-dd"
    $fileName = "post-$category-$i.md"
    $filePath = Join-Path $PostsDir $fileName

    # ✅ YAML front matter
    $frontMatter = @"
---
title: "$title"
date: "$date"
category: $category
description: "$description"
---
"@

    # ✅ Post body with category-aware content + category-specific affiliate link
    $body = @"
$bodyContent

[Explore $category roles on Mercor]($affiliateLink)
"@

    # Write file
    $content = $frontMatter + "`r`n" + $body
    Set-Content -Path $filePath -Value $content -Encoding UTF8

    Write-Output "Created blog post: $fileName with category [$category], title '$title', and affiliate link $affiliateLink at $date"
}
