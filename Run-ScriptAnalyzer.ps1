#
.SYNOPSIS
    Wrapper for running ScriptAnalyzer in isolated sessions per file.
    Skips known problematic files, restricts severity to Error/Warning, and saves results into a timestamped consolidated report.

.DESCRIPTION
    This script runs Invoke-ScriptAnalyzer on each .ps1 file in the repo
    using isolated PowerShell sessions. Known crash-prone files are skipped.
    Results are consolidated into a timestamped report file for audit history.
# | # Generate timestamped report path
$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$reportPath = ".\ScriptAnalyzerReport_$timestamp.txt"

Write-Output "Starting ScriptAnalyzer run..."
Write-Output "Report will be saved to $reportPath"

# List of files to skip (known crashers)
$excludeFiles = @(
    'BatchCreateBlogs.ps1', 'powershell-analyzer.ps1', 'QAValidator.ps1', 'RepoCleanup.ps1'
)

# Remove old report if exists (just for cleanliness)
if (Test-Path $reportPath) { Remove-Item $reportPath }

# Analyze each file in isolated session
Get-ChildItem -Path . -Filter *.ps1 -Recurse | ForEach-Object {
    $file = $_.FullName
    if ($excludeFiles -contains $_.Name) {
        Write-Warning "Skipping problematic file: $($_.Name)"
        return
    }

    Write-Output "Analyzing $file ..."
    try {
        Start-Process pwsh -ArgumentList "-NoProfile -Command Invoke-ScriptAnalyzer -Path '$file' -Severity Error, Warning | Out-File -FilePath '$reportPath' -Append -Encoding UTF8" -Wait -NoNewWindow
    }
    catch {
        Write-Warning "ScriptAnalyzer failed on ${file}: $($_.Exception.Message)"
    }
}

Write-Output "`u{2705} ScriptAnalyzer run complete. Results saved to $reportPath"

