<#.SYNOPSIS
  Verifies that Fix-LandingPage.ps1 applied correctly.
.DESCRIPTION
 - Checks index.njk for category and post loops.
 - Confirms category.njk and post.njk exist.
 - Validates .eleventy.js collections wiring.
 - Ensures Markdown posts have title and tags.
#>

$projectRoot = "C:\Users\LMTest\promotional\mercor-affiliate-blog"
$srcPath = Join-Path $projectRoot "src"

Write-Host "Verifying landing page fix in $projectRoot..."

# --- Check index.njk ---
$indexPath = Join-Path $srcPath "index.njk"
if (Test-Path $indexPath) {
    $indexContent = Get-Content $indexPath -Raw
    if ($indexContent -match "collections\.categories" -and $indexContent -match "collections\.posts") {
        Write-Host "✅ index.njk contains loops for categories and posts."
    }
    else {
        Write-Host "❌ index.njk missing category/post loops."
    }
}
else {
    Write-Host "❌ index.njk not found."
}

# --- Check category.njk ---
$categoryPath = Join-Path $srcPath "categories\category.njk"
if (Test-Path $categoryPath) {
    Write-Host "✅ category.njk exists."
}
else {
    Write-Host "❌ category.njk missing."
}

# --- Check post.njk ---
$postPath = Join-Path $srcPath "posts\post.njk"
if (Test-Path $postPath) {
    Write-Host "✅ post.njk exists."
}
else {
    Write-Host "❌ post.njk missing."
}

# --- Check .eleventy.js collections ---
$eleventyPath = Join-Path $projectRoot ".eleventy.js"
if (Test-Path $eleventyPath) {
    $eleventyContent = Get-Content $eleventyPath -Raw
    if ($eleventyContent -match 'addCollection\("categories"' -and $eleventyContent -match 'addCollection\("posts"') {
        Write-Host "✅ .eleventy.js defines categories and posts collections."
    }
    else {
        Write-Host "❌ .eleventy.js missing collections wiring."
    }
}
else {
    Write-Host "❌ .eleventy.js not found."
}

# --- Check Markdown posts ---
$postsPath = Join-Path $srcPath "posts"
if (Test-Path $postsPath) {
    Get-ChildItem -Path $postsPath -Filter *.md | ForEach-Object {
        $content = Get-Content $_.FullName -Raw
        $hasTitle = $content -match "title:"
        $hasTags = $content -match "tags:"
        if ($hasTitle -and $hasTags) {
            Write-Host "✅ $($_.Name) has title and tags."
        }
        else {
            Write-Host "❌ $($_.Name) missing title or tags."
        }
    }
}
else {
    Write-Host "❌ posts folder not found."
}

Write-Host "Verification complete."
#>
