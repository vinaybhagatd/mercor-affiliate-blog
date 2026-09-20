# pre-push.ps1
param($remoteName, $remoteLocation)

Write-Host "=== Pre-push hook started ==="
Write-Host "Remote: $remoteName"
Write-Host "Location: $remoteLocation"

# Example check: run tests before pushing
try {
    pwsh -File .\scripts\Test-Profile.ps1
    Write-Host "✅ Pre-push checks passed."
    exit 0
} catch {
    Write-Host "❌ Pre-push checks failed: $($_.Exception.Message)"
    exit 1
}
