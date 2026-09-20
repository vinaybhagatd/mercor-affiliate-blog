#!/usr/bin/env pwsh
<#
<#
<#
<#
<#
<#
<#
.SYNOPSIS
  Stabilize-MABS.ps1 — Stabilization pipeline for Mercor Affiliate Blog System.

.DESCRIPTION
  Runs front matter fixer + validator, sanity check, PowerShell linting, and auto-formatting.
  Blocks stabilization if errors are found or if sanity check fails.
  Logs warnings separately for hygiene. Applies guardrails from mabs-v16.8.

.PATH
  Script location: C:\Users\LMTest\promotional\mercor-affiliate-blog\Stabilize-MABS.ps1
#>

Write-Host "=== Stabilize-MABS.ps1 started ===" -ForegroundColor Cyan

# Paths
$repoRoot = "C:\Users\LMTest\promotional\mercor-affiliate-blog"
$blogPath = Join-Path $repoRoot "src\posts"
$fixer = Join-Path $repoRoot "FixFrontMatter.ps1"
$validator = Join-Path $repoRoot "VerifyFrontMatter.ps1"
$settingsPath = Join-Path $repoRoot "PSScriptAnalyzerSettings.psd1"
$reportPath = Join-Path $repoRoot "QAValidatorReport.txt"
$excludeFiles = @("Stabilize-MABS.ps1")

# --- Step 1: Run FixFrontMatter.ps1 ---
Write-Host "Running FixFrontMatter.ps1..." -ForegroundColor Cyan
& $fixer

# --- Step 2: Run VerifyFrontMatter.ps1 ---
Write-Host "Validating blog front matter..." -ForegroundColor Cyan
& $validator

# --- Step 3: Sanity Check (tags must include category) ---
Write-Host "Running sanity check..." -ForegroundColor Cyan
$sanityFail = $false
Get-ChildItem -Path $blogPath -Recurse -Filter *.md | ForEach-Object {
    $file = $_.FullName
    $content = Get-Content $file -Raw
    if ($content -match "(?s)^---(.*?)---") {
        $yamlBlock = $matches[1]
        $categoryMatch = [regex]::Match($yamlBlock, "category:\s*(\w+)", [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
        $tagsMatch = [regex]::Match($yamlBlock, "tags:\s*"

\[(.*?)\]

", [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)"

        if ($categoryMatch.Success -and $tagsMatch.Success) {
            $categoryNorm = $categoryMatch.Groups[1].Value.Trim().ToLower()
            $tagsNorm = $tagsMatch.Groups[1].Value.Split(',') | ForEach-Object { $_.Trim().ToLower() }

            if ($tagsNorm -contains $categoryNorm) {
                Write-Host "✅ $($_.Name) passes sanity check" -ForegroundColor Green
            }
            else {
                Write-Host "❌ $($_.Name) fails sanity check (tags missing category)" -ForegroundColor Red
                $sanityFail = $true
            }
        }
        else {
            Write-Host "❌ Missing category or tags in $($_.Name)" -ForegroundColor Red
            $sanityFail = $true
        }
    }
}
if ($sanityFail) {
    Write-Host "❌ Sanity check failed. Stabilization blocked." -ForegroundColor Red
    exit 1
}

# --- Step 4: ScriptAnalyzer Enforcement ---
Write-Host "Running PSScriptAnalyzer..." -ForegroundColor Cyan

$errors = Invoke-ScriptAnalyzer -Path $repoRoot -Recurse -Settings $settingsPath -Severity ParseError,Error |
    Where-Object { $excludeFiles -notcontains $_.ScriptName }

$warnings = Invoke-ScriptAnalyzer -Path $repoRoot -Recurse -Settings $settingsPath -Severity Warning |
    Where-Object { $excludeFiles -notcontains $_.ScriptName }

if ($warnings -and $warnings.Count -gt 0) {
    $warnings | Format-Table RuleName, Severity, ScriptName, Line, Message -AutoSize |
        Out-String | Set-Content $reportPath -Encoding UTF8
    Write-Host "⚠ Warnings logged to $reportPath" -ForegroundColor Yellow
} else {
    "No warnings found." | Set-Content $reportPath -Encoding UTF8
    Write-Host "No warnings found." -ForegroundColor Green
}

if ($errors -and $errors.Count -gt 0) {
    $errors | Format-Table RuleName, Severity, ScriptName, Line, Message -AutoSize
    Write-Host "❌ Stabilization blocked: ScriptAnalyzer found errors." -ForegroundColor Red
    exit 1
}

# --- Step 5: Auto-Formatting ---
Write-Host "Auto-formatting PowerShell scripts..." -ForegroundColor Cyan
Get-ChildItem -Path $repoRoot -Recurse -Filter *.ps1 | ForEach-Object {
    Write-Host "Formatting $($_.FullName)..."
    Invoke-Formatter -ScriptDefinition (Get-Content $_.FullName -Raw) |
        Set-Content $_.FullName -Encoding UTF8
}

# --- Step 6: Artifact Hygiene ---
Write-Host "Cleaning generated artifacts..." -ForegroundColor Cyan
$artifacts = @("QAValidatorReport.txt","PreCommitReport.txt","CleanupReport.txt","deploy.yml")
foreach ($artifact in $artifacts) {
    $artifactPath = Join-Path $repoRoot $artifact
    if (Test-Path $artifactPath) {
        Remove-Item $artifactPath -Force
        Write-Host "Removed $artifactPath" -ForegroundColor DarkGray
    }
}

Write-Host "✅ Stabilization complete. All guardrails passed." -ForegroundColor Green
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