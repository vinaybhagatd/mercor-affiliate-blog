#!/usr/bin/env pwsh
<#
Pre‑commit hook: Validate blog front matter and lint PowerShell scripts.
Blocks commits if:
  - Front matter validation fails
  - ScriptAnalyzer finds Error/ParseError issues
Logs warnings separately for hygiene tracking.
#>

Write-Host "=== PreCommitHook.ps1 started ===" -ForegroundColor Cyan

# Paths
$repoRoot    = "C:\Users\LMTest\promotional\mercor-affiliate-blog"
$validator   = Join-Path $repoRoot "VerifyFrontMatter.ps1"
$settingsPath = ".\PSScriptAnalyzerSettings.psd1"
$reportPath   = ".\PreCommitReport.txt"
$excludeFiles = @(".githooks\pre-commit.ps1")

# --- Front Matter Validation ---
& $validator
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Front matter validation failed. Commit blocked." -ForegroundColor Red
    exit 1
}

# --- ScriptAnalyzer Enforcement ---
Write-Host "Running PSScriptAnalyzer on active PowerShell scripts..." -ForegroundColor Cyan

# Errors (blocking)
$errors = Invoke-ScriptAnalyzer -Path . -Recurse -Settings $settingsPath -Severity ParseError,Error |
    Where-Object { $excludeFiles -notcontains $_.ScriptName }

# Warnings (non-blocking, logged)
$warnings = Invoke-ScriptAnalyzer -Path . -Recurse -Settings $settingsPath -Severity Warning |
    Where-Object { $excludeFiles -notcontains $_.ScriptName }

# Log warnings
if ($warnings -and $warnings.Count -gt 0) {
    $warnings | Format-Table RuleName, Severity, ScriptName, Line, Message -AutoSize |
        Out-String | Set-Content $reportPath -Encoding UTF8
    Write-Host "⚠ Warnings logged to $reportPath" -ForegroundColor Yellow
} else {
    "No warnings found." | Set-Content $reportPath -Encoding UTF8
    Write-Host "No warnings found." -ForegroundColor Green
}

# Block commit if errors exist
if ($errors -and $errors.Count -gt 0) {
    $errors | Format-Table RuleName, Severity, ScriptName, Line, Message -AutoSize
    Write-Host "❌ Commit blocked: ScriptAnalyzer found errors." -ForegroundColor Red
    exit 1
}

Write-Host "✅ All validations passed. Commit allowed." -ForegroundColor Green
exit 0
