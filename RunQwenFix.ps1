param([switch]$All)

function Log {
    param([string]$message)
    Write-Host "[RunQwenFix] $message"
}

function Sanitize-Script {
    param([string]$filePath)

    $lines = Get-Content $filePath
    $cleaned = @()

    foreach ($line in $lines) {
        Log ("Line: $line")

        if ($line.Trim() -eq "") {
            Log ("Removed empty line")
            continue
        }

        if ($line -match "^(Great|Certainly|Of course|I'm|This is|Sure!|Happy to|Here|Thank|Please|Summary|Conversation|ChatGPT|Copilot|AI)") {
            Log ("Removed filler line: $line")
            continue
        }

        $cleaned += $line
        Log ("Kept line: $line")
    }

    Set-Content -Path $filePath -Value $cleaned -Force
    Log ("Sanitized $filePath")
}

function Repair-Script {
    param([string]$filePath)

    Log ("🔧 Fixing $filePath ...")
    Sanitize-Script $filePath

    Log ("🔍 Running ScriptAnalyzer on $filePath ...")
    try {
        $result = Invoke-ScriptAnalyzer -Path $filePath -Severity Error -ErrorAction Stop
        if ($result.Count -eq 0) {
            Log ("✔ $filePath passed ScriptAnalyzer validation.")
        }
        else {
            Log ("❌ $filePath has analyzer errors.")
            $result | ForEach-Object { Log ($_.Message) }
        }
    }
    catch {
        Log ("❌ Analyzer failed on ${filePath}: $_")
    }
}

if ($All) {
    $scripts = @(
        "GenerateBlogData.ps1",
        "BatchCreateBlogs.ps1",
        "QAValidator.ps1",
        "Orchestrator.ps1",
        "SelfHeal.ps1",
        "DebugAllWithQwen.ps1"
    )

    foreach ($script in $scripts) {
        $path = Join-Path $PSScriptRoot $script
        if (Test-Path $path) {
            Repair-Script $path
        }
        else {
            Log ("⚠ Skipped $script (not found)")
        }
    }

    Log ("✅ Targeted batch repair complete.")
}
else {
    Log ("ℹ Use -All to repair all pipeline scripts.")
}
