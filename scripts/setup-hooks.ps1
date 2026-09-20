#!/usr/bin/env pwsh
<#
.SYNOPSIS
  setup-hooks.ps1 — Normalize and install Git hooks.

.DESCRIPTION
  1. Detects duplicate .githooks folders in repo root.
  2. Keeps the first canonical .githooks folder, archives extras.
  3. Creates symlinks in .git/hooks pointing to scripts in .githooks.
  4. If symlink creation fails, falls back to copying the hook script.
  5. Verifies each symlink or copy points to a valid .ps1 file.
  6. If -FixMissing is passed, restores missing hook scripts from backup.
  7. Logs results to HookSetupReport.txt.
#>

param(
    [switch]$FixMissing
)

$repoRoot   = "C:\Users\LMTest\promotional\mercor-affiliate-blog"
$gitHooks   = Join-Path $repoRoot ".git/hooks"
$customHooksRoot = Join-Path $repoRoot ".githooks"
$archiveRoot = Join-Path $repoRoot "backup\githooks_duplicates"
$logsPath   = Join-Path $repoRoot "logs"
$reportFile = Join-Path $logsPath "HookSetupReport.txt"

if (-not (Test-Path $logsPath)) { New-Item -ItemType Directory -Path $logsPath | Out-Null }
"=== Hook Setup run: $(Get-Date) ===" | Out-File -FilePath $reportFile -Encoding UTF8

Write-Host "=== setup-hooks.ps1 started ===" -ForegroundColor Cyan

# Step 1: Detect duplicate .githooks folders
$githooksFolders = Get-ChildItem $repoRoot -Directory -Filter ".githooks*"
if ($githooksFolders.Count -gt 1) {
    Write-Host "⚠ Found $($githooksFolders.Count) .githooks folders" -ForegroundColor Yellow
    if (-not (Test-Path $archiveRoot)) { New-Item -ItemType Directory -Path $archiveRoot | Out-Null }

    $canonical = $githooksFolders[0].FullName
    foreach ($dup in $githooksFolders[1..($githooksFolders.Count-1)]) {
        $target = Join-Path $archiveRoot $dup.Name
        Move-Item $dup.FullName $target -Force
        Write-Host "📦 Archived duplicate folder: $($dup.FullName) → $target" -ForegroundColor DarkYellow
        Add-Content -Path $reportFile -Value "ARCHIVED: $($dup.FullName) → $target"
    }
    $customHooksRoot = $canonical
} else {
    Write-Host "✔ Single .githooks folder detected" -ForegroundColor Green
}

# Step 2: Ensure .git/hooks exists
if (-not (Test-Path $gitHooks)) {
    Write-Host "❌ .git/hooks not found. Is this a Git repo?" -ForegroundColor Red
    Add-Content -Path $reportFile -Value "ERROR: .git/hooks not found"
    exit 1
}

# Step 3: Symlink each hook script (with fallback to copy)
Get-ChildItem $customHooksRoot -Filter *.ps1 | ForEach-Object {
    $hookName = $_.Name
    $target   = $_.FullName
    $linkPath = Join-Path $gitHooks $hookName

    if (Test-Path $linkPath) { Remove-Item $linkPath -Force }

    try {
        New-Item -ItemType SymbolicLink -Path $linkPath -Target $target -ErrorAction Stop | Out-Null
        Write-Host "🔗 Linked $hookName → $linkPath" -ForegroundColor Green
        Add-Content -Path $reportFile -Value "LINKED: $hookName → $linkPath"
    }
    catch {
        Write-Host "⚠ Symlink failed for $hookName, falling back to copy..." -ForegroundColor Yellow
        Copy-Item $target $linkPath -Force
        Write-Host "📄 Copied $hookName → $linkPath" -ForegroundColor DarkYellow
        Add-Content -Path $reportFile -Value "COPIED: $hookName → $linkPath"
    }

    # Step 4: Verify target exists
    if (-not (Test-Path $target)) {
        Write-Host "❌ WARNING: Hook target missing → $target" -ForegroundColor Red
        Add-Content -Path $reportFile -Value "WARNING: Hook target missing → $target"

        if ($FixMissing) {
            $backupTarget = Join-Path $archiveRoot $hookName
            if (Test-Path $backupTarget) {
                Copy-Item $backupTarget $target -Force
                Write-Host "🛠 Restored missing hook from backup → $target" -ForegroundColor Cyan
                Add-Content -Path $reportFile -Value "FIXED: Restored $hookName from backup"
            } else {
                Write-Host "⚠ No backup found for $hookName" -ForegroundColor Yellow
                Add-Content -Path $reportFile -Value "ERROR: No backup found for $hookName"
            }
        }
    } else {
        Write-Host "✔ Verified hook target exists → $target" -ForegroundColor Green
        Add-Content -Path $reportFile -Value "VERIFIED: $target"
    }
}

Write-Host "=== setup-hooks.ps1 complete ===" -ForegroundColor Cyan
Add-Content -Path $reportFile -Value "=== setup-hooks.ps1 complete ==="
