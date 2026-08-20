<#
.SYNOPSIS
CreateBlog.ps1
Generates a single blog post in HTML format for a given category and title,
fills placeholder instructions with generated content from Qwen Coder via LM Studio.
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$Category,

    [Parameter(Mandatory=$true)]
    [string]$Title,

    [string]$OutputDirectory = ".\blogs",

    [ValidateSet("GA4","Plausible")]
    [string]$AnalyticsProvider = "GA4"   # Default to GA4
)

# --- Function to call LM Studio CLI ---
function Generate-SectionContent {
    param([string]$Instruction)

    $lmStudioPath = "C:\Users\LMTest\.lmstudio\bin\lms.exe"
    $model = "md-coder-qwen3-8b"

    $result = & $lmStudioPath chat $model -p $Instruction
    return $result
}

# Ensure output directory exists
if (-not (Test-Path $OutputDirectory)) {
    New-Item -ItemType Directory -Path $OutputDirectory | Out-Null
}

# Build filename (HTML)
$filename = Join-Path $OutputDirectory "$Category-blogs.html"

# Select analytics script
switch ($AnalyticsProvider) {
    "GA4" {
        $analyticsScript = @"
<!-- Google Analytics 4 -->
<script async src="https://www.googletagmanager.com/gtag/js?id=G-XXXXXXX"></script>
<script>
  window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}
  gtag('js', new Date());
  gtag('config', 'G-XXXXXXX');
</script>
"@
    }
    "Plausible" {
        $analyticsScript = @"
<!-- Plausible Analytics -->
<script defer data-domain="mercor-affiliate-blog.com" src="https://plausible.io/js/plausible.js"></script>
"@
    }
}

# --- Generate content for each section ---
$personaContent = Generate-SectionContent -Instruction "Write a 200-word Persona & Context story about a remote $Category professional, their challenges, and aspirations."
$dayContent     = Generate-SectionContent -Instruction "Generate a 150-word 'Day in the Life' narrative for a remote $Category professional, focusing on workflows, meetings, and productivity strategies."
$toolsContent   = Generate-SectionContent -Instruction "List and describe 3 top productivity tools used by remote $Category professionals, with practical examples."
$skillsContent  = Generate-SectionContent -Instruction "Provide a list of 3 essential skills for remote $Category professionals, with one-sentence explanations each."
$salaryContent  = Generate-SectionContent -Instruction "Give realistic salary ranges for remote $Category professionals at entry, mid, and senior levels."
$growthContent  = Generate-SectionContent -Instruction "Write a 150-word growth path narrative showing how a remote $Category professional advances in their career, including challenges and takeaways."

# --- Build HTML content ---
$htmlContent = @"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>$Title</title>
    <meta name="canonical" content="https://mercor-affiliate-blog.com/$Category/future-remote-careers">
    <meta name="category" content="$Category">
    <meta name="thumbnail" content="C:\Users\LMTest\promotional\mercor-affiliate-blog\assets\images\thumbnails\$Category.png">
    $analyticsScript
</head>
<body>
    <h1>$Title</h1>

    <h2>🎨 Persona & Context</h2>
    <p>$personaContent</p>

    <h2>📅 Day in the Life</h2>
    <p>$dayContent</p>

    <h2>🛠 Tools Used</h2>
    <p>$toolsContent</p>

    <h2>🧩 Skills Required</h2>
    <p>$skillsContent</p>

    <h2>💰 Salary Range</h2>
    <p>$salaryContent</p>

    <h2>📈 Growth Path</h2>
    <p>$growthContent</p>

    <h2>📩 Lead Magnet CTA</h2>
    <p><strong>Download our Free $Category Career Guide:</strong></p>
    <form action="https://example.com/subscribe" method="post">
      <input type="email" name="email" placeholder="Enter your email" required>
      <button type="submit">Get the Guide</button>
    </form>

    <h2>🔗 Recommended Resources</h2>
    <ul>
        <li><a href="https://example.com/product4?affid=123">Affiliate Resource 1</a></li>
        <li><a href="https://example.com/product5?affid=123">Affiliate Resource 2</a></li>
    </ul>

    <h2>⚖️ Disclosure</h2>
    <p>Some of the links in this post are affiliate links. If you click and purchase, we may earn a commission at no extra cost to you. We only recommend products we trust and use ourselves.</p>
</body>
</html>
"@

# Write HTML file
Set-Content -Path $filename -Value $htmlContent -Encoding UTF8

Write-Host "✅ Blog created with generated content: $filename"
