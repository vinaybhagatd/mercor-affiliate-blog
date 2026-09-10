<#
.SYNOPSIS
MasterHarness v13 – Unified orchestrator for MABS scripts.

.DESCRIPTION
Integrates Analyze-And-Fix auto-retry loop (Qwen Coder + PSScriptAnalyzer).
Fixes parser issues with Unicode escapes and variable interpolation.
Uses script-scope counters instead of global variables.
Modes:
- -All: batch repair + self-heal
- -RepairOnly: batch repair only
- -SelfHealOnly: self-heal only
- -File <path>: repair a single script
Adds summary reporting at the end.
#>

param(
    [string]$TargetDir = "C:\Users\LMTest\promotional\mercor-affiliate-blog",
    [switch]$All,
    [switch]$RepairOnly,
    [switch]$SelfHealOnly,
    [string]$File,
    [int]$MaxRetries = 3
)

# Counters for summary (script-scope)
$script:RepairedCount = 0
$script:SkippedCount = 0
$script:ErrorCount   = 0

function Log {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Output "[MasterHarness] $timestamp - $Message"
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
- Unicode escapes use UNICODE_ESCAPE
- Wrap stray numbered lines inside comments
Return corrected script only.
Note: UNICODE_ESCAPE means PowerShell-compliant Unicode escape in the form u{XXXX}.
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
        $script:RepairedCount++
        Log ("AI repair applied to $Path")
    } catch {
        $script:ErrorCount++
        Log ("AI repair failed: $($_.Exception.Message)")
    }
}

function Analyze-And-Fix {
    param([string]$filePath, [int]$MaxRetries = 3)
    if (-not $filePath) { $script:SkippedCount++; Log ("Skipped: filePath was null."); return }
    Log ("DEBUG: Processing ${filePath}")

    $retry = 0
    while ($retry -lt $MaxRetries) {
        $results = Run-Analyzer -Path $filePath
        if (-not $results) {
            $script:RepairedCount++
            Log ("${filePath} passed ScriptAnalyzer validation.")
            break
        } else {
            Log ("Errors detected in ${filePath}:")
            $results | ForEach-Object { Log ($_.Message) }
            $retry++
            Log ("Attempting AI repair (retry $retry of $MaxRetries)...")
            AI-Repair -Path $filePath
        }
    }

    if ($retry -eq $MaxRetries) {
        $results = Run-Analyzer -Path $filePath
        if ($results) {
            $script:ErrorCount++
            Log ("${filePath} still has errors after $MaxRetries retries.")
        } else {
            $script:RepairedCount++
            Log ("${filePath} passed validation after final retry.")
        }
    }
}

function Process-Files {
    param([array]$files)
    foreach ($file in $files) {
        $path = $file.FullName
        if (-not [string]::IsNullOrWhiteSpace($path)) {
            Log ("DEBUG: Found file $path")
            Analyze-And-Fix -filePath $path -MaxRetries $MaxRetries
        } else {
            $script:SkippedCount++
            Log ("Skipped: filePath was null.")
        }
    }
}

function SelfHeal {
    Log ("Starting MABS Self-Heal Cycle...")
    if (Test-Path ".\diagnostics.ps1") { .\diagnostics.ps1; Log ("Diagnostics complete.") }
    else { Log ("diagnostics.ps1 not found.") }

    $files = Get-ChildItem -Path "." -Recurse -File -Filter *.ps1
    if (-not $files) { Log ("No .ps1 files found under current directory.") }
    else { Process-Files -files $files }

    if (Test-Path ".\Orchestrator.ps1") { .\Orchestrator.ps1; Log ("Orchestrator executed.") }
    else { Log ("Orchestrator.ps1 not found.") }

    Get-ChildItem -Path ".\src\posts" -Filter *.md -Recurse | ForEach-Object {
        $post = Get-Content $_.FullName -Raw
        $post = $post -replace "content:", "body:"
        Set-Content $_.FullName $post
        Log ("Sanitized reserved property in $($_.Name)")
    }

    Get-ChildItem -Path ".\src\_layouts" -Filter *.njk -Recurse | ForEach-Object {
        $layout = Get-Content $_.FullName -Raw
        $layout = $layout -replace "{{\s*content\s*}}", "{{ body }}"
        $layout = $layout -replace "{%\s*block content\s*%}", "{% block body %}"
        $layout = $layout -replace "{%\s*endblock content\s*%}", "{% endblock body %}"
        Set-Content $_.FullName $layout
        Log ("Updated reserved property references in $($_.Name)")
    }

    Log ("MABS Self-Heal + AI Repair complete.")
}

# === Main Execution with Mode Switches ===
if ($RepairOnly) {
    $files = Get-ChildItem -Path $TargetDir -Recurse -File -Filter *.ps1
    if (-not $files) { Log ("No .ps1 files found under $TargetDir") }
    else { Process-Files -files $files }
    Log ("Repair-only mode complete.")
}
elseif ($SelfHealOnly) {
    SelfHeal
}
elseif ($All) {
    $files = Get-ChildItem -Path $TargetDir -Recurse -File -Filter *.ps1
    if (-not $files) { Log ("No .ps1 files found under $TargetDir") }
    else { Process-Files -files $files }
    Log ("Batch repair complete.")
    SelfHeal
}
elseif ($File) {
    if (Test-Path $File) {
        Log ("DEBUG: Single file mode for $File")
        Analyze-And-Fix -filePath $File -MaxRetries $MaxRetries
        Log ("Single file repair complete.")
    } else { Log ("File not found: ${File}") }
}
else {
    Log ("Use -All, -RepairOnly, or -SelfHealOnly to control execution.")
}

# === Summary Report ===
Log ("================ SUMMARY REPORT ================")
Log ("Files repaired : $script:RepairedCount")
Log ("Files skipped  : $script:SkippedCount")
Log ("Errors detected: $script:ErrorCount")
Log ("================================================")
