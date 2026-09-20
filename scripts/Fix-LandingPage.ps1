<#.SYNOPSIS
  Automates fix for blank landing page in MABS.
.DESCRIPTION
 - Restores canonical index.njk with dynamic loops.
 - Ensures collections wiring in .eleventy.js.
 - Creates canonical category.njk and post.njk.
 - Cleans up invalid tags in Markdown posts.
#>

$projectRoot = "C:\Users\LMTest\promotional\mercor-affiliate-blog"
$srcPath = Join-Path $projectRoot "src"

Write-Host "Applying landing page fix in $projectRoot..."

# --- Restore canonical index.njk ---
$indexContent = @""
-- -
layout: base.njk
title: Mercor Affiliate Blog System
permalink: /index.html
-- -

<h1>Mercor Affiliate Blog System</h1>

<nav>
<ul>
<li><a href="/">Home</a></li>
<li><a href="/categories/">Explore Categories</a></li>
<li><a href="/pricing/">Pricing</a></li>
<li><a href="/contact/">Contact</a></li>
</ul>
</nav>

<section id="categories">
<h2>Explore Categories</h2>
<ul>
{ % for category, posts in collections.categories % }
<li>
<a href="/categories/{{ category }}/"> { { category | capitalize } }</a>
<span>({ { posts | length } } posts)</span>
</li>
{ % endfor % }
</ul>
</section>

<section id="blogs">
<h2>Explore Blogs</h2>
<ul>
{ % for post in collections.posts | reverse % }
<li>
<a href="{{ post.url }}"> { { post.data.title } }</a>
{ % if post.data.tags % }
<span class="tags"> { { post.data.tags | join(", ") } }</span>
{ % endif % }
</li>
{ % endfor % }
</ul>
</section>

<footer>
<p>© Mercor Affiliate Blog System</p>
</footer>
"@"

$indexPath = Join-Path $srcPath "index.njk"
$indexContent | Set-Content -Path $indexPath -Encoding UTF8
Write-Host "Restored index.njk"

# --- Restore canonical category.njk ---
$categoryContent = @""
-- -
layout: base.njk
pagination:
data: collections.categories
size: 1
alias: category
permalink: /categories/ { { category } }/index.html
-- -

<h1> { { category | capitalize } }</h1>
<ul>
{ % for post in collections.categories[category] % }
<li><a href="{{ post.url }}"> { { post.data.title } }</a></li>
{ % endfor % }
</ul>
"@"

$categoryPath = Join-Path $srcPath "categories\category.njk"
if (!(Test-Path (Split-Path $categoryPath -Parent))) { New-Item -ItemType Directory -Path (Split-Path $categoryPath -Parent) | Out-Null }
$categoryContent | Set-Content -Path $categoryPath -Encoding UTF8
Write-Host "Restored category.njk"

# --- Restore canonical post.njk ---
$postContent = @""
-- -
layout: base.njk
-- -

<article>
<h1> { { title } }</h1>
<div class="content"> { { content | safe } }</div>
{ % if tags % }
<p class="tags">Categories: { { tags | join(", ") } }</p>
{ % endif % }
</article>
"@"

$postPath = Join-Path $srcPath "posts\post.njk"
if (!(Test-Path (Split-Path $postPath -Parent))) { New-Item -ItemType Directory -Path (Split-Path $postPath -Parent) | Out-Null }
$postContent | Set-Content -Path $postPath -Encoding UTF8
Write-Host "Restored post.njk"

# --- Ensure collections wiring in .eleventy.js ---
$eleventyConfig = @""
module.exports = function(eleventyConfig) {
    eleventyConfig.addCollection("categories", function(collectionApi) {
            let categories = {};
            collectionApi.getAll().forEach(item => {
                    if (item.data.tags) {
                        item.data.tags.forEach(tag => {
                                if (!categories[tag]) categories[tag] = [];
                                categories[tag].push(item);
                            });
                    }
                });
            return categories;
        });

    eleventyConfig.addCollection("posts", function(collectionApi) {
            return collectionApi.getFilteredByGlob("src/posts/*.md");
        });

    return {
        dir: {
            input: "src",
            output: "_site",
            includes: "_includes",
            layouts: "_layouts"
        }
    };
};
"@"

$eleventyPath = Join-Path $projectRoot ".eleventy.js"
$eleventyConfig | Set-Content -Path $eleventyPath -Encoding UTF8
Write-Host "Updated .eleventy.js collections wiring"

# --- Clean up invalid 'tags: ["post"]' in Markdown files ---
Get-ChildItem -Path (Join-Path $srcPath "posts") -Filter *.md | ForEach-Object {
    $content = Get-Content $_.FullName -Raw
    if ($content -match 'tags:\s*

\[["'']post["'']\]

') {
        $fixed = $content -replace 'tags:\s*

\[["'']post["'']\]

', 'tags: ["misc"]'
        $fixed | Set-Content $_.FullName -Encoding UTF8
        Write-Host "Fixed tags in $($_.Name)"
    }
}

Write-Host "✅ Landing page fix complete. Run 'npx eleventy --clean --serve' to verify."
#>
