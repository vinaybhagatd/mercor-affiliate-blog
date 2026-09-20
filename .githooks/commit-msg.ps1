# commit-msg.ps1
param([string]$commitMsgFile)

# Read the commit message
$commitMessage = Get-Content $commitMsgFile -Raw

# Example validation: prevent empty commit messages
if ([string]::IsNullOrWhiteSpace($commitMessage)) {
    Write-Host "❌ Commit message cannot be empty."
    exit 1
}

Write-Host "✅ Commit message validated."
exit 0
