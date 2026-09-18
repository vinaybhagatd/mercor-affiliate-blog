<#
.SYNOPSIS
  Fills generated blog skeletons with complete body sections.
.DESCRIPTION
  Iterates through blog files in src/posts and injects Persona, Tools, Skills, CTA, and Disclosure sections.
#>

$projectRoot = "C:\Users\LMTest\promotional\mercor-affiliate-blog"
$postsPath   = Join-Path $projectRoot "src\posts"

Write-Host "Filling blog content in $postsPath..."

# Ensure posts folder exists
if (-not (Test-Path $postsPath)) {
    Write-Host "❌ Posts folder not found: $postsPath"
    exit
}

# Process each blog file
Get-ChildItem -Path $postsPath -Include *.md, *.html -Recurse | ForEach-Object {
    $file = $_.FullName
    $content = Get-Content $file -Raw

    # Extract category from filename
    $category = $_.BaseName -replace "-blogs",""

    # Build filler content
    $filler = @"
<section>
  <h2>Persona & Context</h2>
  <p>This blog is written for professionals exploring opportunities in $category. It sets the context and audience clearly.</p>
</section>

<section>
  <h2>Tools Used</h2>
  <ul>
    <li>Key tools relevant to $category workflows</li>
    <li>Automation and productivity enhancers</li>
    <li>Recommended platforms for beginners</li>
  </ul>
</section>

<section>
  <h2>Skills Required</h2>
  <ul>
    <li>Core skills essential for $category careers</li>
    <li>Soft skills that improve collaboration</li>
    <li>Continuous learning and adaptability</li>
  </ul>
</section>

<section>
  <h2>Lead Magnet CTA</h2>
  <p>Download our free guide to succeed in $category careers. Sign up to access exclusive resources.</p>
</section>

<footer>
  <p>⚖️ Disclosure: Some links may be affiliate links. We only recommend products we trust.</p>
</footer>
"@

    # Replace placeholder or append filler
    if ($content -match "<section>") {
        # Already has sections, skip
        Write-Host "ℹ️ $($_.Name) already contains sections."
    } else {
        $updated = $content + "`n" + $filler
        $updated | Set-Content $file -Encoding UTF8
        Write-Host "✅ Filled content for $($_.Name)"
    }
}

Write-Host "Content filling complete."
