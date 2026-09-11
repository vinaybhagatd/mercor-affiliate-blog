<#
.SYNOPSIS
    GitHub release creation script for Mercor Affiliate Blog System.
.DESCRIPTION
    - Checks GH_TOKEN authentication
    - Validates tag existence before creating
    - Creates annotated tag if missing
    - Pushes tag safely
    - Creates GitHub release via API
    - Skips release creation if it already exists
.NOTES
    Author: Mercor Affiliate Blog System (MABS)
#>

param(
    [string]$RepoOwner     = "vinaybhagatd",
    [string]$RepoName      = "mercor-affiliate-blog",
    [string]$TagName       = "mabs-v16.4",
    [string]$ReleaseTitle  = "Mercor Affiliate Blog Release",
    [string]$ReleaseBody   = "Automated release created by ReleaseAudit.ps1"
)

function Log {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "$timestamp - $Message"
}

try {
    Log "=== Create-Release.ps1 started ==="

    # --- Auth check ---
    if (-not $env:GH_TOKEN) {
        throw "GH_TOKEN not found. Please set GH_TOKEN environment variable."
    }

    $headers = @{
        Authorization = "Bearer $env:GH_TOKEN"
        Accept        = "application/vnd.github+json"
        "User-Agent"  = "MercorAffiliateBlogSystem"
    }

    # --- Check if tag exists ---
    $existingTag = git tag -l $TagName
    if ($existingTag) {
        Log "⚠️ Tag [$TagName] already exists. Skipping tag creation."
    } else {
        Log ">>> Creating new tag: $TagName"
        git tag -a $TagName -m "Release $TagName"
        git push origin $TagName
    }

    # --- Check if release already exists ---
    $existingRelease = Invoke-RestMethod -Uri "https://api.github.com/repos/$RepoOwner/$RepoName/releases/tags/$TagName" `
        -Headers $headers -ErrorAction SilentlyContinue

    if ($existingRelease) {
        Log "⚠️ Release for tag [$TagName] already exists: $($existingRelease.html_url)"
    } else {
        # --- Create release ---
        $releasePayload = @{
            tag_name   = $TagName
            name       = $ReleaseTitle
            body       = $ReleaseBody
            draft      = $false
            prerelease = $false
        } | ConvertTo-Json -Depth 3

        Log ">>> Creating GitHub release for $TagName..."
        $release = Invoke-RestMethod -Uri "https://api.github.com/repos/$RepoOwner/$RepoName/releases" `
            -Method Post -Headers $headers -Body $releasePayload -ErrorAction Stop

        Log "✅ Release created successfully: $($release.html_url)"
    }
}
catch {
    Log "❌ Create-Release.ps1 encountered error: $($_.Exception.Message)"
}
finally {
    Log "=== Create-Release.ps1 complete ==="
}
