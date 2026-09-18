#!/usr/bin/env pwsh
<#
.SYNOPSIS
  PreCommitHook.ps1 — Runs validation before allowing commit.
#>

Write-Host "PowerShell profile loaded successfully."
Write-Host "=== PreCommitHook.ps1 started ==="

$repoRoot = "C:\Users\LMTest\promotional\mercor-affiliate-blog"
$validator = Join-Path $repoRoot "scripts\VerifyFrontMatter.ps1"

& $validator

Write-Host "=== PreCommitHook.ps1 complete ==="
