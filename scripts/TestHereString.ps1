# TestHereString.ps1
# Minimal script to validate here-string syntax

$ConfigPath = "$env:USERPROFILE\.ssh\config"

Write-Host "📝 Creating SSH config file at $ConfigPath..."
@"
Host github.com
    HostName github.com
    User git
    IdentityFile C:/Users/LMTest/.ssh/id_ed25519
    IdentitiesOnly yes
"@ | Out-File -FilePath $ConfigPath -Encoding ascii -Force

Write-Host "✅ SSH config file created."
