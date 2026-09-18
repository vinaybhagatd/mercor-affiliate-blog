# Run-ScriptAnalyzer.ps1

# Enable ScriptAnalyzer with error-only blocking
try {
    $analysis = Invoke-ScriptAnalyzer -Path . -Recurse -Settings ".\PSScriptAnalyzerSettings.psd1"
    $errors = $analysis | Where-Object { $_.Severity -eq "Error" }

    if ($errors.Count -gt 0) {
        Write-Output "❌ ScriptAnalyzer blocking errors detected:"
        $errors | ForEach-Object { Write-Output " - $($_.RuleName) in $($_.ScriptName)" }
    }
} catch {
    Write-Output "⚠️ Could not run script analyzer: $_"
}
