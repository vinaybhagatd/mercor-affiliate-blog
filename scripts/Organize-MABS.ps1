#!/usr/bin/env pwsh
<#.SYNOPSIS
  Enhanced Organize-MABS.ps1 — Enforce guardrails and reorganize MABS project structure.

.DESCRIPTION
  1. Runs guardrail checks (front matter integrity, PSScriptAnalyzer).
  2. Creates canonical folder structure.
  3. Classifies .ps1 files into pipeline, experimental, thirdparty, or templates.
  4. Moves files accordingly.
  5. Prints a post-run summary report.
#>

$repoRoot = "C:\Users\LMTest\promotional\mercor-affiliate-blog"

Write-Host "=== Enhanced Organize-MABS.ps1 started ===" -ForegroundColor Cyan

# --- Step 1: Guardrail Enforcement ---
Write-Host "Running guardrail checks..." -ForegroundColor Cyan

# Front matter sanity check
$postsPath = Join-Path $repoRoot "src\posts"
if (-not (Test-Path $postsPath)) { New-Item -ItemType Directory -Path $postsPath | Out-Null }
$sanityFail = $false
Get-ChildItem -Path $repoRoot -Recurse -Filter *.md | ForEach-Object {
    $content = Get-Content $_.FullName -Raw
    if ($content -match "(?s)^---(.*?)---") {
        $yamlBlock = $matches[1]
        $categoryMatch = [regex]::Match($yamlBlock, "category:\s*(\w+)")
        $tagsMatch = [regex]::Match($yamlBlock, "tags:\s*"

            \[(.*?)\]

            ")"
            if ($categoryMatch.Success -and $tagsMatch.Success) {
                $categoryNorm = $categoryMatch.Groups[1].Value.Trim().ToLower()
                $tagsNorm = $tagsMatch.Groups[1].Value.Split(',') | ForEach-Object { $_.Trim().ToLower() }
                if (-not ($tagsNorm -contains $categoryNorm)) {
                    Write-Host "❌ $($_.Name) tags missing category" -ForegroundColor Red
                    $sanityFail = $true
                }
            }
            else {
                Write-Host "❌ Missing category or tags in $($_.Name)" -ForegroundColor Red
                $sanityFail = $true
            }
        }
    }
    if (-not $sanityFail) { Write-Host "✅ Front matter integrity OK" -ForegroundColor Green }

    # ScriptAnalyzer check
    $settings = Join-Path $repoRoot "config\PSScriptAnalyzerSettings.psd1"
    if (Test-Path $settings) {
        $errors = Invoke-ScriptAnalyzer -Path $repoRoot -Recurse -Settings $settings -Severity ParseError, Error
        if ($errors.Count -gt 0) {
            Write-Host "❌ ScriptAnalyzer found errors:" -ForegroundColor Red
            $errors | Format-Table RuleName, Severity, ScriptName, Line, Message -AutoSize
        }
        else {
            Write-Host "✅ No ScriptAnalyzer errors found" -ForegroundColor Green
        }
    }
    else {
        Write-Host "⚠ No PSScriptAnalyzerSettings.psd1 found in config" -ForegroundColor Yellow
    }

    # --- Step 2: Create Canonical Folder Structure ---
    Write-Host "Creating folder structure..." -ForegroundColor Cyan
    $folders = @("agents", "scripts", "experimental", "thirdparty", "templates", "src\posts", "_layouts", "_includes", "_site\assets\images\thumbnails", "config", "logs")
    foreach ($folder in $folders) {
        $path = Join-Path $repoRoot $folder
        if (-not (Test-Path $path)) { New-Item -ItemType Directory -Path $path -Force | Out-Null }
    }

    # --- Step 3: Classification Logic ---
    Write-Host "Classifying .ps1 files..." -ForegroundColor Cyan

    $pipelineKeywords = @("Stabilize", "QAValidator", "Cleanup-OpenClawTemp", "Format-Scripts", "Run-ScriptAnalyzer", "Setup-MABS", "Orchestrator", "MasterHarness")
    $experimentalKeywords = @("Debug", "Test", "Diagnostics", "MercorDebug", "RunPrompt", "Analyze", "SelfHeal")
    $thirdpartyKeywords = @("uglifyjs", "mustache", "liquid", "handlebars", "nunjucks", "acorn", "errno", "esparse", "esvalidate", "markdown-it", "mkdirp", "rimraf", "semver", "node-which", "js-yaml")
    $templateKeywords = @("template", "skeleton", "Generate", "CreateBlog", "create-categories")

    $summary = @{
        pipeline     = 0
        experimental = 0
        thirdparty   = 0
        templates    = 0
        skipped      = 0
    }

    Get-ChildItem $repoRoot -Filter *.ps1 | ForEach-Object {
        $file = $_.Name
        $dest = $null

        if ($pipelineKeywords | Where-Object { $file -like "*$_*" }) {
            $dest = "scripts"
            $summary.pipeline++
        }
        elseif ($experimentalKeywords | Where-Object { $file -like "*$_*" }) {
            $dest = "experimental"
            $summary.experimental++
        }
        elseif ($thirdpartyKeywords | Where-Object { $file -like "*$_*" }) {
            $dest = "thirdparty"
            $summary.thirdparty++
        }
        elseif ($templateKeywords | Where-Object { $file -like "*$_*" }) {
            $dest = "templates"
            $summary.templates++
        }
        else {
            $summary.skipped++
        }

        if ($dest) {
            $target = Join-Path $repoRoot $dest
            if (-not (Test-Path (Join-Path $target $file))) {
                Move-Item $_.FullName $target -Force
            }
            else {
                Write-Host "⚠ Skipped duplicate: $file already exists in $dest" -ForegroundColor Yellow
            }
        }
    }

    # --- Step 4: Post-Run Summary ---
    Write-Host "`n=== Post-Run Summary ===" -ForegroundColor Cyan
    Write-Host "Pipeline scripts moved: $($summary.pipeline)" -ForegroundColor Green
    Write-Host "Experimental scripts moved: $($summary.experimental)" -ForegroundColor Yellow
    Write-Host "Third-party scripts moved: $($summary.thirdparty)" -ForegroundColor Magenta
    Write-Host "Template scripts moved: $($summary.templates)" -ForegroundColor Blue
    Write-Host "Skipped (unclassified or duplicates): $($summary.skipped)" -ForegroundColor DarkGray
    Write-Host "=== Organize-MABS.ps1 complete ===" -ForegroundColor Cyan
    #>


}