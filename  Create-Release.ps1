<#
.SYNOPSIS
  Creates a GitHub release with auto-generated notes.
.DESCRIPTION
  - Uses commit metadata for release notes
  - Pulls latest QA summary from QAValidatorReport.txt
  - Publishes release under the provided tag
#>

param(
  [string]$Tag,
  [string]$Repo = "origin"
)

$ErrorActionPreference = "Stop"

Write-Host "=== Create-Release.ps1 started ===" -ForegroundColor Cyan

# --- Step 1: Ensure GITHUB_TOKEN is available ---
if (-not $env:GITHUB_TOKEN) {
    Write-Warning "Missing GITHUB_TOKEN. Please set it before running."
    exit 1
}

# --- Step 2: Collect commit metadata ---
$commitLog = git log -1 --pretty=format:"%h %s (%ci)" | Out-String

# --- Step 3: Pull QA summary ---
$qaSummary = ""
if (Test-Path "QAValidatorReport.txt") {
    $lines = Get-Content "QAValidatorReport.txt"
    $summaryStart = ($lines | Select-String "Summary:").LineNumber
    if ($summaryStart) {
        $qaSummary = ($lines | Select-Object -Skip ($summaryStart - 1) -First 6) -join "`n"
    } else {
        $qaSummary = "No QA summary found."
    }
} else {
    $qaSummary = "QAValidatorReport.txt not found."
}

# --- Step 4: Build release notes ---
$releaseNotes = @"
## Release $Tag

### Commit Metadata
$commitLog

### QA Validation Summary
$qaSummary
"@

# --- Step 5: Create GitHub release ---
Write-Host "Publishing release $Tag..."
gh release create $Tag --notes "$releaseNotes"

Write-Host "=== Create-Release.ps1 complete. Release $Tag published with QA summary. ===" -ForegroundColor Green
