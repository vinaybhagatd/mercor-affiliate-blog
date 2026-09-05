<# 
.SYNOPSIS
Automates setup of Mercor Affiliate Blog System (MABS).
.DESCRIPTION
Installs dependencies, regenerates Eleventy config, layouts, and starter CSS.
Ensures deterministic folder paths and repeatable builds.
#>

# Guardrail: stop on error
$ErrorActionPreference = "Stop"

Write-Host "=== Mercor Affiliate Blog System Setup ==="

# Step 1: Ensure dependencies
Write-Host "Installing Eleventy and Luxon..."
npm install @11ty/eleventy luxon --save-dev

# Step 2: Regenerate .eleventy.js
$eleventyConfig = @"
const { DateTime } = require("luxon");

module.exports = function(eleventyConfig) {
  eleventyConfig.setFreezeReservedData(false);
  eleventyConfig.addPassthroughCopy("src/assets");

  // Dynamic category collections using built-in slug filter
  eleventyConfig.addCollection("categories", function(collection) {
    return collection.getAll().reduce((cats, item) => {
      if(item.data.tags) {
        item.data.tags.forEach(tag => {
          const slug = eleventyConfig.getFilter("slug")(tag);
          if(!cats[slug]) cats[slug] = [];
          cats[slug].push(item);
        });
      }
      return cats;
    }, {});
  });

  // Render body safely
  eleventyConfig.addFilter("renderBody", function(data) {
    if(data && data.body) return data.body;
    return "";
  });

  // Date filter
  eleventyConfig.addFilter("date", function(dateObj, format = "dd LLL yyyy") {
    return DateTime.fromJSDate(new Date(dateObj)).toFormat(format);
  });

  return {
    dir: {
      input: "src",
      includes: "_includes",
      layouts: "_layouts",
      output: "_site"
    },
    markdownTemplateEngine: "njk",
    htmlTemplateEngine: "njk",
    dataTemplateEngine: "njk"
  };
};
"@
Set-Content -Path ".eleventy.js" -Value $eleventyConfig -Encoding UTF8
Write-Host "Regenerated .eleventy.js"

# Step 3: Regenerate layouts
$layoutsPath = "src\_layouts"
New-Item -ItemType Directory -Force -Path $layoutsPath | Out-Null

# base.njk
$baseLayout = @"
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>{{ title or "Mercor Affiliate Blog" }}</title>
  <link rel="stylesheet" href="/assets/styles.css">
</head>
<body id="site-body">
  <header id="site-header" class="header">
    <h1 id="site-title" class="title"><a href="/">Mercor Affiliate Blog</a></h1>
    <nav id="site-nav" class="nav">
      <ul class="nav-list">
        {% for cat, posts in collections.categories %}
          <li class="nav-item"><a class="nav-link" href="/categories/{{ cat }}/">{{ cat }}</a></li>
        {% endfor %}
      </ul>
    </nav>
  </header>
  <main id="site-main" class="main">{% block body %}{% endblock %}</main>
  <footer id="site-footer" class="footer"><p class="footer-text">&copy; {{ "now" | date("yyyy") }} Mercor Affiliate Blog System</p></footer>
</body>
</html>
"@
Set-Content -Path "$layoutsPath\base.njk" -Value $baseLayout -Encoding UTF8

# post.njk
$postLayout = @"
---
layout: base.njk
---
{% block body %}
<article class="post">
  <h1 class="post-title">{{ title }}</h1>
  <p class="post-meta">Published on {{ date | date("dd LLL yyyy") }}</p>
  <div class="post-body">{{ body | renderBody | safe }}</div>
</article>
{% endblock %}
"@
Set-Content -Path "$layoutsPath\post.njk" -Value $postLayout -Encoding UTF8

# category.njk
$categoryLayout = @"
---
layout: base.njk
---
{% block body %}
<section class="category-page">
  <h1 class="category-title">Posts in {{ category }}</h1>
  <ul class="category-list">
    {% for post in collections[category] | reverse %}
      <li class="category-item">
        <h2 class="post-title"><a href="{{ post.url }}">{{ post.data.title }}</a></h2>
        <p class="post-meta">Published on {{ post.data.date | date("dd LLL yyyy") }}</p>
        <div class="excerpt">{{ post.data.body | renderBody | safe | truncate(200, true, "...") }}</div>
        <p><a class="read-more" href="{{ post.url }}">Read more →</a></p>
      </li>
    {% endfor %}
  </ul>
</section>
{% endblock %}
"@
Set-Content -Path "$layoutsPath\category.njk" -Value $categoryLayout -Encoding UTF8

# Step 4: Regenerate index.njk
$indexLayout = @"
---
layout: base.njk
title: "Mercor Affiliate Blog"
---
{% block body %}
<section class="home-page">
  <h1>Latest Posts</h1>
  <ul class="post-list">
    {% for post in collections.all | reverse | slice(0,10) %}
      <li class="post-item">
        <h2><a href="{{ post.url }}">{{ post.data.title }}</a></h2>
        <p class="post-meta">Published on {{ post.data.date | date("dd LLL yyyy") }}</p>
        <div class="excerpt">{{ post.data.body | renderBody | safe | truncate(200, true, "...") }}</div>
        <p><a class="read-more" href="{{ post.url }}">Read more →</a></p>
      </li>
    {% endfor %}
  </ul>
</section>
{% endblock %}
"@
Set-Content -Path "src\index.njk" -Value $indexLayout -Encoding UTF8

# Step 5: Regenerate categories/index.njk
$categoriesIndex = @"
---
layout: category.njk
pagination:
  data: collections.categories
  size: 1
  alias: category
permalink: "categories/{{ category }}/index.html"
---
"@
New-Item -ItemType Directory -Force -Path "src\categories" | Out-Null
Set-Content -Path "src\categories\index.njk" -Value $categoriesIndex -Encoding UTF8

# Step 6: Starter CSS
$assetsPath = "src\assets"
New-Item -ItemType Directory -Force -Path $assetsPath | Out-Null
$cssContent = @"
/* Starter stylesheet for MABS */
body#site-body { margin:0; font-family:'Segoe UI',Arial,sans-serif; line-height:1.6; background:#f9f9f9; color:#333; }
#site-header { background:#222; color:#fff; padding:1rem; }
#site-title a { color:#fff; text-decoration:none; }
#site-nav .nav-list { list-style:none; display:flex; flex-wrap:wrap; margin:0; padding:0; }
#site-nav .nav-item { margin-right:1rem; }
#site-nav .nav-link { color:#ddd; text-decoration:none; }
#site-nav .nav-link:hover { color:#fff; }
#site-main { max-width:800px; margin:2rem auto; padding:0 1rem; }
.post-title { font-size:2rem; margin-bottom:0.5rem; }
.post-meta { font-size:0.9rem; color:#666; margin-bottom:1rem; }
.post-body { font-size:1rem; line-height:1.7; }
.category-title { font-size:1.8rem; margin-bottom:1rem; }
.category-list { list-style:none; padding:0; }
.category-item { margin-bottom:2rem; border-bottom:1px solid #ddd; padding-bottom:1rem; }
.excerpt { font-size:0.95rem; color:#444; }
.read-more { font-weight:bold; color:#0066cc; text-decoration:none; }
.read-more:hover { text-decoration:underline; }
#site-footer { background:#222; color:#fff; text-align:center; padding:1rem; }
.footer-text { margin:0; font-size:0.85rem; }
"@
Set-Content -Path "$assetsPath\styles.css" -Value $cssContent -Encoding UTF8

Write-Host "=== Setup complete. Run 'npx eleventy --serve' to start the site. ==="

