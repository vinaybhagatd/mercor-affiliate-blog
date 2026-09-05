# HermesAutomation.ps1
param(
    [string]$ProjectDir = "C:\Users\LMTest\promotional\mercor-affiliate-blog", [string[]]$Categories = @("creative", "data", "engineering", "finance", "language", "law", "medicine", "misc", "operations", "sciences", "tech"), [switch]$OpenSummary
)

# Logging function
function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Output "[${timestamp}][${Level}] ${Message}"
}

# Error logging function
function Write-ErrorLog {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Error "[${timestamp}] ${Message}"
}

# Define Send-OllamaRequest wrapper
function Send-OllamaRequest {
    param(
        [string]$Prompt, [switch]$ResetContext
    )
    try {
        $body = @{ prompt = $Prompt }
        if ($ResetContext) { $body["reset"] = $true }
        $jsonBody = $body | ConvertTo-Json -Depth 5
        $response = Invoke-RestMethod -Uri "http://localhost:11434/api/generate" -Method Post -Body $jsonBody -ContentType "application/json"
        return $response.output
    }
    catch {
        Write-ErrorLog "Failed to send request to OLLAMA: $_"
        return $null
    }
}

# Main loop
foreach ($category in $Categories) {
    try {
        Write-Log "Processing category: ${category}"

        # Correct file reference
        $scriptPath = Join-Path $ProjectDir "CreateBlog.ps1"
        if (-not (Test-Path $scriptPath)) {
            Write-ErrorLog "Missing script file: ${scriptPath}"
            continue
        }

        $issuesPrompt = Get-Content -Path -Path -Path -Path -Path -Path -Path -Path -Path -Path -Path -Path -Path -Path -Path $scriptPath -Raw
        $response = Send-OllamaRequest -Prompt $issuesPrompt -ResetContext

        if ([string]::IsNullOrWhiteSpace($response)) {
            Write-Log "No response received for ${category}" "ERROR"
        }
        else {
            $outDir = Join-Path $ProjectDir "blogs"
            if (-not (Test-Path $outDir)) { New-Item -ItemType Directory -Path $outDir | Out-Null }
            $outFile = Join-Path $outDir "${category}-output.txt"
            $response | Out-File -FilePath $outFile -Encoding UTF8
            Write-Log "Response saved for ${category}  ${outFile}"
        }

    }
    catch {
        Write-Log "Error processing ${category}: $_" "ERROR"
    }
}

# Optional summary mode
if ($OpenSummary) {
    Write-Log "Summary mode enabled. Listing generated outputs..."
    $blogsDir = Join-Path $ProjectDir "blogs"
    if (Test-Path $blogsDir) {
        Get-ChildItem -Path $blogsDir -Filter "*-output.txt" | ForEach-Object {
            Write-Output "Generated file: $($_.FullName)"
        }
    }
    else {
        Write-Log "No blogs directory found." "WARN"
    }
}







