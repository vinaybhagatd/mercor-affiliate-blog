#!/usr/bin/env pwsh
<#
<#
<#
<#
<#
<#
<#
.SYNOPSIS
  Verify-Stabilize.ps1 — Post-run verification for StabilizeAgent.

.DESCRIPTION
  Checks front matter validity, analyzer results, tag duplication, and cleanup state
  after StabilizeAgent execution. Designed for Mercor Affiliate Blog System (MABS).
.PATH
  Script location: C:\Users\LMTest\promotional\mercor-affiliate-blog\scripts\Verify-Stabilize.ps1
#>

Write-Host "=== Verify-Stabilize.ps1 started ===" -ForegroundColor Cyan

$repoRoot = "C:\Users\LMTest\promotional\mercor-affiliate-blog"
$postsPath = Join-Path $repoRoot "src\posts"
$logsPath = Join-Path $repoRoot "logs"
$settings = Join-Path $repoRoot "config\PSScriptAnalyzerSettings.psd1"

# --- Step 1: Front Matter Sanity Check ---
Write-Host "Checking front matter integrity..." -ForegroundColor Cyan
$sanityFail = $false
Get-ChildItem -Path $postsPath -Recurse -Filter *.md | ForEach-Object {
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
            if (-not ($tagsNorm -contains $categoryNorm)) {
                Write-Host "❌ $($_.Name) tags missing category" -ForegroundColor Red
                $sanityFail = $true
            }
        } else {
            Write-Host "❌ Missing category or tags in $($_.Name)" -ForegroundColor Red
            $sanityFail = $true
        }
    }
}
if (-not $sanityFail) {
    Write-Host "✅ All posts pass front matter sanity check" -ForegroundColor Green
}

# --- Step 2: ScriptAnalyzer Enforcement ---
Write-Host "Running PSScriptAnalyzer..." -ForegroundColor Cyan
$errors = Invoke-ScriptAnalyzer -Path $repoRoot -Recurse -Settings $settings -Severity ParseError,Error
if ($errors.Count -gt 0) {
    Write-Host "❌ ScriptAnalyzer found errors:" -ForegroundColor Red
    $errors | Format-Table RuleName, Severity, ScriptName, Line, Message -AutoSize
} else {
    Write-Host "✅ No ScriptAnalyzer errors found" -ForegroundColor Green
}

# --- Step 3: Git Tag Duplication Check ---
Write-Host "Checking Git tags..." -ForegroundColor Cyan
try {
    $tags = git -C $repoRoot tag
    $dupTags = $tags | Group-Object | Where-Object { $_.Count -gt 1 }
    if ($dupTags) {
        Write-Host "❌ Duplicate Git tags detected:" -ForegroundColor Red
        $dupTags | ForEach-Object { Write-Host $_.Name }
    } else {
        Write-Host "✅ No duplicate Git tags" -ForegroundColor Green
    }
} catch {
    Write-Host "⚠ Git not available or repo not initialized" -ForegroundColor Yellow
}

# --- Step 4: Cleanup State ---
Write-Host "Checking logs and artifacts..." -ForegroundColor Cyan
$artifacts = @("QAValidatorReport.txt","PreCommitReport.txt","CleanupReport.txt","deploy.yml")
foreach ($artifact in $artifacts) {
    $artifactPath = Join-Path $logsPath $artifact
    if (Test-Path $artifactPath) {
        Write-Host "⚠ Artifact still present: $artifactPath" -ForegroundColor Yellow
    }
}
Write-Host "=== Verification complete ===" -ForegroundColor Cyan
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