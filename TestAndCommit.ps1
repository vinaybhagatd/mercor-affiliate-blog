<#
.SYNOPSIS
  Run full MABS validation, commit changes, and tag release sequentially.
.DESCRIPTION
  - Executes RunAll-Tests.ps1
  - Consumes structured output object
  - If errors = 0 and LM Studio found, commits changes
  - Automatically increments sequential tag (mabs-v16.x)
#>

$ErrorActionPreference = "Stop"

Write-Host "=== TestAndCommit.ps1 started ===" -ForegroundColor Cyan

# Run full validation and capture structured result
$result = .\RunAll-Tests.ps1 -Verbose

# Debug echo: show captured object
Write-Host "=== DEBUG: Captured result ===" -ForegroundColor Yellow
Write-Host "AnalyzerErrors: $($result.AnalyzerErrors)" -ForegroundColor Gray
Write-Host "LMStudioFound: $($result.LMStudioFound)" -ForegroundColor Gray
Write-Host "=== END DEBUG ===" -ForegroundColor Yellow

# Validation check
if ($result.AnalyzerErrors -eq 0 -and $result.LMStudioFound -eq $true) {
    Write-Host "✅ Validation passed. Staging and committing..." -ForegroundColor Green

    git add .eleventy.js .gitattributes .github/workflows/ci.yml .github/workflows/nightly.yml README.md RunAll-Tests.ps1 QAValidatorReport.txt TestAndCommit.ps1
    git commit -m "Validated MABS update: CI + nightly workflow + README + Eleventy config"

    git push origin main
    if ($LASTEXITCODE -eq 0) {
        # Sequential tag logic
        $latestTag = git tag --list "mabs-v16.*" | Sort-Object | Select-Object -Last 1
        if ($latestTag) {
            $parts = $latestTag -split "\."
            $version = [int]$parts[-1] + 1
        } else {
            $version = 1
        }
        $tagName = "mabs-v16.$version"

        git tag -a $tagName -m "Release ${tagName}: Validated commit checkpoint"
        git push origin $tagName

        Write-Host "🎉 Commit and tag complete. Release checkpoint: $tagName" -ForegroundColor Cyan
    } else {
        Write-Host "❌ Git push failed. Please check SSH keys or remote access." -ForegroundColor Red
    }
} else {
    Write-Host "❌ Validation failed. Commit aborted." -ForegroundColor Red
}
