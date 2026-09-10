<#
.SYNOPSIS
Analyze-And-Fix v2 – Auto-retry repair loop for PowerShell scripts.

.DESCRIPTION
Runs PSScriptAnalyzer on a target script. If errors are found, retries repair
using Qwen Coder until the script passes validation or max retries reached.
#>

param(
    [string]$FilePath,
    [int]$MaxRetries = 3
)

function Log {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Output "[Analyze-And-Fix] $timestamp - $Message"
}

function Run-Analyzer {
    param([string]$Path)
    try {
        return Invoke-ScriptAnalyzer -Path $Path -Severity Error -ErrorAction SilentlyContinue
    } catch {
        Log ("Analyzer failed: $($_.Exception.Message)")
        return @()
    }
}

function AI-Repair {
    param([string]$Path)
    $content = Get-Content $Path -Raw
    $prompt = @"
Repair this PowerShell script for syntax errors and ScriptAnalyzer compliance.
Ensure:
- Function calls use parentheses (Log("message"))
- Param blocks use newlines or semicolons, not commas
- Wildcards quoted ("*.md")
- Unicode escapes use `u{XXXX}
- Wrap stray numbered lines inside comments
Return corrected script only.
"@
    $body = @{
        model    = "qwen2.5-7b-instruct"
        messages = @(@{ role = "user"; content = $prompt + "`n`n" + $content })
    } | ConvertTo-Json -Depth 3 -Compress

    try {
        $response = Invoke-RestMethod -Uri "http://localhost:1234/v1/chat/completions" `
            -Method Post -Body $body -ContentType "application/json"
        $fixed = $response.choices[0].message.content
        $fixed | Set-Content $Path
        Log ("AI repair applied to $Path")
    } catch {
        Log ("AI repair failed: $($_.Exception.Message)")
    }
}

# === Main Loop ===
if (-not (Test-Path $FilePath)) {
    Log ("File not found: $FilePath")
    exit 1
}

Log ("Starting analysis for $FilePath")
$retry = 0
while ($retry -lt $MaxRetries) {
    $results = Run-Analyzer -Path $FilePath
    if (-not $results) {
        Log ("$FilePath passed ScriptAnalyzer validation.")
        break
    } else {
        Log ("Errors detected in $FilePath:")
        $results | ForEach-Object { Log ($_.Message) }
        $retry++
        Log ("Attempting AI repair (retry $retry of $MaxRetries)...")
        AI-Repair -Path $FilePath
    }
}

if ($retry -eq $MaxRetries) {
    $results = Run-Analyzer -Path $FilePath
    if ($results) {
        Log ("$FilePath still has errors after $MaxRetries retries.")
    } else {
        Log ("$FilePath passed validation after final retry.")
    }
}
