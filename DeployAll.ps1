<#
.SYNOPSIS
  One-click wrapper for full deploy.
.DESCRIPTION
  - Runs ReleaseAudit.ps1 (BulkFix + Audit + Release)
  - Pushes latest changes and tags to GitHub Pages
#>

$ErrorActionPreference = "Stop"

Write-Host "=== DeployAll.ps1 started ===" -ForegroundColor Cyan

# --- Step 1: Run ReleaseAudit (fix + audit + release) ---
Write-Host "Running ReleaseAudit.ps1..."
.\ReleaseAudit.ps1

# --- Step 2: Push to GitHub Pages ---
Write-Host "Deploying to GitHub Pages..."
git push origin main
git push origin --tags

Write-Host "=== DeployAll.ps1 complete. Full deploy executed. ===" -ForegroundColor Green
