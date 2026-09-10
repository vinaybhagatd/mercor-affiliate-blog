<#
.SYNOPSIS
  Master cleanup orchestrator for Mercor Affiliate Blog System (MABS).
.DESCRIPTION
  Runs both Cleanup-Repo.ps1 and Cleanup-Blogs.ps1 in sequence.
  Supports dry-run mode to preview deletions without removing files.
  Logs all actions to CleanupReport.txt for audit.
#>

param(
  [switch]$DryRun,
  [switch]$IncludeBlogs
)

$repoRoot = "C:\Users\LMTest\promotional\mercor-affiliate-blog"
$logFile = "$repoRoot\CleanupReport.txt"

function Log($text) {
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $text" | Out-File -FilePath $logFile -Append
}

Write-Output "🔧 Starting master cleanup orchestrator..."
Log "Master cleanup started."

# ✅ Run repo cleanup
Write-Output "➡️ Running Cleanup-Repo.ps1..."
if ($DryRun) {
    pwsh -NoProfile -ExecutionPolicy Bypass -File "$repoRoot\Cleanup-Repo.ps1" -DryRun
    Log "Repo cleanup executed in dry-run mode."
} else {
    pwsh -NoProfile -ExecutionPolicy Bypass -File "$repoRoot\Cleanup-Repo.ps1"
    Log "Repo cleanup executed in live mode."
}

# ✅ Run blog cleanup only if requested
if ($IncludeBlogs) {
    Write-Output "➡️ Running Cleanup-Blogs.ps1..."
    if ($DryRun) {
        pwsh -NoProfile -ExecutionPolicy Bypass -File "$repoRoot\Cleanup-Blogs.ps1" -DryRun
        Log "Blog cleanup executed in dry-run mode."
    } else {
        pwsh -NoProfile -ExecutionPolicy Bypass -File "$repoRoot\Cleanup-Blogs.ps1"
        Log "Blog cleanup executed in live mode."
    }
} else {
    Write-Output "ℹ️ Blog cleanup skipped (use -IncludeBlogs to enable)."
    Log "Blog cleanup skipped."
}

Write-Output "✅ Master cleanup complete. See CleanupReport.txt for audit trail."
Log "Master cleanup completed successfully."
