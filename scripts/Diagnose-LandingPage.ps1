<#.SYNOPSIS
  Diagnose blank landing page in MABS.
.DESCRIPTION
 - Checks index.njk for loops.
 - Confirms collections in .eleventy.js.
 - Reports number of Markdown posts and their tags.
#>

$projectRoot = "C:\Users\LMTest\promotional\mercor-affiliate-blog"
$srcPath = Join-Path $projectRoot "src"

Write-Host "Diagnosing landing page in $projectRoot..."

# --- Check index.njk loops ---
$indexPath = Join-Path $srcPath "index.njk"
if (Test-Path $indexPath) {
    $indexContent = Get-Content $indexPath -Raw
    $hasCategoriesLoop = $indexContent -match "collections\.categories"
    $hasPostsLoop = $indexContent -match "collections\.posts"
    Write-Host "index.njk loops: Categories=$hasCategoriesLoop, Posts=$hasPostsLoop"
}
else {
    Write-Host "❌ index.njk not found."
}

# --- Check .eleventy.js collections ---
$eleventyPath = Join-Path $projectRoot ".eleventy.js"
if (Test-Path $eleventyPath) {
    $eleventyContent = Get-Content $eleventyPath -Raw
    $hasCategories = $eleventyContent -match 'addCollection\("categories"'
    $hasPosts = $eleventyContent -match 'addCollection\("posts"'
    Write-Host ".eleventy.js collections: Categories=$hasCategories, Posts=$hasPosts"
}
else {
    Write-Host "❌ .eleventy.js not found."
}

# --- Inspect Markdown posts ---
$postsPath = Join-Path $srcPath "posts"
if (Test-Path $postsPath) {
    $posts = Get-ChildItem -Path $postsPath -Filter *.md
    Write-Host "Found $($posts.Count) posts."
    foreach ($post in $posts) {
        $content = Get-Content $post.FullName -Raw
        $titleMatch = [regex]::Match($content, 'title:\s*"?(.+?)"?')
        $tagsMatch = [regex]::Match($content, 'tags:\s*

\[(.+?)\]

')
        $title = if ($titleMatch.Success) { $titleMatch.Groups[1].Value } else { "MISSING" }
        $tags = if ($tagsMatch.Success) { $tagsMatch.Groups[1].Value } else { "MISSING" }
        Write-Host "Post: $($post.Name) | Title=$title | Tags=$tags"
    }
}
else {
    Write-Host "❌ posts folder not found."
}

Write-Host "Diagnosis complete."
#>
