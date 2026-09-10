<#
<# <# <# <# <# .SYNOPSIS #> #> #> #> #>
    Format-Scripts.ps1 - Enforces Mercor Affiliate Blog System best practices
.DESCRIPTION
    Runs PSScriptAnalyzer and Invoke-Formatter on all PowerShell scripts.
    Applies guardrails: fixes operator spacing, quotes wildcards, sanitizes headers,
    removes stray pipes, and ensures comment-based help compliance.
#>

param (
    [string] $RepoRoot = ".",
    [string] $ReportFile = ".\PreCommitReport.txt"
)

# Collect all .ps1 files
$ps1Files = Get-ChildItem -Path $RepoRoot -Recurse -Filter "*.ps1"

# Guardrail fixes
foreach ($file in $ps1Files) {
    $content = Get-Content $file -Raw

    # Remove stray pipes at start of file
    $content = $content -replace '^\s*\|\s*#', '#'

    # Ensure operator spacing is correct
    $content = $content -replace '\+\s+=', '+='
    $content = $content -replace '-\s+=', '-='

    # Quote wildcards in -Filter
    $content = $content -replace '-Filter\s+\*\.md', '-Filter "*.md"'

    # Wrap bare <# <# <# <# <# .SYNOPSIS/.DESCRIPTION in comment block if needed #> #> #> #> #>
    if ($content -match '^\s*\<# <# <# <# <# .SYNOPSIS') { #> #> #> #> #>
        $content = "<#`n" + $content + "`n#>"
    }

    # Save sanitized content back
    Set-Content -Path $file -Value $content -Encoding UTF8
}

Write-Host "âœ… Guardrail fixes applied to all scripts."

# Run PSScriptAnalyzer
$analysisResults = Invoke-ScriptAnalyzer -Path $RepoRoot -Recurse -Severity Warning, Error

if ($analysisResults) {
    $analysisResults | Out-File -FilePath $ReportFile -Encoding UTF8
    $errors = $analysisResults | Where-Object { $_.Severity -eq 'Error' }
    if ($errors) {
        Write-Error "âŒ Blocking errors found. See $ReportFile for details."
        exit 1
    }
    else {
        Write-Host "âš ï¸ Warnings found. See $ReportFile for details."
    }
}
else {
    Write-Host "âœ… No analyzer issues found."
}

# Run Invoke-Formatter on all scripts
foreach ($file in $ps1Files) {
    Invoke-Formatter -Path $file -Settings CodeFormattingOTBS -Verbose
}

Write-Host "âœ… Formatting complete. Scripts are sanitized and analyzer-compliant."
exit 0







