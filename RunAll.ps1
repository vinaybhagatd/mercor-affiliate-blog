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

Log ">>> Committing changes..."
git add .
git commit -m "Automated commit from RunAll.ps1" || Log "⚠️ Nothing to commit."

# Create a new timestamped tag
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$TagName = "release-$timestamp"
Log ">>> Creating new tag: $TagName"
git tag -a $TagName -m "Automated release $TagName"
git push origin $TagName

# Guardrail: verify tag exists on remote before creating release
Log ">>> Verifying tag $TagName exists on remote..."
Start-Sleep -Seconds 5
$remoteTag = git ls-remote origin refs/tags/$TagName
if (-not $remoteTag) {
    throw "❌ Tag $TagName not found on remote. Aborting release creation."
}

# Create GitHub release
Log ">>> Generating release notes..."
pwsh ./Create-Release.ps1 -TagName $TagName -ReleaseTitle "Mercor Affiliate Blog Release" -ReleaseBody "Automated release created by RunAll.ps1"

# Sync with remote before final push
Log ">>> Syncing with remote before push..."
git pull --rebase origin main || git rebase --abort

# Deploy to GitHub Pages
Log ">>> Deploying to GitHub Pages..."
git push origin main

Log "=== RunAll.ps1 complete. Release $TagName deployed. ==="
