#!/usr/bin/env pwsh
<#
.SYNOPSIS
  Classify-Scripts.ps1 — Reorganize MABS PowerShell scripts.

.DESCRIPTION
  Scans all .ps1 files in the repo and classifies them into:
    * pipeline     → core automation + CI/CD drivers
    * experimental → debug/test stubs
    * thirdparty   → wrappers for external tools
    * cleanup      → repo hygiene + maintenance
    * tests        → validation + QA checks
    * githooks     → Git hook scripts
    * framework    → Eleventy/Node wrappers
    * automation   → AutoFix, BulkFix, HermesAutomation, etc.
  Moves files into sub-folders accordingly.
  Prints a summary report at the end.
#>

$repoRoot = "C:\Users\LMTest\promotional\mercor-affiliate-blog"

Write-Host "=== Classify-Scripts.ps1 started ===" -ForegroundColor Cyan

# --- Ensure canonical folders exist ---
$folders = @("scripts","experimental","thirdparty","cleanup","tests","githooks","framework","automation")
foreach ($folder in $folders) {
    $path = Join-Path $repoRoot $folder
    if (-not (Test-Path $path)) { New-Item -ItemType Directory -Path $path -Force | Out-Null }
}

# --- Classification keywords ---
$pipelineKeywords     = @("Stabilize","QAValidator","Repair","Run-ScriptAnalyzer","Format-Scripts","Setup-MABS","MasterHarness","Orchestrator")
$experimentalKeywords = @("Debug","Test","Diagnostics","MercorDebug","RunPrompt","SelfHeal","Analyze","blog-template")
$thirdpartyKeywords   = @("acorn","ejs","handlebars","liquid","mustache","uglifyjs","markdown-it","js-yaml","mkdirp","rimraf","semver","node-which","nunjucks")
$cleanupKeywords      = @("Cleanup","RepoCleanup")
$testKeywords         = @("Test","Validate","Verify")
$hookKeywords         = @("pre-commit","setup-hooks")
$utilityKeywords      = @("Backup","Deploy","RunPipeline","Update-ModuleVersion","Organize-MABS","ContentFiller","CreateBlog","CreateCategories","Generate","ReleaseAudit")
$frameworkKeywords    = @("eleventy","parser","errno","mime","jake","pidtree","resolve","run-p","run-s","which","npm-run-all")
$automationKeywords   = @("AutoFix","BulkFix","Configure","HermesAutomation","RunAll","RunQwenFix","RunScheduler","SanitizeScripts","PSFixer")

$summary = @{
    pipeline     = 0
    experimental = 0
    thirdparty   = 0
    cleanup      = 0
    tests        = 0
    hooks        = 0
    utilities    = 0
    framework    = 0
    automation   = 0
    skipped      = 0
}

# --- Scan and classify ---
Get-ChildItem $repoRoot -Recurse -Filter *.ps1 | ForEach-Object {
    $file = $_.Name
    $dest = $null

    if ($pipelineKeywords | Where-Object { $file -like "*$_*" }) {
        $dest = "scripts"; $summary.pipeline++
    } elseif ($experimentalKeywords | Where-Object { $file -like "*$_*" }) {
        $dest = "experimental"; $summary.experimental++
    } elseif ($thirdpartyKeywords | Where-Object { $file -like "*$_*" }) {
        $dest = "thirdparty"; $summary.thirdparty++
    } elseif ($cleanupKeywords | Where-Object { $file -like "*$_*" }) {
        $dest = "cleanup"; $summary.cleanup++
    } elseif ($testKeywords | Where-Object { $file -like "*$_*" }) {
        $dest = "tests"; $summary.tests++
    } elseif ($hookKeywords | Where-Object { $file -like "*$_*" }) {
        $dest = "githooks"; $summary.hooks++
    } elseif ($utilityKeywords | Where-Object { $file -like "*$_*" }) {
        $dest = "scripts"; $summary.utilities++
    } elseif ($frameworkKeywords | Where-Object { $file -like "*$_*" }) {
        $dest = "framework"; $summary.framework++
    } elseif ($automationKeywords | Where-Object { $file -like "*$_*" }) {
        $dest = "automation"; $summary.automation++
    } else {
        $summary.skipped++
    }

    if ($dest) {
        $target = Join-Path $repoRoot $dest
        if (-not (Test-Path (Join-Path $target $file))) {
            Move-Item $_.FullName $target -Force
            Write-Host "✔ Moved $file → $dest" -ForegroundColor Green
        } else {
            Write-Host "⚠ Skipped duplicate: $file already exists in $dest" -ForegroundColor Yellow
        }
    } else {
        Write-Host "⚠ Skipped unclassified: $file" -ForegroundColor DarkGray
    }
}

# --- Summary ---
Write-Host "`n=== Classification Summary ===" -ForegroundColor Cyan
Write-Host "Pipeline scripts moved: $($summary.pipeline)" -ForegroundColor Green
Write-Host "Experimental scripts moved: $($summary.experimental)" -ForegroundColor Yellow
Write-Host "Third-party scripts moved: $($summary.thirdparty)" -ForegroundColor Magenta
Write-Host "Cleanup scripts moved: $($summary.cleanup)" -ForegroundColor Blue
Write-Host "Test/validation scripts moved: $($summary.tests)" -ForegroundColor Cyan
Write-Host "Git hook scripts moved: $($summary.hooks)" -ForegroundColor DarkGreen
Write-Host "Utility scripts moved: $($summary.utilities)" -ForegroundColor DarkYellow
Write-Host "Framework scripts moved: $($summary.framework)" -ForegroundColor DarkCyan
Write-Host "Automation scripts moved: $($summary.automation)" -ForegroundColor DarkRed
Write-Host "Skipped (unclassified or duplicates): $($summary.skipped)" -ForegroundColor DarkGray
Write-Host "=== Classify-Scripts.ps1 complete ===" -ForegroundColor Cyan
