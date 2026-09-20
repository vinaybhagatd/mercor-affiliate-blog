#!/usr/bin/env pwsh
<#
<#
<#
<#
<#
<#
<#
.SYNOPSIS
  PreCommitHook.ps1 — Runs validation before allowing commit.

.DESCRIPTION
  Executes two guardrails before commit:
  1. VerifyFrontMatter.ps1 — validates Markdown front matter.
  2. Run-ScriptAnalyzer.ps1 — runs PSScriptAnalyzer with custom settings.
  Commits are blocked if either fails with Error/ParseError.
  Warnings are logged separately to PreCommitReport.txt.
#>

Write-Host "PowerShell profile loaded successfully."
Write-Host "=== PreCommitHook.ps1 started ==="

$repoRoot = "C:\Users\LMTest\promotional\mercor-affiliate-blog"
$logsPath = Join-Path $repoRoot "logs"
$reportFile = Join-Path $logsPath "PreCommitReport.txt"

if (-not (Test-Path $logsPath)) { New-Item -ItemType Directory -Path $logsPath | Out-Null }
"=== Pre-commit run: $(Get-Date) ===" | Out-File -FilePath $reportFile -Encoding UTF8

# --- Front matter validation ---
$validator = Join-Path $repoRoot "scripts\VerifyFrontMatter.ps1"
& $validator
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Front matter validation failed. Commit blocked." -ForegroundColor Red
    exit 1
}

# --- ScriptAnalyzer linting ---
$analyzer = Join-Path $repoRoot "scripts\Run-ScriptAnalyzer.ps1"
if (Test-Path $analyzer) {
    Write-Host "=== Running PSScriptAnalyzer ==="
    $results = & $analyzer
    $errors = $results | Where-Object { $_.Severity -eq "Error" -or $_.Severity -eq "ParseError" }
    $warnings = $results | Where-Object { $_.Severity -eq "Warning" }

    if ($errors.Count -gt 0) {
        Write-Host "❌ ScriptAnalyzer errors detected. Commit blocked." -ForegroundColor Red
        $errors | Out-File -FilePath $reportFile -Encoding UTF8 -Append
        exit 1
    }

    if ($warnings.Count -gt 0) {
        Write-Host "⚠️ ScriptAnalyzer warnings logged." -ForegroundColor Yellow
        $warnings | Out-File -FilePath $reportFile -Encoding UTF8 -Append
    }
}

Write-Host "=== PreCommitHook.ps1 complete ==="
exit 0
#>
}
#>
}
#>
}
#>
}
#>
}
#>
}