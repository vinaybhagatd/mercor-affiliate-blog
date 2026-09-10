<#
.SYNOPSIS
  Installer script for Git hooks in Mercor Affiliate Blog System (MABS).
.DESCRIPTION
  Creates shims in .git/hooks/ that call canonical PowerShell hook scripts
  stored in .githooks/ (pre-commit.ps1, post-commit.ps1).
#>

$repoRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition
$gitHooksDir = Join-Path $repoRoot ".git/hooks"
$customHooksDir = Join-Path $repoRoot ".githooks"

function Create-Shim($hookName) {
    $shimPath = Join-Path $gitHooksDir $hookName
    $psScriptPath = Join-Path $customHooksDir "$hookName.ps1"

    $shimContent = @"
#!/bin/sh
# Git hook shim for $hookName
pwsh -NoProfile -ExecutionPolicy Bypass -File "$(git rev-parse --show-toplevel)/.githooks/$hookName.ps1"
"@

    Set-Content -Path $shimPath -Value $shimContent -Encoding UTF8
    # Make executable (for Unix-like environments)
    try {
        bash -c "chmod +x '$shimPath'" 2>$null
    } catch {
        Write-Output "Note: chmod skipped (Windows environment)."
    }

    Write-Output "Created shim: $shimPath -> $psScriptPath"
}

Write-Output "🔧 Setting up Git hooks..."
Create-Shim "pre-commit"
Create-Shim "post-commit"
Write-Output "✅ Hooks setup complete. Pre-commit and post-commit now wired to .githooks/"
