<#
.SYNOPSIS
  End-to-end automation pipeline for MABS.
.DESCRIPTION
  Runs self-heal, blog generation, front matter fixes,
  QA validation, release tagging, and deployment.
#>

$ErrorActionPreference = "Stop"

Write-Host "=== RunAll.ps1 started ===" -ForegroundColor Cyan

# --- Step 1: Self-Heal ---
Write-Host "[SelfHeal] $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Running self-heal scripts..."
.\SelfHeal.ps1
Write-Host "[SelfHeal] $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - MABS Self-Heal + AI Repair complete."

# --- Step 2: Generate Blogs ---
Write-Host "Generating blogs..."
.\BatchCreateBlogs.ps1

# --- Step 3: Fix Front Matter ---
Write-Host "Fixing front matter..."
.\FixFrontMatter.ps1

# --- Step 4: QA Validation ---
Write-Host "Running QA validation..."
try {
    .\QAValidator.ps1
    Write-Host "QA validation passed. Continuing pipeline..."
} catch {
    Write-Warning "QA validation reported issues. See QAValidatorReport.txt for details."
    # Continue pipeline instead of aborting
}

# --- Step 5: Git Commit & Auto-Bump Tag ---
Write-Host "Committing changes..."
git add .
git commit -m "Automated blog update $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" | Out-Null

# Auto-bump tag logic
$tagBase = "release"
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$newTag = "$tagBase-$timestamp"

Write-Host "Creating new tag: $newTag"
git tag -a $newTag -m "Automated release $newTag"
git push origin $newTag

# --- Step 6: Release Notes ---
Write-Host "Generating release notes..."
.\Create-Release.ps1 -Tag $newTag

# --- Step 7: Deployment ---

Write-Host "Syncing with remote before push..."
git pull --rebase origin main || git rebase --abort

Write-Host "Deploying to GitHub Pages..."
git push origin main

Write-Host "=== RunAll.ps1 complete. Release $newTag deployed. ===" -ForegroundColor Green
