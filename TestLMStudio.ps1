<#
.SYNOPSIS
TestLMStudio.ps1
Runs a single prompt against LM Studio CLI to verify connectivity and output.
#>

# Path to LM Studio CLI
$lmStudioPath = "C:\Users\LMTest\.lmstudio\bin\lms.exe"

# Model name (must match what `lms.exe ls` shows as LOADED)
$model = "md-coder-qwen3-8b"

# Test prompt
$prompt = "Write a 50-word story about a remote creative professional."

Write-Host "🔄 Running test prompt against $model..."
$result = & $lmStudioPath chat $model -p $prompt

Write-Host "✅ Output received:"
Write-Output $result
