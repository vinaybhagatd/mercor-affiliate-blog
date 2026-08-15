<#
.SYNOPSIS
    Wrapper to run ScriptAnalyzer and then auto-format scripts.
.DESCRIPTION
    - Runs ScriptAnalyzer in isolated sessions per file.
    - Skips known crash-prone files.
    - Restricts severity to Error/Warning.
    - Produces timestamped analyzer report.
    - Automatically runs Invoke-Formatter across all scripts.
    - Produces timestamped formatter report.
#>

# Generate timestamped report paths
$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$analyzerReport = ".\ScriptAnalyzerReport_$timestamp.txt"
$formatterReport = ".\FormatterReport_$timestamp.txt"

Write-Host "Starting ScriptAnalyzer run..."
Write-Host "Analyzer report will be saved to $analyzerReport"

# List of files to skip (known crashers)
$excludeFiles = @(
    'BatchCreateBlogs.ps1',
    'powershell-analyzer.ps1',
    'QAValidator.ps1',
    'RepoCleanup.ps1'
)

# Remove old reports if exist
if (Test-Path $analyzerReport) { Remove-Item $analyzerReport }
if (Test-Path $formatterReport) { Remove-Item $formatterReport }

# --- Step 1: Run ScriptAnalyzer ---
Get-ChildItem -Path . -Filter *.ps1 -Recurse | ForEach-Object {
    $file = $_.FullName
    if ($excludeFiles -contains $_.Name) {
        Write-Warning "Skipping problematic file: $($_.Name)"
        return
    }

    Write-Host "Analyzing $file ..."
    try {
        Start-Process pwsh -ArgumentList "-NoProfile -Command Invoke-ScriptAnalyzer -Path '$file' -Severity Error,Warning | Out-File -FilePath '$analyzerReport' -Append -Encoding UTF8" -Wait -NoNewWindow
    }
    catch {
        Write-Warning "ScriptAnalyzer failed on ${file}: $($_.Exception.Message)"
    }
}

Write-Host "? ScriptAnalyzer run complete. Results saved to $analyzerReport"

# --- Step 2: Run Invoke-Formatter ---
Write-Host "Starting auto-formatting of scripts..."
Get-ChildItem -Path . -Filter *.ps1 -Recurse | ForEach-Object {
    $file = $_.FullName
    try {
        $content = Get-Content $file -Raw
        $formatted = Invoke-Formatter -ScriptDefinition $content -Settings CodeFormatting
        Set-Content -Path $file -Value $formatted -Encoding UTF8
        Add-Content -Path $formatterReport -Value "Formatted $file"
        Write-Host "Formatted $file"
    }
    catch {
        Write-Warning "Formatter failed on ${file}: $($_.Exception.Message)"
    }
}

Write-Host "? Formatting complete. Report saved to $formatterReport"
