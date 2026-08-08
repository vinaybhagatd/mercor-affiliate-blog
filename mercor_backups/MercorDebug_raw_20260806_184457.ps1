$logFile = "mercordebug.log"
$orchestrator = "Orchestrator.ps1"
$backupDir = "orchestrator_backups"
$diffDir = "orchestrator_diffs"
$summaryDir = "orchestrator_summaries"

# === Self-Healing for MercorDebug itself ===
$selfFile = $MyInvocation.MyCommand.Path
$selfBackupDir = "mercor_backups"
if (-not (Test-Path $selfBackupDir)) {
    New-Item -ItemType Directory -Path $selfBackupDir | Out-Null
}

function Log($text) {
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $text" | Out-File -FilePath $logFile -Append
}

function SelfHeal-MercorDebug {
    $content = Get-Content $selfFile -Raw
    $fixed = $false

    $backupFile = Join-Path $selfBackupDir ("MercorDebug_fail_{0}.ps1" -f (Get-Date -Format "yyyyMMdd_HHmmss"))
    Copy-Item $selfFile $backupFile -Force

    Log "=== SELF-HEAL ACTIONS BEGIN ==="

    # Fix unterminated Log/Write-Output strings
    $content = $content -replace 'Log\s*\("([^"]*)$', 'Log "$1"'

    # Escape reserved operators
    $content = $content -replace 'SideIndicator -eq "`<="', 'SideIndicator -eq "`<="'
    $content = $content -replace 'SideIndicator -eq "`=>"','SideIndicator -eq "`=>"'

    # Balance braces
    $openBraces = ([regex]::Matches($content, '{')).Count
    $closeBraces = ([regex]::Matches($content, '}')).Count
    if ($openBraces -gt $closeBraces) {
        $diff = $openBraces - $closeBraces
        $content += "`n" + ("}" * $diff)
        Log "SELF-HEAL FIX: Added $diff closing brace(s)."
        $fixed = $true
    }

    Log "=== SELF-HEAL ACTIONS END ==="

    if ($fixed) {
        Set-Content $selfFile $content
        Write-Output "MercorDebug self-healed. Backup saved to $backupFile"
    }
}

SelfHeal-MercorDebug

# === Orchestrator runner ===
function Run-Orchestrator {
    try {
        Log "Running Orchestrator..."
        & ".\$orchestrator"
        $exitCode = $LASTEXITCODE
        if ($exitCode -eq 0) {
            Log "Orchestrator ran successfully."
            return $true
        } else {
            Log "Orchestrator exited with code $exitCode."
            return $false
        }
    }
    catch {
        $errMsg = $_.Exception.Message
        Log "Error running Orchestrator: $errMsg"
        return $false
    }
}

function Backup-FailedVersion {
    param([int]$attempt)
    $backupFile = Join-Path $backupDir ("Orchestrator_fail{0}.ps1" -f $attempt)
    Copy-Item $orchestrator $backupFile -Force
    Log "Backed up failed Orchestrator to $backupFile"
    return $backupFile
}

function Auto-Fix {
    param([string]$file, [int]$attempt)

    $content = Get-Content $file -Raw
    $fixed = $false

    # Fix unterminated strings
    $pattern = 'Write-Output\s*\("([^"]*)$'
    if ($content -match $pattern) {
        $content = $content -replace $pattern, 'Write-Output ("$1")'
        Log "Fixed unterminated string in Write-Output."
        $fixed = $true
    }

    # Ensure try/catch alignment
    $tryCount = ([regex]::Matches($content, 'try\s*{')).Count
    $catchCount = ([regex]::Matches($content, 'catch\s*{')).Count
    if ($tryCount -gt $catchCount) {
        $content += "`ncatch { Write-Output 'Generic catch added by MercorDebug'; }"
        Log "Added missing catch block."
        $fixed = $true
    }

    # Ensure braces balanced
    $openBraces = ([regex]::Matches($content, '{')).Count
    $closeBraces = ([regex]::Matches($content, '}')).Count
    if ($openBraces -gt $closeBraces) {
        $diff = $openBraces - $closeBraces
        $content += "`n" + ("}" * $diff)
        Log "Added $diff closing brace(s)."
        $fixed = $true
    }

    if (-not $fixed) {
        Log "No auto-fix applied — possible deeper logic error."
    }

    Set-Content $file $content
    Log "Applied auto-fixes to $file."

    $backupFile = Join-Path $backupDir ("Orchestrator_fail{0}.ps1" -f $attempt)
    $diffFile = Join-Path $diffDir ("diff_attempt{0}.txt" -f $attempt)

    $backupContent = Get-Content $backupFile
    $fixedContent = Get-Content $file

    $diff = Compare-Object -ReferenceObject $backupContent -DifferenceObject $fixedContent -IncludeEqual:$false |
        ForEach-Object {
            if ($_.SideIndicator -eq "`<=") {
                "REMOVED: " + $_.InputObject
            } elseif ($_.SideIndicator -eq "`=>") {
                "ADDED:   " + $_.InputObject
            }
        }

    $diff | Out-File $diffFile
    Log "Diff log written to $diffFile"
    return $diffFile
}

# === Main Loop ===
$maxAttempts = 10
$attempt = 0
$success = $false
$summary = @()

while (-not $success -and $attempt -lt $maxAttempts) {
    $attempt++
    Log "Attempt $attempt..."
    $success = Run-Orchestrator
    if (-not $success) {
        $backupFile = Backup-FailedVersion -attempt $attempt
        Log "Orchestrator failed. Applying auto-fix..."
        $diffFile = Auto-Fix -file $orchestrator -attempt $attempt
        $summary += [PSCustomObject]@{
            Attempt     = $attempt
            BackupFile  = $backupFile
            DiffFile    = $diffFile
        }
    }
    Start-Sleep -Seconds 2
}

# === Summary Report ===
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$summaryFile = Join-Path $summaryDir ("summary_{0}.txt" -f $timestamp)

$summaryHeader = "`n=== MercorDebug Summary Report ($timestamp) ==="
Write-Output $summaryHeader
Log $summaryHeader
$summaryHeader | Out-File $summaryFile -Append

foreach ($entry in $summary) {
    $line = "Attempt $($entry.Attempt): Backup=$($entry.BackupFile), Diff=$($entry.DiffFile)"
    Write-Output $line
    Log $line
    $line | Out-File $summaryFile -Append
}

$summaryFooter = "==================================="
Write-Output $summaryFooter
Log $summaryFooter
$summaryFooter | Out-File $summaryFile -Append

# Final status line + exit code
if ($success) {
    $statusLine = "FINAL STATUS: SUCCESS after $attempt attempt(s)"
    $exitCode = 0
} else {
    $statusLine = "FINAL STATUS: FAILED after $attempt attempt(s)"
    $exitCode = 1
}

Write-Output $statusLine
Log $statusLine
$statusLine | Out-File $summaryFile -Append

Write-Output "Master summary written to $summaryFile"
Log ("Master summary written to $summaryFile")

exit $exitCode

