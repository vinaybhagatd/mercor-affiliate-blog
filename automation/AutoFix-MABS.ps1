#!/usr/bin/env pwsh
<#
.SYNOPSIS
  AutoFix.ps1 — Hardened cleanup for parse errors and hygiene.

.DESCRIPTION
  Applies guardrails to all .ps1 scripts in the repo:
 - Normalizes line endings to CRLF.
 - Forces UTF‑8 (no BOM) encoding.
 - Sanitizes hidden characters (zero‑width spaces, BOM markers).
 - Fixes parse errors (closing braces, terminating strings, stray tokens).
 - Enforces operator spacing.
 - Wraps metadata headers in <# … #> blocks (only once, full‑file guard).
- Removes stray pipe characters at script start.
- Skips generated artifacts.
- Runs Invoke‑Formatter for consistent style (with error handling).
Logs all changes and full run output to logs\AutoFixReport.txt.
#>

$repoRoot = "C:\Users\LMTest\promotional\mercor-affiliate-blog"
$logsPath = Join-Path $repoRoot "logs"
$reportFile = Join-Path $logsPath "AutoFixReport.txt"

if (-not (Test-Path $logsPath)) { New-Item -ItemType Directory -Path $logsPath | Out-Null }

Start-Transcript -Path $reportFile -Append
Write-Host "=== AutoFix.ps1 started ===" -ForegroundColor Cyan

# 🔧 Normalize all .ps1 files to CRLF line endings and sanitize hidden chars before processing
Get-ChildItem -Path $repoRoot -Recurse -Filter *.ps1 |
    ForEach-Object {
        $raw = Get-Content $_.FullName -Raw
        $normalized = $raw -replace "`r?`n", "`r`n"
        $sanitized = $normalized -replace '[\u200B-\u200D\uFEFF]', ''  # remove zero-width chars/BOM
        Set-Content -Path $_.FullName -Value $sanitized -Encoding UTF8NoBOM -NoNewline
    }
Write-Host "Normalized line endings and sanitized hidden characters for all scripts" -ForegroundColor Cyan

# Skip generated artifacts
$scripts = Get-ChildItem -Path $repoRoot -Recurse -Filter *.ps1 |
    Where-Object { $_.Name -notin @('QAReport.txt', 'PreCommitReport.txt', 'deploy.yml') }

foreach ($script in $scripts) {
    $content = Get-Content $script.FullName
    $fixed = $false

    # 1. Remove stray pipe at start
    if ($content.Count -gt 0 -and $content[0] -match '^\|') {
        $content[0] = $content[0] -replace '^\|', ''
        $fixed = $true
        Write-Host "Removed stray pipe in $($script.Name)"
    }

    # 2. Fix operator spacing
    for ($i = 0; $i -lt $content.Count; $i++) {
        $content[$i] = $content[$i] -replace '\+\s=', '+='
        $content[$i] = $content[$i] -replace '\s+=', ' ='
        $content[$i] = $content[$i] -replace '\s+-', ' -'
    }

    # 3. Wrap metadata headers (full‑file guard clause)
    if (-not ($content -join "`n" -match '<#')) {
        for ($i = 0; $i -lt $content.Count; $i++) {
            if ($content[$i] -match '^\.(SYNOPSIS|DESCRIPTION)') {
                $content[$i] = "<#`n" + $content[$i]
                $content += "#>"
                $fixed = $true
                Write-Host "Wrapped metadata in $($script.Name)"
                break
            }
        }
    }

    # 4. Fix unterminated strings
    for ($i = 0; $i -lt $content.Count; $i++) {
        if ($content[$i] -match '^[^"]*"[^"]*$') {
            $content[$i] += '"'"
            $fixed = $true
            Write-Host "Closed string in $($script.Name): line $($i + 1)"
        }
    }

    # 5. Add missing closing brace at EOF (safe check)
    if ($content.Count -gt 0) {
        $lastLine = $content[-1].Trim()
        if ($lastLine -notmatch '^\}$' -and $lastLine -notmatch '#>$') {
            $content += ""
        }""
            $fixed = $true
            Write-Host "Added closing brace in $($script.Name)"
        }
    }

    # Save back if changed
    if ($fixed) {
        # Normalize and sanitize before saving
        $normalized = ($content -join "`r`n")
        $sanitized = $normalized -replace '[\u200B-\u200D\uFEFF]', ''
        Set-Content -Path $script.FullName -Value $sanitized -Encoding UTF8NoBOM -NoNewline

        try {
            $raw = Get-Content $script.FullName -Raw
            $raw = $raw -replace "`r?`n","`r`n"
            $formatted = Invoke-Formatter -ScriptDefinition $raw
            Set-Content -Path $script.FullName -Value $formatted -Encoding UTF8NoBOM -NoNewline
            Write-Host "✔ Auto-fixed and formatted $($script.Name)" -ForegroundColor Green
        }
        catch {
            Write-Host "⚠ Skipped formatting for $($script.Name) due to encoding/line issues" -ForegroundColor Yellow
            Add-Content -Path $reportFile -Value "Skipped formatting for $($script.Name) (encoding/line issues)"
        }
    } else {
        Write-Host "No fixes needed in $($script.Name)" -ForegroundColor Yellow
    }
}

Write-Host "=== AutoFix.ps1 complete ===" -ForegroundColor Cyan
Stop-Transcript

        }