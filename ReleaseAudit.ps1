<#
.SYNOPSIS
    Release audit wrapper for Mercor Affiliate Blog System.
.DESCRIPTION
    - Runs BulkFix-Posts.ps1 to repair missing categories/affiliate links
    - Runs QAValidator.ps1 with PreReleaseAudit mode to validate all posts
    - Runs RunAll.ps1 to execute the full pipeline (tests + deployment)
    - Consolidates logs into ReleaseAuditReport.txt for permanent audit trail
#>

param(
    [string]$ReportFile = "ReleaseAuditReport.txt"
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

    Log "=== ReleaseAudit.ps1 complete. Audit successful. ==="
}
catch {
    Log "❌ ReleaseAudit encountered error: $($_.Exception.Message)"
    throw
}
