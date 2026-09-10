<#
.SYNOPSIS
  Unified test harness for Mercor Affiliate Blog System.
.DESCRIPTION
  - Runs PSScriptAnalyzer on all active PowerShell scripts
  - Executes LM Studio smoke test (ports 1234, 1235, 1236)
  - Prints summary of results
  - Emits structured output for wrapper scripts
#>

$ErrorActionPreference = "Stop"

function Log {
    param([string]$Message)
    # Keep host logging for human readability
    Write-Host $Message
    # Append to QA report file
    Add-Content -Path "QAValidatorReport.txt" -Value $Message
}

Log "=== RunAll-Tests.ps1 started ==="

# -------------------------------
# 1. PowerShell Analyzer Checks
# -------------------------------
Log "Running PSScriptAnalyzer on active scripts..."
$scripts = Get-ChildItem -Path . -Filter *.ps1 -Recurse | Where-Object { -not $_.Name.StartsWith("Cleanup") }

$errors = 0
foreach ($script in $scripts) {
    $results = Invoke-ScriptAnalyzer -Path $script.FullName -Severity Error
    if ($results) {
        Log "❌ Errors in $($script.Name):"
        $results | ForEach-Object { Log "   $($_.RuleName): $($_.Message)" }
        $errors++
    }
    else {
        Log "✅ $($script.Name) passed analyzer checks."
    }
}

# -------------------------------
# 2. LM Studio Smoke Test
# -------------------------------
Log "Running LM Studio smoke test..."
$ports = 1234, 1235, 1236
$lmStudioFound = $false

foreach ($port in $ports) {
    try {
        $url = "http://127.0.0.1:$port/v1/models"
        $response = Invoke-RestMethod -Uri $url -TimeoutSec 5
        if ($response.data) {
            Log "✅ LM Studio is running on port $port"
            foreach ($model in $response.data) {
                Log "Model available: $($model.id)"
            }
            if ($response.data.id -contains "qwen2.5-coder-1.5b-instruct" -or
                $response.data.id -contains "qwen2.5-7b-instruct") {
                Log "🎉 Qwen is online and ready!"
            }
            $lmStudioFound = $true
            break
        }
    }
    catch {
        Log "No response on port $port"
    }
}

if (-not $lmStudioFound) {
    Log "❌ LM Studio API not detected on ports 1234–1236."
    Log "Tip: Start LM Studio, load your model, and enable the local server."
}

# -------------------------------
# 3. Summary (structured output)
# -------------------------------
Write-Output @{
    AnalyzerErrors = $errors
    LMStudioFound  = $lmStudioFound
}
