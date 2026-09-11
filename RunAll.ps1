<#
.SYNOPSIS
    Full automation pipeline for Mercor Affiliate Blog System (MABS).
.DESCRIPTION
    - Runs self-heal scripts
    - Generates blogs
    - Fixes front matter
    - Runs QA validation
    - Commits changes
    - Creates timestamped tag
    - Verifies tag exists on remote
    - Calls Create-Release.ps1
    - Syncs with remote before push
    - Deploys to GitHub Pages
.NOTES
    Author: Mercor Affiliate Blog System (MABS)
#>

Write-Host "=== RunAll.ps1 started ==="

# --- Self-heal ---
Write-Host "[SelfHeal] $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Running self-heal scripts..."
pwsh ./SelfHeal.ps1
Write-Host "[SelfHeal] $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - MABS Self-Heal + AI Repair complete."

# --- Blog generation ---
Write-Host "Generating blogs..."
pwsh ./BatchCreateBlogs.ps1

# --- Fix front matter ---
Write-Host "Fixing front matter..."
pwsh ./FixFrontMatter.ps1

# --- QA validation ---
Write-Host "Running QA validation..."
pwsh ./QAValidator.ps1

# --- Commit changes ---
Write-Host ">>> Committing changes..."
git add .
git commit -m "Automated commit from RunAll.ps1" || Write-Host "⚠️ Nothing to commit."

# --- Create timestamped tag ---
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$TagName = "release-$timestamp"
Write-Host ">>> Creating new tag: $TagName"
git tag -a $TagName -m "Automated release $TagName"
git push origin $TagName

# --- Guardrail: verify tag exists on remote ---
Write-Host ">>> Verifying tag $TagName exists on remote..."
Start-Sleep -Seconds 5
$remoteTag = git ls-remote origin refs/tags/$TagName
if (-not $remoteTag) {
    throw "❌ Tag $TagName not found on remote. Aborting release creation."
}

# --- Create GitHub release ---
Write-Host ">>> Generating release notes..."
pwsh ./Create-Release.ps1 -TagName $TagName -ReleaseTitle "Mercor Affiliate Blog Release" -ReleaseBody "Automated release created by RunAll.ps1"

# --- Sync with remote before push ---
Write-Host ">>> Syncing with remote before push..."
git pull --rebase origin main || git rebase --abort

# --- Deploy to GitHub Pages ---
Write-Host ">>> Deploying to GitHub Pages..."
git push origin main

Write-Host "=== RunAll.ps1 complete. Release $TagName deployed. ==="
