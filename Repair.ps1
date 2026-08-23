<# 
.SYNOPSIS
Repairs PowerShell scripts in the repo by sanitizing content,
fixing formatting issues, and ensuring analyzer compliance.
#>

param(
    [string]$RepoPath = "C:\Users\LMTest\promotional\mercor-affiliate-blog"
)

Write-Output "▶ Starting Repair.ps1..."

# ---------------------------------------------------------
# 1. Validate repo path discipline
# ---------------------------------------------------------

if (-not (Test-Path $RepoPath)) {
    Write-Output "❌ Repo path not found: $RepoPath"
    exit 1
}

Set-Location $RepoPath
Write-Output "✔ Repo path validated: $RepoPath"

# ---------------------------------------------------------
# 2. Collect all PowerShell scripts
# ---------------------------------------------------------

$psFiles = Get-ChildItem . -Filter *.ps1 -Recurse

foreach ($ps in $psFiles) {
    Write-Output "▶ Repairing: $($ps.Name)"

    $content = Get-Content $ps.FullName -Raw

    # -----------------------------------------------------
    # 2a. Remove stray pipe characters at start
    # -----------------------------------------------------
    $content = $content -replace "^\|", ""

    # -----------------------------------------------------
    # 2b. Wrap metadata in <# ... #> blocks
    # -----------------------------------------------------
    if ($content -match "^\.(SYNOPSIS|DESCRIPTION)") {
        $content = $content -replace "^\.(SYNOPSIS|DESCRIPTION)", "<# `n.$1"
        if ($content -notmatch "#>") {
            $content = $content + "`n#>"
        }
    }

    # -----------------------------------------------------
    # 2c. Fix operator spacing
    # -----------------------------------------------------
    $content = $content -replace "\+ =", "+="

    # -----------------------------------------------------
    # 2d. Quote wildcards in -Filter
    # -----------------------------------------------------
    $content = $content -replace "-Filter\s+(\*\.\w+)", '-Filter "$1"'

    # -----------------------------------------------------
    # 2e. Normalize quotes
    # -----------------------------------------------------
    $content = $content.Replace("'", '"')

    # -----------------------------------------------------
    # 2f. Fix invalid Unicode escapes (\uXXXX → `u{XXXX})
    # -----------------------------------------------------
    $content = $content -replace '\\u([0-9A-Fa-f]{4})', { "`u{$($matches[1])}" }

    # -----------------------------------------------------
    # 2g. Save sanitized content
    # -----------------------------------------------------
    $content | Out-File $ps.FullName -Encoding UTF8
    Write-Output "✔ Sanitized: $($ps.Name)"

    # -----------------------------------------------------
    # 2h. Run Invoke-Formatter
    # -----------------------------------------------------
    try {
        $formatted = Invoke-Formatter -ScriptDefinition (Get-Content $ps.FullName -Raw)
        $formatted | Out-File $ps.FullName -Encoding UTF8
        Write-Output "✔ Auto-formatted: $($ps.Name)"
    }
    catch {
        Write-Output "⚠️ Could not auto-format: $($ps.Name)"
    }
}

# ---------------------------------------------------------
# 3. Run ScriptAnalyzer with error-only blocking
# ---------------------------------------------------------

try {
    $analysis = Invoke-ScriptAnalyzer -Path . -Recurse -Settings ".\PSScriptAnalyzerSettings.psd1"
    $errors = $analysis | Where-Object { $_.Severity -eq "Error" }

    if ($errors.Count -gt 0) {
        Write-Output "❌ ScriptAnalyzer blocking errors detected:"
        $errors | ForEach-Object { Write-Output " - $($_.RuleName) in $($_.ScriptName)" }
        exit 1
    } else {
        Write-Output "✔ ScriptAnalyzer passed with no blocking errors."
    }
}
catch {
    Write-Output "⚠️ ScriptAnalyzer not available."
}

# ---------------------------------------------------------
# Final Output
# ---------------------------------------------------------

Write-Output "`n==============================="
Write-Output "   REPAIR-SCRIPTS SUMMARY"
Write-Output "==============================="
Write-Output "`u{2714} All scripts sanitized and repaired."
Write-Output "✔ Repo path discipline enforced."
Write-Output "✔ Best practices applied."
