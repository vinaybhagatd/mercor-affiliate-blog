<#
.SYNOPSIS
Self-healing orchestrator for MABS.

.DESCRIPTION
Runs diagnostics → repair → diagnostics → orchestrator.
If ScriptAnalyzer finds errors, calls LM Studio (Qwen Coder) to auto-repair.
Also sanitizes reserved keys in posts and layouts.
#>

param(
    [string]$JsonFolder = ".\BlogData"
    [string]$BlogsFolder = ".\GeneratedBlogs"
    [string]$SiteFolder = ".\mercor-affiliate-blog\_site"
)

function Log {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Output "[SelfHeal] $timestamp - $Message"
}

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

function Validate-And-Repair {
    param([string]$filePath)

    if (-not $filePath) {
        Log ("Skipped: filePath was null.")
        return
    }

    Log ("DEBUG: Processing $filePath")

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

# === Self-Heal Workflow ===
Log ("Starting MABS Self-Heal Cycle...")

# Step 1: Initial Diagnostics
if (Test-Path ".\diagnostics.ps1") {
    .\diagnostics.ps1
    Log ("Diagnostics complete.")
} else {
    Log ("diagnostics.ps1 not found.")
}

# Step 2: Repair all scripts (corrected file discovery)
$files = Get-ChildItem -Path "." -Recurse | Where-Object { $_.Extension -eq ".ps1" }
if (-not $files) {
    Log ("No .ps1 files found under current directory.")
} else {
    foreach ($file in $files) {
        Log ("DEBUG: Found file $($file.FullName)")
        Validate-And-Repair -filePath $file.FullName
    }
}

# Step 3: Run Orchestrator if available
if (Test-Path ".\Orchestrator.ps1") {
    .\Orchestrator.ps1
    Log ("Orchestrator executed.")
} else {
    Log ("Orchestrator.ps1 not found.")
}

# Step 4: Sanitize reserved keys in posts
Get-ChildItem -Path ".\src\posts" -Filter "*.md" -Recurse | ForEach-Object {
    $post = Get-Content $_.FullName -Raw
    $post = $post -replace "content:", "body:"
    Set-Content $_.FullName $post
    Log ("Sanitized reserved property in $($_.Name)")
}

# Step 5: Sanitize reserved keys in layouts
Get-ChildItem -Path ".\src\_layouts" -Filter *.njk -Recurse | ForEach-Object {
    $layout = Get-Content $_.FullName -Raw
    $layout = $layout -replace "{{\s*content\s*}}", "{{ body }}"
    $layout = $layout -replace "{%\s*block content\s*%}", "{% block body %}"
    $layout = $layout -replace "{%\s*endblock content\s*%}", "{% endblock body %}"
    Set-Content $_.FullName $layout
    Log ("Updated reserved property references in $($_.Name)")
}

Log ("MABS Self-Heal + AI Repair complete.")

