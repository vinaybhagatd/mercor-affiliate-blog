param(
    [switch]$ExecuteMode,
    [switch]$DryRunMode
)

$logFile = "orchestrator.log"

function Log($text) {
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $line = "$timestamp - $text"
    $line | Out-File -FilePath $logFile -Append
}

function Run-Agent($scriptName, $args) {
    Log ("Running " + $scriptName)
    if ($DryRunMode) {
        Write-Output ("Would run: " + $scriptName + " " + ($args -join " "))
        Log ("Would run: " + $scriptName + " " + ($args -join " "))
        return 0
    }
    elseif ($ExecuteMode) {
        try {
            & ".\$scriptName" @args
            $exitCode = $LASTEXITCODE
            if ($exitCode -eq 0) {
                Log ($scriptName + " completed successfully.")
            } else {
                Log ($scriptName + " failed with exit code " + $exitCode)
            }
            return $exitCode
        }
        catch {
            $errMsg = $_.Exception.Message
            Log ("Error in " + $scriptName + ": " + $errMsg)
            Write-Output ("Error in " + $scriptName + ": " + $errMsg)
            return 1
        }
    }
    else {
        Write-Output ("[REVIEW MODE] " + $scriptName + " logged only.")
        Log ("[REVIEW MODE] " + $scriptName + " logged only.")
        return 0
    }
}

# === Orchestration Sequence ===
try {
    Log "=== NEW RUN ==="
    Log "Starting Orchestrator pipeline..."

    Run-Agent "CreateBlog.ps1" @()
    Run-Agent "SEOAgent.ps1" @()
    Run-Agent "UIAgent.ps1" @()
    Run-Agent "DocsAgent.ps1" @()
    Run-Agent "ArchitectAgent.ps1" @()
    Run-Agent "RefactorerAgent.ps1" @()
    Run-Agent "PerformanceAgent.ps1" @()
    Run-Agent "SecurityAgent.ps1" @()

    # QA loop with retry limit
    $qaPass = $false
    $retryCount = 0
    $maxRetries = 3

    while (-not $qaPass -and $retryCount -lt $maxRetries) {
        $qaExitCode = Run-Agent "QAValidator.ps1" @()
        if ($qaExitCode -eq 0) {
            $qaPass = $true
            Log "QA passed."
        } else {
            Log "QA failed — looping back to Refactorer."
            Run-Agent "RefactorerAgent.ps1" @()
            $retryCount++
        }
    }

    if (-not $qaPass) {
        Log ("QA did not pass after " + $maxRetries + " attempts. Aborting pipeline.")
        Write-Output ("Pipeline aborted: QA failed after " + $maxRetries + " attempts.")
        exit 1
    }

    Run-Agent "CIGatekeeper.ps1" @()

    Log "Pipeline complete."
    Write-Output "Pipeline complete. Results saved to orchestrator.log"
}
catch {
    $errMsg = $_.Exception.Message
    Log ("Error in Orchestrator: " + $errMsg)
    Write-Output ("Error in Orchestrator: " + $errMsg)
}








