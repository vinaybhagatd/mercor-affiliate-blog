<# 
Fix-SSHKey.ps1
Permanent setup for SSH key permissions, agent loading, GitHub config,
Git safe.directory registration, and connectivity validation
Run this script once after generating a new key
#>

$KeyPath    = "$env:USERPROFILE\.ssh\id_ed25519"
$ConfigPath = "$env:USERPROFILE\.ssh\config"
$RepoPath   = "C:/Users/LMTest/promotional/mercor-affiliate-blog"
$RepoSSHUrl = "git@github.com:bhagatvinayd/mercor-affiliate-blog.git"   # <-- replace with your actual SSH URL

# Track results
$Results = @{}

Write-Host "🔑 Fixing permissions for $KeyPath..."
try {
    icacls $KeyPath /inheritance:r | Out-Null
    icacls $KeyPath /grant:r "$($env:USERNAME):(R)" | Out-Null
    icacls $KeyPath /remove "Users" "Everyone" | Out-Null
    $Results["Permissions"] = "✅ Fixed"
} catch {
    $Results["Permissions"] = "⚠️ Failed"
}

Write-Host "⚙️ Configuring ssh-agent service..."
try {
    Set-Service ssh-agent -StartupType Automatic
    $Results["ssh-agent service"] = "✅ Configured"
} catch {
    $Results["ssh-agent service"] = "⚠️ Needs Admin"
}

if ((Get-Service ssh-agent).Status -ne 'Running') {
    Start-Service ssh-agent
    $Results["ssh-agent status"] = "✅ Started"
} else {
    $Results["ssh-agent status"] = "ℹ️ Already running"
}

try {
    ssh-add $KeyPath
    $Results["Key added"] = "✅ Added"
} catch {
    $Results["Key added"] = "⚠️ Failed"
}

if (-Not (Test-Path $ConfigPath)) {
    Write-Host "📝 Creating SSH config file at $ConfigPath..."
@"
Host github.com
    HostName github.com
    User git
    IdentityFile $KeyPath
    IdentitiesOnly yes
"@ | Out-File -FilePath $ConfigPath -Encoding ascii -Force
    $Results["SSH config"] = "✅ Created"
} else {
    $Results["SSH config"] = "ℹ️ Already exists"
}

Write-Host "🔒 Ensuring $RepoPath is in Git safe.directory..."
$safeDirs = git config --global --get-all safe.directory
if ($safeDirs -notcontains $RepoPath) {
    git config --global --add safe.directory $RepoPath
    $Results["Safe.directory"] = "✅ Registered"
} else {
    $Results["Safe.directory"] = "ℹ️ Already registered"
}

Write-Host "🔍 Running GitHub connectivity test..."
try {
    git ls-remote $RepoSSHUrl | Out-Null
    $Results["Connectivity"] = "✅ Verified"
} catch {
    $Results["Connectivity"] = "⚠️ Failed"
}

# Final summary with timestamp
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
Write-Host "`n📋 Summary Report ($timestamp):"
foreach ($key in $Results.Keys) {
    Write-Host (" - {0}: {1}" -f $key, $Results[$key])
}
