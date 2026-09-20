#!/usr/bin/env pwsh
<#
.SYNOPSIS
  Verify-Duplicates.ps1 — Detects duplicate .ps1 scripts.

.DESCRIPTION
  Compares files with the same name across repo folders.
  Reports whether duplicates are identical or different.
  Identical duplicates are safe to delete.
  Use -DeleteIdentical to automatically move extras to backup.
  Use -DryRun to preview deletions without removing files.
  All results are logged to DuplicateReport.txt with a summary.
#>

param(
    [switch]$DeleteIdentical,
    [switch]$DryRun
)

$repoRoot   = "C:\Users\LMTest\promotional\mercor-affiliate-blog"
$logsPath   = Join-Path $repoRoot "logs"
$backupPath = Join-Path $repoRoot "backup\duplicates"
$reportFile = Join-Path $logsPath "DuplicateReport.txt"

if (-not (Test-Path $logsPath)) { New-Item -ItemType Directory -Path $logsPath | Out-Null }
if (-not (Test-Path $backupPath)) { New-Item -ItemType Directory -Path $backupPath -Force | Out-Null }

"=== Duplicate Verification run: $(Get-Date) ===" | Out-File -FilePath $reportFile -Encoding UTF8

# Counters for summary
$identicalCount = 0
$differentCount = 0
$deletedCount   = 0
$dryRunCount    = 0

# Collect all .ps1 files grouped by name
$files = Get-ChildItem $repoRoot -Recurse -Filter *.ps1 | Group-Object Name

foreach ($group in $files) {
    if ($group.Count -gt 1) {
        Write-Host "🔎 Checking duplicates for $($group.Name)" -ForegroundColor Cyan
        $baseFile    = $group.Group[0].FullName
        $baseContent = Get-Content $baseFile -Raw
        $allMatch    = $true

        foreach ($file in $group.Group[1..($group.Count-1)]) {
            $content = Get-Content $file.FullName -Raw
            if ($baseContent -ne $content) {
                $allMatch = $false
                $differentCount++
                Write-Host "⚠️ DIFFERENT: $($group.Name) → $($file.FullName)" -ForegroundColor Yellow
                Add-Content -Path $reportFile -Value "DIFFERENT: $($group.Name) → $($file.FullName)"
            } else {
                $identicalCount++
                Write-Host "✔ IDENTICAL: $($group.Name) → $($file.FullName)" -ForegroundColor Green
                Add-Content -Path $reportFile -Value "IDENTICAL: $($group.Name) → $($file.FullName)"

                if ($DeleteIdentical) {
                    if ($file.FullName -ne $baseFile) {
                        if ($DryRun) {
                            $dryRunCount++
                            Write-Host "📝 DryRun: Would archive $($file.FullName)" -ForegroundColor DarkYellow
                            Add-Content -Path $reportFile -Value "DRYRUN: Would archive $($file.FullName)"
                        } else {
                            $targetBackup = Join-Path $backupPath $file.Name
                            Move-Item $file.FullName $targetBackup -Force
                            $deletedCount++
                            Write-Host "📦 Archived duplicate: $($file.FullName) → $targetBackup" -ForegroundColor Red
                            Add-Content -Path $reportFile -Value "ARCHIVED: $($file.FullName) → $targetBackup"
                        }
                    }
                }
            }
        }

        if ($allMatch) {
            Write-Host "✅ All copies of $($group.Name) are identical." -ForegroundColor Green
            Add-Content -Path $reportFile -Value "SAFE TO DELETE duplicates of $($group.Name)"
        } else {
            Write-Host "❌ $($group.Name) has differences. Keep all copies." -ForegroundColor Red
            Add-Content -Path $reportFile -Value "KEEP ALL copies of $($group.Name)"
        }
    }
}

# --- Summary ---
$summary = @"
=== Duplicate Verification Summary ===
Identical duplicates found: $identicalCount
Different duplicates found: $differentCount
DryRun archives (preview only): $dryRunCount
Actual archives performed: $deletedCount
Backup folder: $backupPath
=== Verify-Duplicates.ps1 complete ===
"@

Write-Host $summary -ForegroundColor Cyan
Add-Content -Path $reportFile -Value $summary
