#!/usr/bin/env pwsh
<#
Pre‑commit hook: Run PSScriptAnalyzer with custom settings.
Blocks commits only on Error severity.
Logs warnings separately to PreCommitReport.txt for hygiene tracking.
#>

Write-Output "Running PSScriptAnalyzer on active PowerShell scripts..."

$settingsPath = ".\PSScriptAnalyzerSettings.psd1"
$reportPath = ".\PreCommitReport.txt"

# Exclude the hook itself from analysis
$excludeFiles = @(".githooks\pre-commit.ps1")

# Run analyzer for Errors only (blocking)
$errors = Invoke-ScriptAnalyzer -Path . -Recurse -Settings .\PSScriptAnalyzerSettings.psd1 -Severity Error |
Where-Object { $_.ScriptName -ne 'pre-commit.ps1' }

# Run analyzer for Warnings (non‑blocking, logged)
$warnings = Invoke-ScriptAnalyzer -Path . -Recurse -Settings $settingsPath -Severity Warning |
Where-Object { $excludeFiles -notcontains $_.ScriptName }

# Log warnings to report file
if ($warnings -and $warnings.Count -gt 0) {
    $warnings | Format-Table RuleName, Severity, ScriptName, Line, Message -AutoSize |
    Out-String | Set-Content $reportPath -Encoding UTF8
    Write-Output "Warnings logged to $reportPath"
}
else {
    "No warnings found." | Set-Content $reportPath -Encoding UTF8
    Write-Output "No warnings found."
}

# Block commit if errors exist
if ($errors -and $errors.Count -gt 0) {
    $errors | Format-Table RuleName, Severity, ScriptName, Line, Message -AutoSize
    Write-Output "❌ Commit blocked: ScriptAnalyzer found errors."
    exit 1
}

Write-Output "✅ No blocking errors found. Commit allowed."
exit 0
