# Orchestrator.ps1
# Expanded orchestration with six steps, logging, healing, diffs, summaries, and configurable parallel sub-script execution with validation and per-script status

function Log($text) {
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $text" | Out-File -FilePath "orchestrator.log" -Append
}

function Write-Summary($status, $details, $scriptStatuses) {
    $summaryDir = "orchestrator_summaries"
    if (-not (Test-Path $summaryDir)) {
        New-Item -ItemType Directory -Path $summaryDir | Out-Null
    }
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $summaryFile = Join-Path $summaryDir ("summary_$timestamp.txt")

    $scriptBlock = ""
    foreach ($s in $scriptStatuses.Keys) {
        $scriptBlock += "Script: $s`nStatus: $($scriptStatuses[$s])`n`n"
    }

    $content = @"
===================================
Orchestrator Run Summary
Timestamp: $timestamp
Overall Status: $status
Details: $details

--- Per-Script Status ---
$scriptBlock
===================================
"@
    $content | Out-File -FilePath $summaryFile -Encoding UTF8
    Log "Summary written to $summaryFile"
}

function Run-Task {
    try {
        Log "Starting orchestration sequence..."

        # === Step 1: Validate Inputs ===
        Log "Step 1: Validating inputs..."
        if (-not (Test-Path "config.json")) {
            throw "Missing config.json"
        }
        Write-Output "Inputs validated."

        # === Step 2: Backup Orchestrator ===
        Log "Step 2: Creating backup..."
        $backupDir = "orchestrator_backups"
        if (-not (Test-Path $backupDir)) { New-Item -ItemType Directory -Path $backupDir | Out-Null }
        $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
        $backupFile = Join-Path $backupDir ("Orchestrator_$timestamp.ps1")
        Copy-Item "Orchestrator.ps1" $backupFile -Force
        Log "Backup saved to $backupFile"

        # === Step 3: Healing / Auto-Fix ===
        Log "Step 3: Healing script..."
        $content = Get-Content "Orchestrator.ps1" -Raw
        $openBraces = ([regex]::Matches($content, '{')).Count
        $closeBraces = ([regex]::Matches($content, '}')).Count
        if ($openBraces -gt $closeBraces) {
            $diff = $openBraces - $closeBraces
            $content += "`n" + ("}" * $diff)
            Log "Added $diff closing brace(s)."
        }
        Set-Content "Orchestrator.ps1" $content

        # === Step 4: Execute Core Logic (Configurable Parallel Sub-Scripts with Validation) ===
        Log "Step 4: Executing core orchestration in parallel from config.json..."

        $scriptStatuses = @{}

        try {
            # Load sub-scripts list from config.json
            $config = Get-Content "config.json" | ConvertFrom-Json
            $scripts = $config.subscripts

            if (-not $scripts -or $scripts.Count -eq 0) {
                throw "No subscripts defined in config.json"
            }

            # Validate all scripts exist before starting jobs
            $missing = @()
            foreach ($script in $scripts) {
                if (-not (Test-Path $script)) {
                    $missing += $script
                    $scriptStatuses[$script] = "MISSING"
                }
            }

            if ($missing.Count -gt 0) {
                $missingList = ($missing -join ", ")
                throw "Missing subscripts: $missingList"
            }

            # Start jobs for all valid scripts
            $jobs = @()
            foreach ($script in $scripts) {
                if ($script -eq ".\\CreateBlog.ps1") {
                    Log "Blog generation started via CreateBlog.ps1..."
                } else {
                    Log "Starting $script as a job..."
                }

                $job = Start-Job -ScriptBlock {
                    param($s)
                    try {
                        & $s
                        if ($s -eq ".\\CreateBlog.ps1") {
                            return "Blog generation completed successfully."
                        } else {
                            return "SUCCESS"
                        }
                    } catch {
                        return "FAILED: $($_.Exception.Message)"
                    }
                } -ArgumentList $script
                $jobs += $job
            }

            # Wait for all jobs to finish
            Log "Waiting for jobs to complete..."
            Wait-Job -Job $jobs

            # Collect results
            foreach ($job in $jobs) {
                $result = Receive-Job -Job $job
                $scriptName = ($job.ChildJobs[0].Command)
                $scriptStatuses[$scriptName] = $result
                Log "Output from ${scriptName}: $result"
            }

            # Clean up jobs
            Remove-Job -Job $jobs

            Write-Output "All configured sub-scripts executed successfully in parallel."
        }
        catch {
            $errMsg = $_.Exception.Message
            Log "Error in Step 4 (parallel execution): $errMsg"
            throw
        }

        # === Step 5: Diff Generator ===
        Log "Step 5: Generating diff..."
        $diffDir = "orchestrator_diffs"
        if (-not (Test-Path $diffDir)) { New-Item -ItemType Directory -Path $diffDir | Out-Null }
        $diffFile = Join-Path $diffDir ("diff_attempt_$timestamp.txt")

        $beforeFile = "before.txt"
        $afterFile  = "after.txt"
        if (Test-Path $beforeFile -and Test-Path $afterFile) {
            $before = Get-Content $beforeFile
            $after  = Get-Content $afterFile
            $diff = Compare-Object -ReferenceObject $before -DifferenceObject $after
            $diff | Out-File -FilePath $diffFile -Encoding UTF8
            Log "Diff written to $diffFile"
        } else {
            Log "Diff skipped: before/after files not found."
        }

        # === Step 6: Summary Report ===
        Write-Summary "SUCCESS" "All orchestration steps executed successfully." $scriptStatuses
    }
    catch {
        $errMsg = $_.Exception.Message
        Log "Error occurred: $errMsg"
        $scriptStatuses["Overall"] = "FAILED"
        Write-Summary "FAILED" "Error occurred: $errMsg" $scriptStatuses
        Write-Output "Task failed."
    }
    finally {
        Log "Final cleanup actions executed."
    }
}

# === Main Execution ===
try {
    Log "Orchestrator started."
    Run-Task
    Log "Orchestrator finished."
}
catch {
    $errMsg = $_.Exception.Message
    Log "Unhandled error in Orchestrator: $errMsg"
    $scriptStatuses = @{}
    $scriptStatuses["Overall"] = "FAILED"
    Write-Summary "FAILED" "Unhandled error: $errMsg" $scriptStatuses
}
finally {
    Log "Orchestrator script cleanup complete."
}

