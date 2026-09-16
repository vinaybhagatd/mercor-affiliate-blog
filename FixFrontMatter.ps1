<#
.SYNOPSIS
  Normalizes front matter and body content in blog posts.

.DESCRIPTION
  Ensures each Markdown file has valid YAML front matter using the stable template:
    - No date field
    - Title, description, category, layout, affiliate, keywords, tags, thumbnail
  Normalizes body content to Molly Keyser + Sam Browne blended style.
  Enforces tag rewrite: tags always mirror category.
#>

param(
  [string]$PostsDir = "C:\Users\LMTest\promotional\mercor-affiliate-blog\src\posts"
)

$canonicalLink = "https://t.mercor.com/a2rcw"
$allowedCategories = @(
    "creative","data","engineering","finance","language",
    "law","medicine","misc","operations","sciences","tech"
)

Write-Host "=== FixFrontMatter.ps1 started ===" -ForegroundColor Cyan

$files = Get-ChildItem $PostsDir -Filter *.md -ErrorAction SilentlyContinue
foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw
    $modified = $false

    # ✅ Ensure front matter delimiters
    if ($content -notmatch "^---") {
        $content = "---`n" + $content
        $modified = $true
    }
    if ($content -notmatch "(?m)^---$") {
        $content += "`n---"
        $modified = $true
    }

    # ✅ Title
    if (-not ($content -match "title:\s*")) {
        $newTitle = $file.BaseName
        $content = $content -replace "(?m)^---", "---`ntitle: $newTitle"
        $modified = $true
    }

    # ✅ Description
    if (-not ($content -match "description:\s*")) {
        $newDesc = "Auto-generated description for $($file.BaseName)."
        $content = $content -replace "(?m)^---", "---`ndescription: $newDesc"
        $modified = $true
    }

    # ✅ Category
    if (-not ($content -match "category:\s*(\w+)")) {
        $category = Split-Path $file.DirectoryName -Leaf
        if ($allowedCategories -contains $category) {
            $newCategory = $category
        } else {
            $newCategory = "misc"
        }
        $content = $content -replace "(?m)^---", "---`ncategory: $newCategory"
        $modified = $true
    } else {
        $null = $content -match "category:\s*(\w+)"
        $newCategory = $Matches[1]
    }

    # ✅ Layout
    if (-not ($content -match "layout:\s*")) {
        $content = $content -replace "(?m)^---", "---`nlayout: post"
        $modified = $true
    }

    # ✅ Affiliate
    if (-not ($content -match "affiliate:\s*")) {
        $content = $content -replace "(?m)^---", "---`naffiliate: $canonicalLink"
        $modified = $true
    }

    # ✅ Keywords
    if (-not ($content -match "keywords:\s*")) {
        $content = $content -replace "(?m)^---", "---`nkeywords: $newCategory"
        $modified = $true
    }

    # ✅ Tags (force rewrite to mirror category)
    if ($content -match "tags:\s*") {
        $content = $content -replace "(?m)^tags:.*$", "tags: [$newCategory]"
        Write-Host "Rewrote tags to [$newCategory] in $($file.Name)" -ForegroundColor Yellow
        $modified = $true
    } else {
        $content = $content -replace "(?m)^---", "---`ntags: [$newCategory]"
        $modified = $true
    }

    # ✅ Thumbnail (safe quoting)
    if (-not ($content -match "thumbnail:\s*")) {
        $thumbLine = "thumbnail: `"/assets/images/thumbnails/$newCategory.png`""
        $content = $content -replace "(?m)^---", "---`n$thumbLine"
        $modified = $true
    }

    # ✅ Remove date permanently
    if ($content -match "date:\s*") {
        $content = $content -replace "(?m)^date:.*$", ""
        Write-Host "Removed date from $($file.Name)" -ForegroundColor Yellow
        $modified = $true
    }

    # ✅ Normalize body content style
    $bodyTemplate = @"
# $($file.BaseName)

🌟 Why This Matters

Imagine yourself facing the challenges of $($file.BaseName). This isn’t just about information — it’s about transformation. Readers want clarity, confidence, and a roadmap they can trust. That’s why this post speaks directly to their goals and frustrations, blending emotional resonance with practical frameworks.

## Key Insights
- Story-driven examples that connect emotionally
- Clear frameworks that recruiters and professionals can apply
- Actionable steps that move readers from confusion to clarity
- Persuasive takeaways that inspire immediate action

## SEO Keywords
$newCategory

## Call to Action
Your next step matters. [Click here]($canonicalLink) to access exclusive resources, tools, and opportunities that will help you put these insights into practice today.
"@

    if ($content -notmatch "🌟 Why This Matters") {
        $frontBlock = ($content.Split("---")[0] + "---")
        $content = $frontBlock + "`n" + $bodyTemplate
        Write-Host "Normalized body content in $($file.Name)" -ForegroundColor Yellow
        $modified = $true
    }

    if ($modified) {
        Set-Content -Path $file.FullName -Value $content -Encoding UTF8
        Write-Host "✔ Updated $($file.Name)" -ForegroundColor Green
    } else {
        Write-Host "✔ No changes needed for $($file.Name)" -ForegroundColor Green
    }
}

Write-Host "=== FixFrontMatter.ps1 complete. All posts normalized to stable template, tags rewritten to match category, and blended style enforced. ===" -ForegroundColor Cyan
