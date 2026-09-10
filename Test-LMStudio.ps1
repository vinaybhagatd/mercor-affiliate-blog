<#
.SYNOPSIS
  Smoke test for LM Studio local API.
.DESCRIPTION
  - Probes common LM Studio ports (1234–1236)
  - Confirms if LM Studio is serving models
  - Prints a friendly status message
#>

$ErrorActionPreference = "Stop"

Write-Host "=== Test-LMStudio.ps1 started ===" -ForegroundColor Cyan

$ports = 1234,1235,1236
$found = $false

foreach ($port in $ports) {
    try {
        $url = "http://127.0.0.1:$port/v1/models"
        Write-Host "Testing $url..."
        $response = Invoke-RestMethod -Uri $url -TimeoutSec 5
        if ($response.data) {
            Write-Host "✅ LM Studio is running on port $port" -ForegroundColor Green
            foreach ($model in $response.data) {
                Write-Host "Model available: $($model.id)"
            }
            if ($response.data.id -contains "qwen2.5-coder-1.5b-instruct" -or
                $response.data.id -contains "qwen2.5-7b-instruct") {
                Write-Host "🎉 Qwen is online and ready!" -ForegroundColor Cyan
            }
            $found = $true
            break
        }
    } catch {
        Write-Host "No response on port $port" -ForegroundColor Yellow
    }
}

if (-not $found) {
    Write-Host "❌ LM Studio API not detected on ports 1234–1236." -ForegroundColor Red
    Write-Host "Tip: Start LM Studio, load your model, and enable the local server." -ForegroundColor DarkYellow
}

Write-Host "=== Test-LMStudio.ps1 complete ===" -ForegroundColor Cyan
