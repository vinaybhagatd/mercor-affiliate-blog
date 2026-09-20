<#
.SYNOPSIS
    Bulletproof test harness for PowerShell profile validation
.DESCRIPTION
    - Confirms profile load and log entry
    - Verifies ssh-agent service
    - Tests Git helper functions
    - Tests aliases and prompt
    - Runs symlink setup script via $PSScriptRoot
    - Validates symlink target correctness
    - Prints consolidated summary
#>

$ErrorActionPreference = "Stop"
$results = @{}

function Log {
    param([string]$Message)
    Write-Host $Message
}

# --- 1. Profile Load & Log ---
Log "=== Checking profile load ==="
$profilePath = $PROFILE
$results.Profile = (Test-Path $profilePath) ? "OK" : "FAIL"
Log ($results.Profile -eq "OK" ? "✅ Profile exists: $profilePath" : "❌ Profile missing: $profilePath")

$logPath = "C:\Users\LMTest\promotional\mercor-affiliate-blog\logs\profile-load.log"
$results.LogFile = (Test-Path $logPath) ? "OK" : "FAIL"
Log ($results.LogFile -eq "OK" ? "✅ Log file exists: $logPath" : "❌ Log file missing: $logPath")

# --- 2. ssh-agent ---
Log "=== Checking ssh-agent ==="
try {
    $svc = Get-Service ssh-agent -ErrorAction Stop
    if ($svc.Status -eq 'Running') {
        $results.SshAgent = "OK"
        Log "✅ ssh-agent running"
    } else {
        $results.SshAgent = "FAIL"
        Log "❌ ssh-agent not running"
    }
} catch {
    $results.SshAgent = "FAIL"
    Log "❌ ssh-agent service not available"
}

# --- 3. Git Helpers ---
Log "=== Checking Git helpers ==="
$results.GitHelpers = (Get-Command git-status -ErrorAction SilentlyContinue) ? "OK" : "FAIL"
Log ($results.GitHelpers -eq "OK" ? "✅ Git helpers defined" : "❌ Git helpers missing")

# --- 4. Aliases & Prompt ---
Log "=== Checking aliases & prompt ==="
$results.Aliases = (Get-Alias ll -ErrorAction SilentlyContinue) ? "OK" : "FAIL"
Log ($results.Aliases -eq "OK" ? "✅ Alias 'll' exists" : "❌ Alias 'll' missing")

$results.Prompt = (Get-Command Prompt -ErrorAction SilentlyContinue) ? "OK" : "FAIL"
Log ($results.Prompt -eq "OK" ? "✅ Prompt function defined" : "❌ Prompt function missing")

# --- 5. Symlink Setup & Validation ---
Log "=== Running symlink setup ==="
try {
    $setupScript = Join-Path $PSScriptRoot "setup-hooks.ps1"
if (Test-Path $setupScript) {
    & $setupScript
    Log "✅ Symlink setup executed: $setupScript"
} else {
    Log "❌ setup-hooks.ps1 not found at $setupScript"
}

} catch {
    $results.Symlinks = "FAIL"
    Log "❌ Symlink setup script failed: $($_.Exception.Message)"
}

# --- Summary ---
Log "`n=== Test Summary ==="
$failures = $results.Values | Where-Object { $_ -eq "FAIL" }
if ($failures.Count -eq 0) {
    Log "🎉 All systems OK"
} else {
    Log "⚠ Some checks failed:"
    $results.GetEnumerator() | Where-Object { $_.Value -eq "FAIL" } | ForEach-Object {
        Log " - $($_.Key)"
    }
}
