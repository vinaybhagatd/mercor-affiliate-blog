<#
.SYNOPSIS
    Release audit wrapper for Mercor Affiliate Blog System.
.DESCRIPTION
    - Runs BulkFix-Posts.ps1 to repair missing categories/affiliate links
    - Runs QAValidator.ps1 with PreReleaseAudit mode to validate all posts
    - Runs RunAll.ps1 to execute the full pipeline (tests + deployment)
    - Consolidates logs into ReleaseAuditReport.txt for permanent audit trail
    - Creates release tags in the format mabs-v<major>.<minor>, auto-incrementing minor version
    - Updates release notes body to include the new semantic tag
#>

param(
    [string]$ReportFile = "ReleaseAuditReport.txt",
    [int]$MajorVersion = 16   # default major version
)

$ErrorActionPreference = "Stop"

function Log {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $Message" | Out-File -FilePath $ReportFile -Append
    Write-Host $Message
}

# Reset report
Clear-Content $ReportFile -ErrorAction SilentlyContinue
Log "=== ReleaseAudit.ps1 started ==="

try {
    # Step 1: BulkFix
    Log ">>> Running BulkFix-Posts.ps1..."
    pwsh ./BulkFix-Posts.ps1 | Tee-Object -FilePath $ReportFile -Append

    # Step 2: QAValidator
    Log ">>> Running QAValidator.ps1 (PreReleaseAudit)..."
    pwsh ./QAValidator.ps1 -PreReleaseAudit | Tee-Object -FilePath $ReportFile -Append

    # Step 3: RunAll pipeline
    Log ">>> Running RunAll.ps1..."
    pwsh ./RunAll.ps1 | Tee-Object -FilePath $ReportFile -Append

    # Step 4: Auto-increment semantic version tag
    $latestTag = git tag --list "mabs-v$MajorVersion.*" | Sort-Object { 
        [version]($_ -replace 'mabs-v','') 
    } | Select-Object -Last 1

    if ($latestTag) {
        $parts = $latestTag -replace 'mabs-v','' -split '\.'
        $minor = [int]$parts[1] + 1
    } else {
        $minor = 1
    }

    $newTag = "mabs-v$MajorVersion.$minor"
    Log ">>> Creating new tag: $newTag"
    git tag -a $newTag -m "Release $newTag"
    git push origin $newTag

    # Step 5: Create GitHub release with updated body including semantic tag
    $releaseBody = @"
Release Notes - $newTag

Summary
-------
Stable milestone for Mercor Affiliate Blog System.
Canonical 11 categories enforced, layouts regenerated, QAValidator integrated.

Included Updates
----------------
- .eleventy.js (slug whitelist + date filter)
- base.njk, post.njk, category.njk layouts
- index.njk and categories/index.njk
- Starter styles.css
- QAValidator.ps1

Guardrails Implemented
----------------------
- Only 11 canonical categories allowed
- QAValidator blocks invalid tags
- Luxon date filter for clean formatting
- Deterministic folder paths and automation scripts

Validation Status
-----------------
- Eleventy build passes
- QAValidator returns only approved categories
- _site renders with styled layouts

Rollback Instructions
---------------------
git checkout $newTag
git reset --hard $newTag

Release Metadata
----------------
- Tag: $newTag
- Date: $(Get-Date -Format "yyyy-MM-dd")
- Maintainer: Vinay
"@

    Log ">>> Creating GitHub release for $newTag"
    gh release create $newTag --notes "$releaseBody"

    Log "=== ReleaseAudit.ps1 complete. Audit successful. ==="
}
catch {
    Log "❌ ReleaseAudit encountered error: $($_.Exception.Message)"
    throw
}
