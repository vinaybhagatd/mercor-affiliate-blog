<#
.SYNOPSIS
    Hardened GitHub release creation script for Mercor Affiliate Blog System.
.DESCRIPTION
    - Checks for GH_TOKEN or GitHub CLI authentication
    - Validates tag existence before creating
    - Creates annotated tag if missing
    - Pushes tag safely
    - Calls GitHub API to create release
    - Provides clear error handling and logging
.NOTES
    Author: Mercor Affiliate Blog System (MABS)
#>

param(
    [string]$RepoOwner = "vinaybhagatd",
    [string]$RepoName  = "mercor-affiliate-blog",
    [string]$TagName   = "mabs-v16.4",
    [string]$ReleaseTitle = "Mercor Affiliate Blog Release",
    [string]$ReleaseBody  = "Automated release created by ReleaseAudit.ps1"
)

function Log {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "$timestamp - $Message"
}

try {
    Log "=== Create-Release.ps1 started ==="

    # --- Check authentication ---
    if (-not $env:GH_TOKEN) {
        Log "⚠️ GH_TOKEN not found. Attempting GitHub CLI authentication..."
        if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
            throw "GitHub CLI not installed. Install from https://cli.github.com/"
        }
        gh auth status 2>$null
        if ($LASTEXITCODE -ne 0) {
            Log "⚠️ GitHub CLI not authenticated. Run 'gh auth login' before retrying."
            throw "Authentication required."
        }
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

    # --- Create release via GitHub API ---
    $headers = @{
        Authorization = "Bearer $env:GH_TOKEN"
        Accept        = "application/vnd.github+json"
        "User-Agent"  = "MercorAffiliateBlogSystem"
    }

    $releasePayload = @{
        tag_name   = $TagName
        name       = $ReleaseTitle
        body       = $ReleaseBody
        draft      = $false
        prerelease = $false
    } | ConvertTo-Json -Depth 3

    Log ">>> Creating GitHub release for $TagName..."
    $response = Invoke-RestMethod -Uri "https://api.github.com/repos/$RepoOwner/$RepoName/releases" `
        -Method Post -Headers $headers -Body $releasePayload -ErrorAction Stop

    Log "✅ Release created successfully: $($response.html_url)"
}
catch {
    Log "❌ Create-Release.ps1 encountered error: $($_.Exception.Message)"
}
finally {
    Log "=== Create-Release.ps1 complete ==="
}
