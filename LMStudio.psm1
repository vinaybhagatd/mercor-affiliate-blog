# LMStudio.psm1
# Functions for interacting with LM Studio (Qwen3-Coder 8B) and Ollama (Hermes-3)

function Send-LMStudioRequest {
    param(
        [string]$Prompt,
        [string]$Model = "md-coder-qwen3-8b",
        [string]$Endpoint = "http://localhost:1234/v1/chat/completions"
    )

    $headers = @{ "Content-Type" = "application/json" }
    $body = @{
        model = $Model
        messages = @(
            @{ role = "system"; content = "You are a helpful coding assistant." },
            @{ role = "user"; content = $Prompt }
        )
        stream = $false
    } | ConvertTo-Json -Depth 3 -Compress

    try {
        $response = Invoke-RestMethod -Uri $Endpoint -Method Post -Headers $headers -Body $body
        return $response.choices[0].message.content
    }
    catch {
        Write-Error "Error calling LM Studio API: $($_.Exception.Message)"
    }
}

function Send-OllamaRequest {
    param(
        [string]$Prompt,
        [string]$Model = "hermes-3",
        [string]$Endpoint = "http://localhost:11434/v1/chat/completions"
    )

    $headers = @{ "Content-Type" = "application/json" }
    $body = @{
        model = $Model
        messages = @(
            @{ role = "system"; content = "You are a code fixer agent that applies corrections to source files." },
            @{ role = "user"; content = $Prompt }
        )
        stream = $false
    } | ConvertTo-Json -Depth 3 -Compress

    try {
        $response = Invoke-RestMethod -Uri $Endpoint -Method Post -Headers $headers -Body $body
        return $response.choices[0].message.content
    }
    catch {
        Write-Error "Error calling Ollama API: $($_.Exception.Message)"
    }
}

function Run-QwenHermesPipeline {
    param(
        [string]$BuildLog,
        [string]$LogDirectory = "C:\Users\LMTest\promotional\mercor-affiliate-blog\pipeline-logs",
        [switch]$OpenInNotepad
    )

    # Ensure log directory exists
    if (-not (Test-Path $LogDirectory)) {
        New-Item -ItemType Directory -Path $LogDirectory | Out-Null
    }

    # Create timestamped log file
    $timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
    $logFile = Join-Path $LogDirectory "pipeline-$timestamp.log"

    Write-Output "=== Qwen Analysis ==="
    $qwenPlan = Send-LMStudioRequest -Prompt $BuildLog
    Write-Output $qwenPlan

    Write-Output "`n=== Hermes Fix Plan ==="
    $hermesPlan = Send-OllamaRequest -Prompt $qwenPlan
    Write-Output $hermesPlan

    # Determine summary status
    $summary = "Summary: "
    if ($qwenPlan -and $hermesPlan) {
        $summary += "Qwen analysis SUCCESS, Hermes fixes SUCCESS."
    }
    elseif ($qwenPlan -and -not $hermesPlan) {
        $summary += "Qwen analysis SUCCESS, Hermes fixes FAILED."
    }
    elseif (-not $qwenPlan -and $hermesPlan) {
        $summary += "Qwen analysis FAILED, Hermes fixes SUCCESS."
    }
    else {
        $summary += "Both Qwen and Hermes FAILED."
    }

    # Save outputs + summary to log file
    $logContent = @"
=== Pipeline Run ($timestamp) ===

    Write-Output "=== Qwen Analysis ==="
    $qwenPlan = Send-LMStudioRequest -Prompt $BuildLog
    Write-Output $qwenPlan

    Write-Output "`n=== Hermes Fix Plan ==="
    $hermesPlan = Send-OllamaRequest -Prompt $qwenPlan
    Write-Output $hermesPlan

$summary
"@

    $logContent | Out-File -FilePath $logFile -Encoding UTF8

    Write-Output "`nPipeline results saved to $logFile"
    Write-Output $summary

    # Optionally open in Notepad
    if ($OpenInNotepad) {
        Start-Process notepad.exe $logFile
    }
}

Export-ModuleMember -Function Send-LMStudioRequest, Send-OllamaRequest, Run-QwenHermesPipeline
