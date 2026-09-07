<#
.SYNOPSIS
  Safely cleans up existing blog posts in src/posts.
.DESCRIPTION
  Deletes only markdown blog files after user confirmation.
  Leaves folder intact for regeneration by BatchCreateBlogs.ps1.
  Supports dry-run mode to preview deletions.
  Logs all actions to CleanupReport.txt for audit.
#>

param(
  [switch]$DryRun
)

$postsDir = "C:\Users\LMTest\promotional\mercor-affiliate-blog\src\posts"
$logFile = "C:\Users\LMTest\promotional\mercor-affiliate-blog\CleanupReport.txt"

function Log($text) {
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $text" | Out-File -FilePath $logFile -Append
}

Write-Output "⚠️ This will delete ALL existing blog posts (*.md) in $postsDir."
if (-not $DryRun) {
    $confirm = Read-Host "Do you want to proceed? (Y/N)"
}

if (Test-Path $postsDir) {
    Get-ChildItem -Path $postsDir -Filter *.md |
        ForEach-Object {
            if ($DryRun) {
                Write-Output "🔎 Would remove blog: $($_.FullName)"
                Log "Dry-run: would remove blog $($_.FullName)"
            } else {
                if ($confirm -eq "Y") {
                    Write-Output "🗑️ Removing blog: $($_.FullName)"
                    Log "Removed blog post: $($_.FullName)"
                    Remove-Item $_.FullName -Force
                }
            }
        }

    if ($DryRun) {
        Write-Output "✅ Dry-run complete. No blogs deleted. See CleanupReport.txt for preview."
        Log "Blog cleanup dry-run completed."
    } elseif ($confirm -eq "Y") {
        Write-Output "✅ Blog cleanup complete. See CleanupReport.txt for audit trail."
        Log "Blog cleanup completed successfully."
    } else {
        Write-Output "❌ Blog cleanup aborted by user."
        Log "Blog cleanup aborted by user."
    }
} else {
    Write-Output "⚠️ Blog posts directory not found: $postsDir"
    Log "Blog cleanup failed: directory not found."
}
