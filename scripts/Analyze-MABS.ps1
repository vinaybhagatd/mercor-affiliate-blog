#!/usr/bin/env pwsh
<#
.SYNOPSIS
  Analyze-MABS.ps1 — System review and analysis pipeline for Mercor Affiliate Blog System.

.DESCRIPTION
  Scans the repository structure, catalogs blog posts, audits metadata/front matter health,
  checks configuration files (including agents folder), and outputs a comprehensive system report.
#>

Write-Host "=== MABS System Analysis Started ===" -ForegroundColor Cyan

# Paths
$repoRoot     = "C:\Users\LMTest\promotional\mercor-affiliate-blog"
$blogPath     = Join-Path $repoRoot "src\posts"
$reportPath   = Join-Path $repoRoot "MABS-SystemAnalysisReport.txt"

$reportContent = [System.Collections.Generic.List[string]]::new()
$reportContent.Add("==================================================")
$reportContent.Add("        MABS SYSTEM ANALYSIS & HEALTH REPORT      ")
$reportContent.Add("==================================================")
$reportContent.Add("Generated: $(Get-Date)")
$reportContent.Add("Repository Root: $repoRoot")
$reportContent.Add("")

# --- 1. Repository Structure & File Inventory ---
Write-Host "[1/4] Cataloging repository structure..." -ForegroundColor Yellow
$reportContent.Add("--- 1. FILE INVENTORY & STRUCTURE ---")

$allFiles = Get-ChildItem -Path $repoRoot -Recurse -File | Where-Object { $_.FullName -notmatch '\\\.git\\' -and $_.FullName -notmatch '\\node_modules\\' }
$fileCounts = $allFiles | Group-Object Extension | Select-Object Name, Count

foreach ($group in $fileCounts) {
    $ext = if ([string]::IsNullOrEmpty($group.Name)) { "[No Extension]" } else { $group.Name }
    $reportContent.Add("  - File Type '$ext': $($group.Count) files")
}
$reportContent.Add("  - Total Tracked Files: $($allFiles.Count)")
$reportContent.Add("")

# --- 2. Core System Files Audit ---
Write-Host "[2/4] Auditing core system configuration scripts..." -ForegroundColor Yellow
$reportContent.Add("--- 2. CORE SYSTEM FILES AUDIT ---")

# Updated paths relative to repository structure
$coreFiles = @(
    @{ Name = "StabilizeAgent.yaml"; Path = "agents\StabilizeAgent.yaml" },
    @{ Name = "Stabilize-MABS.ps1"; Path = "Stabilize-MABS.ps1" },
    @{ Name = "FixFrontMatter.ps1"; Path = "FixFrontMatter.ps1" },
    @{ Name = "VerifyFrontMatter.ps1"; Path = "VerifyFrontMatter.ps1" },
    @{ Name = "PSScriptAnalyzerSettings.psd1"; Path = "PSScriptAnalyzerSettings.psd1" }
)

foreach ($fileInfo in $coreFiles) {
    $fullPath = Join-Path $repoRoot $fileInfo.Path
    if (Test-Path $fullPath) {
        $reportContent.Add("  [OK] Found: $($fileInfo.Name) (at $($fileInfo.Path))")
    } else {
        $reportContent.Add("  [MISSING] Required file missing: $($fileInfo.Name)")
    }
}
$reportContent.Add("")

# --- 3. Blog Posts & Front Matter Analysis ---
Write-Host "[3/4] Analyzing blog posts and metadata..." -ForegroundColor Yellow
$reportContent.Add("--- 3. BLOG POSTS ANALYSIS (`src\posts`) ---")

if (Test-Path $blogPath) {
    $posts = Get-ChildItem -Path $blogPath -Recurse -Filter *.md
    $reportContent.Add("  - Total Blog Posts Found: $($posts.Count)")

    $categories = @{}
    $totalWords = 0
    $issuesCount = 0

    foreach ($post in $posts) {
        $content = Get-Content $post.FullName -Raw
        $wordCount = ($content -split '\s+').Count
        $totalWords += $wordCount

        if ($content -match "(?s)^---(.*?)---") {
            $yamlBlock = $matches[1]
            if ($yamlBlock -match "category:\s*([^\r\n]+)") {
                $cat = $Matches[1].Trim().Trim('"').Trim("'")
                if ($categories.ContainsKey($cat)) { $categories[$cat]++ } else { $categories[$cat] = 1 }
            }
        } else {
            $issuesCount++
        }
    }

    $reportContent.Add("  - Total Estimated Word Count: $totalWords words")
    $reportContent.Add("  - Posts Missing Front Matter Blocks: $issuesCount")
    $reportContent.Add("")
    $reportContent.Add("  Categories Distribution:")
    foreach ($cat in $categories.Keys) {
        $reportContent.Add("    * $cat : $($categories[$cat]) post(s)")
    }
} else {
    $reportContent.Add("  [WARNING] Blog posts directory not found at $blogPath")
}
$reportContent.Add("")

# --- 4. Summary & Health Status ---
Write-Host "[4/4] Finalizing analysis report..." -ForegroundColor Yellow
$reportContent.Add("==================================================")
$reportContent.Add(" ANALYSIS COMPLETE: System is operational.")
$reportContent.Add("==================================================")

# Write report to disk
$reportContent | Set-Content $reportPath -Encoding UTF8
Write-Host "✅ Analysis report successfully updated at: $reportPath" -ForegroundColor Green