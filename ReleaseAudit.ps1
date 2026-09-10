<#
.SYNOPSIS
  One-click wrapper for bulk fix, audit, and release.
.DESCRIPTION
  - Runs BulkFix-Posts.ps1 to repair all posts
  - Runs QAValidator.ps1 in Pre-Release Audit mode
  - Calls RunAll.ps1 for end-to-end automation
#>

$ErrorActionPreference = "Stop"

Write-Host "=== ReleaseAudit.ps1 started ===" -ForegroundColor Cyan

# --- Step 1: Bulk Fix ---
Write-Host "Running BulkFix-Posts.ps1..."
.\BulkFix-Posts.ps1

# --- Step 2: Pre-Release Audit ---
Write-Host "Running QAValidator.ps1 in Pre-Release Audit mode..."
.\QAValidator.ps1 -PreReleaseAudit

# --- Step 3: End-to-End Release ---
Write-Host "Running RunAll.ps1 for full pipeline..."
.\RunAll.ps1

Write-Host "=== ReleaseAudit.ps1 complete. Fix + Audit + Release executed. ===" -ForegroundColor Green
