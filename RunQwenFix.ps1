<#
.SYNOPSIS
RunQwenFix v16 – Self-healing orchestrator for MABS scripts.

.DESCRIPTION
1. Validates RunQwenFix itself with ScriptAnalyzer.
2. Iterates through repo scripts, applies guardrails.
3. If ScriptAnalyzer finds errors, calls LM Studio (Qwen Coder) for AI repair.
4. Logs all actions with timestamps and debug info.
#>

param(
    [string]$TargetDir = "C:\Users\LMTest\promotional\mercor-affiliate-blog",
    [switch]$All,
    [string]$File
)

function Log {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Output "[RunQwenFix] $timestamp - $Message"
}

# === Self-Check ===
$self = $MyInvocation.MyCommand.Path
$selfResults = Invoke-ScriptAnalyzer -Path $self -Severity Error -ErrorAction SilentlyContinue
if ($selfResults) {
    Log ("RunQwenFix.ps1 has errors, consider AI repair.")
}

# === AI Repair Function ===
function AI-Repair {
    param([string]$filePath)

    if (-not $filePath) {
        Log ("Skipped AI repair: filePath was null.")
        return
    }

    Log ("AI repairing ${filePath} via LM Studio...")
    $content = Get-Content $filePath -Raw
    $prompt = "Repair this PowerShell script for syntax errors and ScriptAnalyzer compliance."

    $body = @{
        model    = "qwen2.5-7b-instruct"
        messages = @(@{ role = "user"; content = $prompt + "`n`n" + $content })
    } | ConvertTo-Json -Depth 3 -Compress

    try {
        $response = Invoke-RestMethod -Uri "http://localhost:1234/v1/chat/completions" `
            -Method Post -Body $body -ContentType "application/json"
        $fixed = $response.choices[0].message.content
        $fixed | Set-Content $filePath
        Log ("${filePath} repaired successfully.")
    } catch {
        Log ("AI repair failed for ${filePath}: $($_.Exception.Message)")
    }
}

# === Guardrail + Validation Function ===
function Analyze-And-Fix {
    param([string]$filePath)

    if (-not $filePath) {
        Log ("Skipped: filePath was null.")
        return
    }

    Log ("DEBUG: Processing $filePath")

    $content = Get-Content $filePath -Raw

    # Guardrails
    $content = $content -replace "^\|+", ""                # Remove stray pipes
    $content = $content -replace "\+=", "+="              # Fix operator spacing
    $content = $content -replace "-Filter\s+\*\.md", '-Filter "*.md"' # Quote wildcards
    $content | Set-Content $filePath

    # Validate
    $results = Invoke-ScriptAnalyzer -Path $filePath -Severity Error -ErrorAction SilentlyContinue
    if (-not $results) {
        Log ("${filePath} passed ScriptAnalyzer validation.")
    } else {
        Log ("${filePath} has errors, invoking AI repair...")
        $results | ForEach-Object { Log ($_.Message) }
        AI-Repair -filePath $filePath
        $results2 = Invoke-ScriptAnalyzer -Path $filePath -Severity Error -ErrorAction SilentlyContinue
        if (-not $results2) {
            Log ("${filePath} passed validation after AI repair.")
        } else {
            Log ("${filePath} still has errors after AI repair.")
        }
    }
}

# === Main Execution ===
if ($All) {
    $files = Get-ChildItem -Path $TargetDir -Recurse | Where-Object { $_.Extension -eq ".ps1" }
    if (-not $files) {
        Log ("No .ps1 files found under $TargetDir")
        return
    }
    foreach ($file in $files) {
        Log ("DEBUG: Found file $($file.FullName)")
        Analyze-And-Fix -filePath $file.FullName
    }
    Log ("Batch repair complete.")
}
elseif ($File) {
    if (Test-Path $File) {
        Log ("DEBUG: Single file mode for $File")
        Analyze-And-Fix -filePath $File
        Log ("Single file repair complete.")
    } else {
        Log ("File not found: ${File}")
    }
}
else {
    Log ("Use -All to repair all scripts or -File <path> to repair a single script.")
}

