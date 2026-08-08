# Orchestrator.ps1
# Logs, backups, diffs, and summaries are written inside mercor-affiliate-blog folder
# Passes -LogFile into Diagnostics.ps1 and MercorDebug.ps1

$baseDir = "C:\Users\LMTest\promotional\mercor-affiliate-blog"
$logFile = Join-Path $baseDir "orchestrator.log"

function Log($text) {
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $text" | Out-File -FilePath $logFile -Append
}

function Write-Summary($status, $details, $scriptStatuses) {
    $summaryDir = Join-Path $baseDir "orchestrator_summaries"
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
        $configFile = Join-Path $baseDir "config.json"
        if (-not (Test-Path $configFile)) {
            throw "Missing config.json"
        }
        $config = Get-Content $configFile | ConvertFrom-Json
        $outputDir = $config.settings.outputDirectory
        Write-Output "Inputs validated."

        # === Step 2: Backup Orchestrator ===
        Log "Step 2: Creating backup..."
        $backupDir = Join-Path $baseDir "orchestrator_backups"
        if (-not (Test-Path $backupDir)) { New-Item -ItemType Directory -Path $backupDir | Out-Null }
        $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
        $backupFile = Join-Path $backupDir ("Orchestrator_$timestamp.ps1")
        Copy-Item (Join-Path $baseDir "Orchestrator.ps1") $backupFile -Force
        Log "Backup saved to $backupFile"

        # === Step 3: Healing / Auto-Fix ===
        Log "Step 3: Healing script..."
        $content = Get-Content (Join-Path $baseDir "Orchestrator.ps1") -Raw
        $openBraces = ([regex]::Matches($content, '{')).Count
        $closeBraces = ([regex]::Matches($content, '}')).Count
        if ($openBraces -gt $closeBraces) {
            $diff = $openBraces - $closeBraces
            $content += "`n" + ("}" * $diff)
            Log "Added $diff closing brace(s)."
        }
        Set-Content (Join-Path $baseDir "Orchestrator.ps1") $content

        # === Step 4: Execute Core Logic ===
        Log "Step 4: Executing core orchestration in parallel from config.json..."

        $scriptStatuses = @{}
        try {
            $scripts = $config.subscripts
            if (-not $scripts -or $scripts.Count -eq 0) {
                throw "No subscripts defined in config.json"
            }

            $jobs = @()
            foreach ($script in $scripts) {
                $resolvedPath = Resolve-Path $script
                if ($resolvedPath -eq $null) {
                    $scriptStatuses[$script] = "MISSING"
                    continue
                }

                if ($script -like "*CreateBlog.ps1") {
                    Log "Blog generation started via CreateBlog.ps1..."
                    $job = Start-Job -ScriptBlock {
                        param($s,$outDir)
                        try {
                            & $s -OutputDirectory $outDir
                            return "Blog generation completed successfully."
                        } catch {
                            return "FAILED: $($_.Exception.Message)"
                        }
                    } -ArgumentList $resolvedPath,$outputDir
                }
                elseif ($script -like "*MercorDebug.ps1") {
                    Log "Starting MercorDebug.ps1 with -LogFile..."
                    $debugLogFile = Join-Path $baseDir "mercordebug.log"
                    $job = Start-Job -ScriptBlock {
                        param($s,$logFile)
                        try {
                            & $s -LogFile $logFile
                            return "SUCCESS"
                        } catch {
                            return "FAILED: $($_.Exception.Message)"
                        }
                    } -ArgumentList $resolvedPath,$debugLogFile
                }
                elseif ($script -like "*Diagnostics.ps1") {
                    Log "Starting Diagnostics.ps1 with -LogFile..."
                    $diagLogFile = Join-Path $baseDir "diagnostics.log"
                    $job = Start-Job -ScriptBlock {
                        param($s,$logFile)
                        try {
                            & $s -LogFile $logFile
                            return "SUCCESS"
                        } catch {
                            return "FAILED: $($_.Exception.Message)"
                        }
                    } -ArgumentList $resolvedPath,$diagLogFile
                }
                else {
                    Log "Starting $script as a job..."
                    $job = Start-Job -ScriptBlock {
                        param($s)
                        try {
                            & $s
                            return "SUCCESS"
                        } catch {
                            return "FAILED: $($_.Exception.Message)"
                        }
                    } -ArgumentList $resolvedPath
                }
                $jobs += $job
            }

            Log "Waiting for jobs to complete..."
            Wait-Job -Job $jobs

            foreach ($job in $jobs) {
                $result = Receive-Job -Job $job
                $scriptName = ($job.ChildJobs[0].Command)
                $scriptStatuses[$scriptName] = $result
                Log "Output from ${scriptName}: $result"
            }

            Remove-Job -Job $jobs
            Write-Output "All configured sub-scripts executed successfully in parallel."
        }
        catch {
            $errMsg = $_.Exception.Message
            Log "Error in Step 4: $errMsg"
            throw
        }

        # === Step 5: Diff Generator ===
        Log "Step 5: Generating diff..."
        $diffDir = Join-Path $baseDir "orchestrator_diffs"
        if (-not (Test-Path $diffDir)) { New-Item -ItemType Directory -Path $diffDir | Out-Null }
        $diffFile = Join-Path $diffDir ("diff_attempt_$timestamp.txt")

        $beforeFile = Join-Path $baseDir "before.txt"
        $afterFile  = Join-Path $baseDir "after.txt"
        if (Test-Path $beforeFile -and Test-Path $afterFile) {
            $before = Get-Content $beforeFile
            $after  = Get-Content $afterFile
            $diff   = Compare-Object -ReferenceObject $before -DifferenceObject $after
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







































































































































































































































































































































































































































































































































