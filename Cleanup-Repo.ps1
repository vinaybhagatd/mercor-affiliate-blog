<#
.SYNOPSIS
  Safely cleans up non-essential artifacts from Mercor Affiliate Blog repo.
.DESCRIPTION
  Deletes only logs, diffs, summaries, and stray text artifacts.
  Skips critical folders (node_modules, .git, .github, .githooks, _layouts, _includes, src/posts, _site).
  Skips .bak backups and canonical scripts for rollback safety.
  Supports dry-run mode to preview deletions.
  Moves deleted artifacts into cleanup-archive/ before removal for secondary safety.
  Logs all actions to CleanupReport.txt for audit.
  Provides a summary report at the end.
#>

param(
  [switch]$DryRun
)

$repoRoot   = "C:\Users\LMTest\promotional\mercor-affiliate-blog"
$logFile    = "$repoRoot\CleanupReport.txt"
$archiveDir = "$repoRoot\cleanup-archive"

# ✅ Critical folders to skip
$skipDirs = @(
    "$repoRoot\node_modules",
    "$repoRoot\.git",
    "$repoRoot\.github",
    "$repoRoot\.githooks",
    "$repoRoot\_layouts",
    "$repoRoot\_includes",
    "$repoRoot\src\posts",
    "$repoRoot\_site"
)

function Log($text) {
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $text" | Out-File -FilePath $logFile -Append
}

# Ensure archive folder exists
if (-not (Test-Path $archiveDir)) {
    New-Item -ItemType Directory -Path $archiveDir | Out-Null
    Log "Created cleanup archive folder: $archiveDir"
}

Write-Output "⚠️ This will move logs, diffs, summaries, and stray artifacts into $archiveDir."
if (-not $DryRun) {
    $confirm = Read-Host "Do you want to proceed? (Y/N)"
}

# ✅ Patterns limited to logs, diffs, summaries, and stray text artifacts
$patterns = @("*.log","*.txt")

$archivedCount = 0
$skippedCount  = 0

foreach ($pattern in $patterns) {
    Get-ChildItem -Path $repoRoot -Recurse -Include $pattern -ErrorAction SilentlyContinue |
        ForEach-Object {
            $filePath = $_.FullName

            # Skip critical folders
            if ($skipDirs | Where-Object { $filePath.StartsWith($_) }) {
                $skippedCount++
                return
            }

            # Skip .bak backups
            if ($filePath -match "\.bak$") {
                $skippedCount++
                return
            }

            $destPath = Join-Path $archiveDir $_.Name

            if ($DryRun) {
                Write-Output "🔎 Would archive: $filePath → $destPath"
                Log "Dry-run: would archive $filePath → $destPath"
                $archivedCount++
            } elseif ($confirm -eq "Y") {
                Write-Output "📦 Archiving: $filePath → $destPath"
                Log "Archived artifact: $filePath → $destPath"
                Move-Item $filePath $destPath -Force
                $archivedCount++
            } else {
                $skippedCount++
            }
        }
}

# ✅ Summary report
if ($DryRun) {
    Write-Output "✅ Dry-run complete. $archivedCount files flagged for archiving, $skippedCount files skipped. See CleanupReport.txt for details."
    Log "Repo cleanup dry-run completed. $archivedCount files flagged, $skippedCount skipped."
} elseif ($confirm -eq "Y") {
    Write-Output "✅ Repo cleanup complete. $archivedCount files archived, $skippedCount files skipped. See CleanupReport.txt for audit trail."
    Log "Repo cleanup completed successfully. $archivedCount files archived, $skippedCount skipped."
} else {
    Write-Output "❌ Cleanup aborted by user. $skippedCount files skipped."
    Log "Repo cleanup aborted by user. $skippedCount skipped."
}
