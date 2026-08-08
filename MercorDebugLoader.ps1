# MercorDebugLoader.ps1
# Loader script to verify MercorDebug + Orchestrator + subscripts

$projectPath = "C:\Users\LMTest\promotional\mercor-affiliate-blog"
$debugLog    = Join-Path $projectPath "mercordebug.log"
$diagLog     = Join-Path $projectPath "diagnostics.log"
$createLog   = Join-Path $projectPath "createblog.log"
$orchLog     = Join-Path $projectPath "orchestrator.log"
$summaryDir  = Join-Path $projectPath "orchestrator_summaries"

Write-Output "=== MercorDebugLoader starting ==="

# Run MercorDebug.ps1 (which calls Orchestrator)
try {
    & (Join-Path $projectPath "MercorDebug.ps1") -LogFile $debugLog
    Write-Output "MercorDebug.ps1 executed."
} catch {
    Write-Output "Error running MercorDebug.ps1: $($_.Exception.Message)"
}

# Verify logs exist
$logs = @($debugLog,$diagLog,$createLog,$orchLog)
foreach ($log in $logs) {
    if (Test-Path $log) {
        Write-Output "Log verified: $log"
    } else {
        Write-Output "Missing log: $log"
    }
}

# Verify summary files exist
if (Test-Path $summaryDir) {
    $summaries = Get-ChildItem -Path $summaryDir -Filter "summary_*.txt"
    if ($summaries.Count -gt 0) {
        Write-Output "Summary files verified: $($summaries.Count) found."
    } else {
        Write-Output "No summary files found in $summaryDir"
    }
} else {
    Write-Output "Summary directory missing: $summaryDir"
}

Write-Output "=== MercorDebugLoader complete ==="
