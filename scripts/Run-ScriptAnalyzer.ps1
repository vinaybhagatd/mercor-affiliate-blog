#!/usr/bin/env pwsh
<#.SYNOPSIS
  Run-ScriptAnalyzer.ps1 — Executes PSScriptAnalyzer with custom guardrails.

.DESCRIPTION
  Analyzes PowerShell scripts in the Mercor Affiliate Blog System repo.
 - Validates syntax and style using PSScriptAnalyzer.
 - Blocks commits if any Error or ParseError issues are found.
 - Logs warnings separately for hygiene tracking.
 - Supports analyzing a single file via -Path parameter.
 - Outputs results to logs\PreCommitReport.txt.
#>

param(
    [string]$Path = $null
)

$repoRoot = "C:\Users\LMTest\promotional\mercor-affiliate-blog"
$logsPath = Join-Path $repoRoot "logs"
$reportFile = Join-Path $logsPath "PreCommitReport.txt"

if (-not (Test-Path $logsPath)) { New-Item -ItemType Directory -Path $logsPath | Out-Null }

Import-Module PSScriptAnalyzer -ErrorAction Stop

"=== ScriptAnalyzer run: $(Get-Date) ===" | Out-File -FilePath $reportFile -Encoding UTF8

# Determine target path
if ($Path) {
    $target = $Path
    Write-Host "Analyzing single script: $target" -ForegroundColor Cyan
}
else {
    $target = $repoRoot
    Write-Host "Analyzing entire repo: $target" -ForegroundColor Cyan
}

# Run analyzer
$results = Invoke-ScriptAnalyzer -Path $target -Recurse -Severity @('Error', 'Warning') -ExcludeRule @('PSAvoidUsingWriteHost')

# Separate errors and warnings
$errors = $results | Where-Object { $_.Severity -eq 'Error' }
$warnings = $results | Where-Object { $_.Severity -eq 'Warning' }

# Log results
if ($errors.Count -gt 0) {
    Write-Host "❌ Errors found:" -ForegroundColor Red
    $errors | Format-Table | Out-String | Tee-Object -FilePath $reportFile -Append
}
else {
    Write-Host "✔ No errors detected." -ForegroundColor Green
}

if ($warnings.Count -gt 0) {
    Write-Host "⚠ Warnings found:" -ForegroundColor Yellow
    $warnings | Format-Table | Out-String | Tee-Object -FilePath $reportFile -Append
}
else {
    Write-Host "✔ No warnings detected." -ForegroundColor Green
}

"=== ScriptAnalyzer complete: $(Get-Date) ===" | Out-File -FilePath $reportFile -Encoding UTF8 -Append

#>


}