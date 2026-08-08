param(
    [string]$ProjectDir = "C:\Users\LMTest\promotional\mercor-affiliate-blog",
    [string]$LogDir     = "C:\Users\LMTest\promotional\mercor-affiliate-blog\hermes-logs"
)

# Ensure log directory exists
if (-not (Test-Path $LogDir)) {
    New-Item -ItemType Directory -Path $LogDir | Out-Null
}

# Collect all .ps1 files in the project folder
$ps1Files = Get-ChildItem -Path $ProjectDir -Filter "*.ps1" -Recurse

# Build prompt with issues, Hermes analysis, and script snippets
$issuesPrompt = @"
You are an expert PowerShell coder with 10+ years of experience.
Analyze and fix issues in the Mercor Affiliate Blog system.

### Outputs Preparation:
Please provide actual script snippets so I can further refine the corrections based on exact logic and flows within those scripts. For each script identified, the corrections aim to address specific issues such as handling paths with spaces or aligning with specific project requirements like Eleventy v2.0.1 compatibility, along with a consistent approach to error handling and logging.

=== Known Issues & Hermes Analysis Report ===
Diagnostics.ps1:
- Missing subscripts detection logic fails when paths are relative.
- Error handling inconsistent (Write-Error vs Write-Output).
- Parallel execution not awaited; jobs terminate early.
- Diff generation incomplete when file count > 20.

CreateBlog1.ps1:
- Category logic incorrect: "arts" and "services" still generated.
- Metadata missing canonical URLs.
- Markdown conversion inconsistent.
- ConvertTo-Json depth not set → truncated config.

Orchestrator.ps1:
- Config subscripts fail with spaces in path.
- Deadlocks due to improper Start-Job usage.
- Summary skips failed jobs.
- Regression: missing absolute folder paths.

QAValidator.ps1:
- Validation rules incomplete (duplicate slugs not caught).
- Regex too permissive.
- Error reporting inconsistent.
- Regression: missing SEO metadata detection.

MercorDebug.ps1:
- Debug logs not timestamped.
- Verbose mode ignored.
- Pipeline variables not cleared.
- Regression: failed subscripts not captured.

MercorDebugLoader.ps1:
- Loader fails with hyphenated paths.
- Import-Module errors not handled.
- Regression: cached modules not reloaded.
- Logging inconsistent.

Other Scripts (general):
- Inconsistent Set-Location vs absolute paths.
- No standardized logging.
- Retry logic missing in Invoke-RestMethod/WebRequest.
- Ad-hoc error handling.
- GitHub Actions integration fails on non-zero exit codes.

=== Script Snippets ===
"@"

foreach ($file in $ps1Files) {
    $content = Get-Content $file.FullName -Raw
    $issuesPrompt += "`n=== $($file.Name) ===`n$content`n"
}

# Timestamped log file
$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$logFile   = Join-Path $LogDir "hermes-$timestamp.log"

# Send to Hermes
$response = Send-OllamaRequest -Prompt $issuesPrompt
$response | Out-File -FilePath $logFile -Encoding UTF8

Write-Output "Hermes response saved to $logFile"

# Summary status
if ($OpenSummary) {
    Write-Host "Summary output will be displayed..."
}

# Validate monetization hooks
$blogPath = Join-Path $LogDir "$category-blogs.md"
if (Test-Path $blogPath) {
    $blogContent = Get-Content -Path $blogPath -Raw
    if ($blogContent -match 'AFFILIATE_LINK_PLACEHOLDER' -and 
        $blogContent -match 'EMAIL_CAPTURE_PLACEHOLDER' -and 
        $blogContent -match 'Disclosure') {
        Write-Host "Blog is monetization-ready."
    } else {
        Write-Error "Monetization hooks missing in blog: `n`$blogPath"
        # Auto-fix: Add placeholders and disclosure
        $fixedContent = @"
## ${category} Blog

### Solution & Takeaways
`AFFILIATE_LINK_PLACEHOLDER`

### Call to Action
📌 **Free Resource:** [Download our UX Case Study Template](EMAIL_CAPTURE_PLACEHOLDER)

### Disclosure
Disclosure: Some of the links in this post are affiliate links. This means if you click and purchase, we may earn a commission at no extra cost to you. We only recommend products we trust and use ourselves.

### Conclusion
"
        Set-Content -Path $blogPath -Value $fixedContent -Encoding UTF8
        Write-Host "Blog updated with monetization hooks."
    }
} else {
    Write-Error "No blog file found: `n`$blogPath"
}
