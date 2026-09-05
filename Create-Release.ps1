param(
    [string]$RepoOwner = "vinaybhagatd",
    [string]$RepoName  = "mercor-affiliate-blog",
    [string]$TagName   = "",
    [string]$GitHubToken = $env:GITHUB_TOKEN
)

if (-not $TagName) {
    $TagName = git describe --tags --abbrev=0
}

$CommitHash    = git rev-parse HEAD
$CommitMessage = git log -1 --pretty=%B
$CommitDate    = git log -1 --date=short --pretty=%cd

# Use plain ASCII multi-line string
$ReleaseNotes = @"
Release Notes – MABS $TagName

Summary
-------
Stable milestone for Mercor Affiliate Blog System.
Canonical 11 categories enforced, layouts regenerated, QAValidator integrated.

Included Updates
----------------
- .eleventy.js (slug whitelist + date filter)
- base.njk, post.njk, category.njk layouts
- index.njk and categories/index.njk
- Starter styles.css
- QAValidator.ps1

Guardrails Implemented
----------------------
- Only 11 canonical categories allowed
- QAValidator blocks invalid tags
- Luxon date filter for clean formatting
- Deterministic folder paths and automation scripts

Validation Status
-----------------
- Eleventy build passes
- QAValidator returns only approved categories
- _site renders with styled layouts

Rollback Instructions
---------------------
git checkout $TagName
git reset --hard $TagName

Release Metadata
----------------
- Tag: $TagName
- Date: $CommitDate
- Commit: $CommitHash
- Message: $CommitMessage
- Maintainer: Vinay
"@

$Headers = @{
    Authorization = "token $GitHubToken"
    Accept        = "application/vnd.github+json"
}

$Body = @{
    tag_name   = $TagName
    name       = "MABS $TagName"
    body       = $ReleaseNotes
    draft      = $false
    prerelease = $false
} | ConvertTo-Json -Depth 5

Invoke-RestMethod -Uri "https://api.github.com/repos/$RepoOwner/$RepoName/releases" `
    -Method Post -Headers $Headers -Body $Body

Write-Host "Release $TagName created successfully."

