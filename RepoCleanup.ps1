 | #
.SYNOPSIS
    RepoCleanup.ps1 - Automatically rename unapproved verbs in PowerShell functions.

.DESCRIPTION
    Scans all .ps1 files in the repo and replaces unapproved verbs with approved ones:
      Invoke-*      ??' Invoke-*
      Repair-*      ??' Repair-*
      Restore-* ??' Restore-*
      Invoke-AutoCorrection   ??' Invoke-AutoCorrection

.EXAMPLE
    .\RepoCleanup.ps1
# | param (
    [string] $RepoRoot = "."
)

Write-Output " =  =  = Starting repo-wide cleanup =  =  = "

Get-ChildItem -Path $RepoRoot -Recurse -Filter *.ps1 | ForEach-Object {
    $file = $_.FullName
    Write-Output "Processing: $file"

    $content = -Path 

    # Replace Invoke-* with Invoke-*
    $content = $content -replace '(? | = function\s+)Invoke-', 'Invoke-'
    $content = $content -replace '\bRun-', 'Invoke-'

    # Replace Repair-* with Repair-*
    $content = $content -replace '(? | = function\s+)Repair-', 'Repair-'
    $content = $content -replace '\bFix-', 'Repair-'

    # Replace Restore-* with Restore-*
    $content = $content -replace '(? | = function\s+)Restore-', 'Restore-'
    $content = $content -replace '\bSelfHeal-', 'Restore-'

    # Replace Invoke-AutoCorrection with Invoke-AutoCorrection
    $content = $content -replace '(? | = function\s+)Invoke-AutoCorrection', 'Invoke-AutoCorrection'
    $content = $content -replace '\bAuto-Fix\b', 'Invoke-AutoCorrection'

    Set-Content -Path $file -Value $content -Encoding UTF8
}

Write-Output " =  =  = Cleanup complete. All unapproved verbs replaced with approved verbs. =  =  = "
