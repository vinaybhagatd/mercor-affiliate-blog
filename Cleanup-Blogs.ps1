<#
.SYNOPSIS
  Safely cleans up existing blog posts in src/posts.
.DESCRIPTION
  Deletes only non‑canonical blog posts (those missing the "🌟 Why This Matters" section).
  Provides dry‑run mode for preview before deletion.
  Leaves canonical posts intact.
#>

param(
  [switch]$DryRun
)

$postsDir = "C:\Users\LMTest\promotional\mercor-affiliate-blog\src\posts"
$reportFile = Join-Path $postsDir "CleanupReport.txt"

Write-Output "⚠️ This will delete NON‑CANONICAL blog posts (*.md) in $postsDir."
Write-Output "Canonical posts (with '🌟 Why This Matters') will be preserved."

if (Test-Path $reportFile) {
    Remove-Item $reportFile -Force
}

if (Test-Path $postsDir) {
    Get-ChildItem -Path $postsDir -Filter *.md | ForEach-Object {
        $fileContent = Get-Content $_.FullName -Raw
        if ($fileContent -notmatch "🌟 Why This Matters") {
            if ($DryRun) {
                Write-Output "🔎 Would remove non‑canonical blog: $($_.FullName)"
                Add-Content -Path $reportFile -Value "Would remove: $($_.FullName)"
            } else {
                Write-Output "🗑️ Removing non‑canonical blog: $($_.FullName)"
                Remove-Item $_.FullName -Force
                Add-Content -Path $reportFile -Value "Removed: $($_.FullName)"
            }
        } else {
            Write-Output "✅ Preserved canonical blog: $($_.FullName)"
            Add-Content -Path $reportFile -Value "Preserved: $($_.FullName)"
        }
    }

    if ($DryRun) {
        Write-Output "✅ Dry‑run complete. No blogs deleted. See CleanupReport.txt for preview."
    } else {
        Write-Output "✅ Cleanup complete. See CleanupReport.txt for details."
    }
} else {
    Write-Output "⚠️ Blog posts directory not found: $postsDir"
}
