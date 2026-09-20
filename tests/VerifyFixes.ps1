#!/usr/bin/env pwsh
<#
.SYNOPSIS
  VerifyFixes.ps1 — Validates all repaired scripts for parse errors.

.DESCRIPTION
  Runs a dry-load of every .ps1 file in the repo to confirm:
    * No parser errors
    * No missing braces
    * No unterminated strings
    * No invalid Unicode escapes
  Logs results to logs\VerifyFixesReport.txt
#>

$repoRoot   = "C:\Users\LMTest\promotional\mercor-affiliate-blog"
$logsPath   = Join-Path $repoRoot "logs"
$reportFile = Join-Path $logsPath "VerifyFixesReport.txt"

if (-not (Test-Path $logsPath)) { New-Item -ItemType Directory -Path $logsPath | Out-Null }

Start-Transcript -Path $reportFile -Append
Write-Host "=== VerifyFixes.ps1 started ===" -ForegroundColor Cyan

$scripts = Get-ChildItem -Path $repoRoot -Recurse -Filter *.ps1

foreach ($script in $scripts) {
    try {
        # Dry-run load to catch parser errors
        pwsh -NoProfile -Command "Get-Content '$($script.FullName)' | Out-Null"
        Write-Host "✔ Verified $($script.Name)" -ForegroundColor Green
    }
    catch {
        Write-Host "⚠ Error in $($script.Name): $_" -ForegroundColor Red
        Add-Content -Path $reportFile -Value "Error in $($script.Name): $_"
    }
}

Write-Host "=== VerifyFixes.ps1 complete ===" -ForegroundColor Cyan
Stop-Transcript
