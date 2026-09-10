<#
.SYNOPSIS
  Configures VS Code AI extension to use LM Studio local API.
.DESCRIPTION
  - Skips installation (assumes VS Code + LM Studio already installed)
  - Installs a supported AI extension (Continue)
  - Updates VS Code settings.json to point at LM Studio endpoint
#>

$ErrorActionPreference = "Stop"

Write-Host "=== Setup-LMStudioVSCode.ps1 started ===" -ForegroundColor Cyan

# --- Step 1: Install Continue extension (supports LM Studio endpoint) ---
Write-Host "Installing VS Code Continue extension..."
code --install-extension Continue.continue
Write-Host "Continue extension installed." -ForegroundColor Green

# --- Step 2: Configure VS Code settings.json ---
Write-Host "Configuring VS Code to use LM Studio..."

$settingsPath = "$env:APPDATA\Code\User\settings.json"

if (-Not (Test-Path $settingsPath)) {
    New-Item -ItemType File -Path $settingsPath -Force | Out-Null
}

$settings = @{}
if (Test-Path $settingsPath) {
    try {
        $settings = Get-Content $settingsPath | ConvertFrom-Json
    } catch {
        Write-Warning "Existing settings.json is not valid JSON. Overwriting."
        $settings = @{}
    }
}

# Add LM Studio model configuration
$settings."continue.serverUrl" = "http://127.0.0.1:1234/v1"
$settings."continue.models" = @(
    @{
        "title"    = "Qwen2.5-7B-Instruct (LM Studio)"
        "provider" = "openai"
        "model"    = "qwen2.5-7b-instruct"
    }
)

$settings | ConvertTo-Json -Depth 5 | Set-Content $settingsPath -Encoding UTF8
Write-Host "VS Code configured to use LM Studio local API." -ForegroundColor Green

Write-Host "=== Setup-LMStudioVSCode.ps1 complete ===" -ForegroundColor Cyan
