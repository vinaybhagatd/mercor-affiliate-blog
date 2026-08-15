#
.SYNOPSIS
    Runs PowerShell ScriptAnalyzer across the repository and enforces failures on warnings/errors.

.DESCRIPTION
    This script installs PSScriptAnalyzer if missing, scans all PowerShell scripts and module definition files, and exits with code 1 if any violations are found. Intended for CI/CD pipelines or local validation.
# | # Ensure PSScriptAnalyzer is available
if (-not (Get-Module -ListAvailable -Name PSScriptAnalyzer)) {
    Write-Output "Installing PSScriptAnalyzer..."
    try {
        Install-Module -Name PSScriptAnalyzer -Force -Scope CurrentUser -ErrorAction Stop
    }
    catch {
        Write-Error "Failed to install PSScriptAnalyzer: $_"
        exit 1
    }
}

Import-Module PSScriptAnalyzer -ErrorAction Stop

# Collect all PowerShell scripts and module definition files
$files = Get-ChildItem -Path . -Recurse -Include *.ps1, *.psd1

if (-not $files) {
    Write-Output "No PowerShell files found to analyze."
    exit 0
}

Write-Output " Running ScriptAnalyzer on $($files.Count) files..."

# Run analyzer (no -Recurse here, since Get-ChildItem already recursed)
$results = Invoke-ScriptAnalyzer -Path $files.FullName -Severity Warning, Error

if ($results) {
    Write-Output " ScriptAnalyzer found issues:"
    $results | Format-Table RuleName, Severity, ScriptName, Line, Message -AutoSize
    exit 1
}
else {
    Write-Output " ScriptAnalyzer passed with no issues."
    exit 0
}

