<#
<# .SYNOPSIS #>
    Auto-fix common MABS errors and enforce guardrails.
.DESCRIPTION
    Cleans PowerShell scripts, validates with ScriptAnalyzer,
    sanitizes reserved keys in blog data, posts, and layouts,
    regenerates Eleventy wiring, and runs build pipeline.
#>

$repoRoot = "C:\Users\LMTest\promotional\mercor-affiliate-blog"

Write-Host "🔧 Starting AutoFix for MABS..." -ForegroundColor Cyan

# 1. Script hygiene fixes
Get-ChildItem -Path $repoRoot -Filter *.ps1 -Recurse | ForEach-Object {
    $content = Get-Content $_.FullName -Raw
    $content = $content -replace "^\|", ""
    $content = $content -replace "(\<# .SYNOPSIS.*?)(\r?\n)", "<# `$1 #>`$2" #>
    $content = $content -replace "\+=", "+="
    $content = $content -replace "-Filter \((\*\.md)\)", '-Filter "$1"'
    $content = $content -replace "^using .*", "# replaced invalid using"
    $content = $content -replace "u([0-9A-Fa-f]{4})", 'u{$1}'
    Set-Content $_.FullName $content
    Write-Host "✅ Fixed hygiene in $($_.Name)" -ForegroundColor Green
}

# 2. Run ScriptAnalyzer
Write-Host "🔎 Running ScriptAnalyzer..." -ForegroundColor Cyan
Invoke-ScriptAnalyzer -Path $repoRoot -Recurse -Settings "$repoRoot\PSScriptAnalyzerSettings.psd1" -ReportSummary

# 3. Verify .gitignore
Write-Host "📋 Verifying .gitignore..." -ForegroundColor Cyan
& "$repoRoot\Verify-Gitignore.ps1"

# 4. Sanitize reserved keys in blog data
Write-Host "🧹 Sanitizing reserved keys in blog data..." -ForegroundColor Cyan
Get-ChildItem -Path "$repoRoot\data" -Filter *.json -Recurse | ForEach-Object {
    $content = Get-Content $_.FullName -Raw
    $content = $content -replace '"content"\s*:', '"body":'
    Set-Content $_.FullName $content
    Write-Host "✅ Renamed reserved property in $($_.Name)" -ForegroundColor Green
}

# 5. Sanitize reserved keys in posts
Write-Host "🧹 Sanitizing reserved keys in posts..." -ForegroundColor Cyan
Get-ChildItem -Path "$repoRoot\src\posts" -Filter "*.md" -Recurse | ForEach-Object {
    $post = Get-Content $_.FullName -Raw
    $post = $post -replace "content:", "body:"
    Set-Content $_.FullName $post
    Write-Host "✅ Updated reserved property in $($_.Name)" -ForegroundColor Green
}

# 6. Sanitize reserved keys in layouts
Write-Host "🧹 Sanitizing reserved keys in layouts..." -ForegroundColor Cyan
Get-ChildItem -Path "$repoRoot\src\_layouts" -Filter *.njk -Recurse | ForEach-Object {
    $layout = Get-Content $_.FullName -Raw
    $layout = $layout -replace "{{\s*content\s*}}", "{{ body }}"
    $layout = $layout -replace "{%\s*block content\s*%}", "{% block body %}"
    $layout = $layout -replace "{%\s*endblock content\s*%}", "{% endblock body %}"
    Set-Content $_.FullName $layout
    Write-Host "✅ Updated reserved property references in $($_.Name)" -ForegroundColor Green
}

# 7. Ensure Eleventy wiring
$eleventyFile = "$repoRoot\.eleventy.js"
if (-Not (Test-Path $eleventyFile)) {
    @"
module.exports = function(eleventyConfig) {
  eleventyConfig.setFreezeReservedData(false); // allow reserved keys if needed
  eleventyConfig.addCollection("categories", function(collection) {
    return collection.getAll().reduce((cats, item) => {
      if(item.data.tags) {
        item.data.tags.forEach(tag => {
          if(!cats[tag]) cats[tag] = [];
          cats[tag].push(item);
        });
      }
      return cats;
    }, {});
  });
};
"@ | Set-Content $eleventyFile
    Write-Host "✅ Regenerated .eleventy.js with dynamic categories" -ForegroundColor Green
}

# 8. Run Eleventy build
Write-Host "🚀 Running Eleventy build..." -ForegroundColor Cyan
npx eleventy --serve

Write-Host "🎉 AutoFix complete. Check http://localhost:8080/" -ForegroundColor Green


