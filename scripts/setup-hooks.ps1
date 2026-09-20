# Define a local Log function
function Log {
    param([string]$Message)
    Write-Host $Message
}

Log "=== setup-hooks.ps1 started ==="

# Define hook filenames only (not full paths)
$hooks = @("pre-commit.ps1","commit-msg.ps1","pre-push.ps1")

foreach ($hook in $hooks) {
    $targetPath = Join-Path (Split-Path $PSScriptRoot -Parent) ".githooks\$hook"
    $hookPath   = Join-Path (Split-Path $PSScriptRoot -Parent) ".git\hooks\$hook"

    if (Test-Path $targetPath) {
        try {
            # Create or overwrite symlink
            New-Item -ItemType SymbolicLink -Path $hookPath -Target $targetPath -Force | Out-Null
            Log "✅ Symlink created: $hookPath → $targetPath"
        } catch {
            Log "❌ Failed to create symlink for ${hook}: $($_.Exception.Message)"
        }
    } else {
        Log "❌ Target missing: $targetPath"
    }
}

Log "=== setup-hooks.ps1 complete ==="
