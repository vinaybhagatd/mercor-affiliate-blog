# Generate-ModelJson.ps1
param(
    [string]$ModelFolder = "C:\Users\LMTest\.lmstudio\models\Qwen2.5-7B-Instruct-GGUF",
    [string]$Arch = "qwen2.5",
    [string]$Parameters = "7B"
)

# Ensure the folder exists
if (-not (Test-Path $ModelFolder)) {
    New-Item -ItemType Directory -Path $ModelFolder -Force | Out-Null
}

# Find the first GGUF file in the folder
$ggufFile = Get-ChildItem -Path $ModelFolder -Filter *.gguf | Select-Object -First 1

if (-not $ggufFile) {
    Write-Error "No GGUF file found in $ModelFolder"
    exit 1
}

# Build JSON object
$modelJson = @{
    name       = (Split-Path $ModelFolder -Leaf)
    arch       = $Arch
    parameters = $Parameters
    format     = "GGUF"
    files      = @(
        @{
            filename = $ggufFile.Name
            size     = $ggufFile.Length
        }
    )
}

# Convert to JSON and save
$modelJson | ConvertTo-Json -Depth 3 | Set-Content -Path (Join-Path $ModelFolder "model.json") -Encoding UTF8

Write-Host "Generated model.json for $($ggufFile.Name) in $ModelFolder"
