<#
.SYNOPSIS
  Restore-FromBackup.ps1
.DESCRIPTION
  Restores critical files (Eleventy config, Node metadata, PowerShell scripts)
  from the latest backup folder created by Fix-FolderStructure.ps1.
.NOTES
  Run from project root: C:\Users\LMTest\promotional\mercor-affiliate-blog
#>

$Root = "C:\Users\LMTest\promotional\mercor-affiliate-blog"
$BackupRoot = Join-Path $Root "mercor_backups"

# Find latest backup folder
$latestBackup = Get-ChildItem -Path $BackupRoot -Directory -ErrorAction SilentlyContinue |
                Sort-Object LastWriteTime -Descending | Select-Object -First 1

if (-not $latestBackup) {
    Write-Output "No backup folder found under $BackupRoot. Aborting."
    exit 1
}

Write-Output "Using backup folder: $($latestBackup.FullName)"

# Restore only critical files
$filesToRestore = Get-ChildItem -Path $latestBackup.FullName -Recurse -File |
                  Where-Object { $_.Name -eq ".eleventy.js" -or $_.Name -eq "package.json" -or $_.Name -eq "package-lock.json" -or $_.Extension -eq ".ps1" }

foreach ($file in $filesToRestore) {
    $relativePath = $file.FullName.Substring($latestBackup.FullName.Length+1)
    $dest = Join-Path $Root $relativePath

    $destFolder = Split-Path $dest -Parent
    if (-not (Test-Path $destFolder)) {
        New-Item -ItemType Directory -Force -Path $destFolder | Out-Null
    }

    Copy-Item $file.FullName $dest -Force
    Write-Output "Restored: $relativePath"
}

Write-Output "=== Restoration complete ==="
