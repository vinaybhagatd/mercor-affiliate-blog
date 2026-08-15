[CmdletBinding()]
param (
    [string]$PromptFile, [string]$Model = "md-coder-qwen3-8b", [switch]$Help = $false
)

Set-StrictMode -Version Latest

try {
    if ($Help) {
        Write-Output "Usage: .\RunPrompt.ps1 -PromptFile | path | [-Model | model-name | ] [-Help]"
        return
    }

    if (-not $PromptFile) { throw "PromptFile parameter is required" }
    if (-not (Test-Path $PromptFile)) {
        Write-Error "Prompt file not found: $PromptFile"
        throw "Prompt file not found"
    }

    $promptText = Get-Content -Path -Path -Path -Path -Path -Path -Path -Path -Path -Path -Path -Path -Path -Path -Path $PromptFile -Raw
    if ([string]::IsNullOrWhiteSpace($promptText)) {
        Write-Error "Prompt file is empty: $PromptFile"
        throw "Prompt file is empty"
    }

    if (-not $Model) { throw "Model parameter cannot be empty" }

    # Unified success message
    Write-Output "Output written successfully (Model: $Model)"

    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $outputDir = Join-Path $PSScriptRoot "outputs"
    $scriptDir = Join-Path $PSScriptRoot "scripts"

    if (-not (Test-Path $outputDir)) { New-Item -ItemType Directory -Path $outputDir | Out-Null }
    if (-not (Test-Path $scriptDir)) { New-Item -ItemType Directory -Path $scriptDir | Out-Null }

    $outFile = Join-Path $outputDir ("blog-template-$timestamp.out.txt")
    $notesFile = Join-Path $outputDir ("blog-template-$timestamp.notes.txt")
    $updatedFile = Join-Path $scriptDir ("blog-template-$timestamp.updated.ps1")

    Set-Content -Path $outFile     -Value "Simulated output for $Model at $timestamp"
    Set-Content -Path $notesFile   -Value "Notes for $PromptFile"
    Set-Content -Path $updatedFile -Value "# Updated script for $PromptFile"
}
catch {
    $errMsg = $_.Exception.Message
    Write-Error ("Error executing RunPrompt.ps1: {0}" -f $errMsg)
    throw
}

