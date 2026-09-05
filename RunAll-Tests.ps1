<#
.SYNOPSIS
Full test harness for Mercor Affiliate Blog System (MABS).

.DESCRIPTION
Runs integrity checks, diagnostics, self-heal, orchestrator,
QA validation, Eleventy build, and smoke tests.
Generates a consolidated QAReport.txt.
#>

param(
    [string]$TargetDir = "C:\Users\LMTest\promotional\mercor-affiliate-blog",
    [string]$ReportFile = "QAReport.txt"
)

function Log {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Output "$timestamp - $Message"
    "$timestamp - $Message" | Out-File -FilePath $ReportFile -Append
}

# Reset report
Clear-Content $ReportFile -ErrorAction SilentlyContinue
Log "=== Starting MABS Full Test Harness ==="

# 1. Script Integrity
Log "Running ScriptAnalyzer on all scripts..."
Get-ChildItem -Path $TargetDir -Recurse -Filter "*.ps1" | ForEach-Object {
    $results = Invoke-ScriptAnalyzer -Path $_.FullName -Severity Error -ErrorAction SilentlyContinue
    if (-not $results) {
        Log "PASS: $($_.Name) passed ScriptAnalyzer validation."
    } else {
        Log "FAIL: $($_.Name) has errors:"
        $results | ForEach-Object { Log $_.Message }
    }
}

# 2. Diagnostics
Log "Running diagnostics.ps1..."
if (Test-Path ".\diagnostics.ps1") {
    .\diagnostics.ps1
} else {
    Log "diagnostics.ps1 not found."
}

# 3. Self-Heal Cycle
Log "Running SelfHeal.ps1..."
if (Test-Path ".\SelfHeal.ps1") {
    .\SelfHeal.ps1
} else {
    Log "SelfHeal.ps1 not found."
}

# 4. Orchestrator
Log "Running Orchestrator.ps1..."
if (Test-Path ".\Orchestrator.ps1") {
    .\Orchestrator.ps1
} else {
    Log "Orchestrator.ps1 not found."
}

# 5. QA Validation
Log "Running QAValidator.ps1..."
if (Test-Path ".\QAValidator.ps1") {
    .\QAValidator.ps1
} else {
    Log "QAValidator.ps1 not found."
}

# 6. Eleventy Build
Log "Running Eleventy build..."
try {
    npx eleventy
} catch {
    Log "Eleventy build failed: $($_.Exception.Message)"
}

# 7. Smoke Tests (LM Studio)
Log "Running LM Studio smoke tests..."

function Run-LMStudioTest {
    param([string]$prompt)

    try {
        $body = @{
            model    = "qwen2.5-7b-instruct"
            messages = @(@{ role = "user"; content = $prompt })
        } | ConvertTo-Json -Depth 3 -Compress

        $response = Invoke-RestMethod -Uri "http://localhost:1234/v1/chat/completions" `
            -Method Post `
            -Body $body `
            -ContentType "application/json"

        $output = $response.choices[0].message.content
        Log "LM Studio response to '$prompt': $output"
    }
    catch {
        Log "LM Studio test failed for '$prompt': $($_.Exception.Message)"
    }
}

Run-LMStudioTest "ls"
Run-LMStudioTest "ps"
Run-LMStudioTest "chat"

Log "=== MABS Full Test Harness Complete ==="

