param(
    [switch]$Restore
)

$scriptPath = $MyInvocation.MyCommand.Path
$files = Get-ChildItem -Path . -Filter *.ps1 -Recurse
$masterReport = @()

# Replacement map using proper PowerShell Unicode escapes
$replaceMap = @{
    "`u{2026}" = "..."   # ellipsis
    "`u{201C}" = '"'     # left curly double quote
    "`u{201D}" = '"'     # right curly double quote
    "`u{2018}" = "'"     # left curly single quote
    "`u{2019}" = "'"     # right curly single quote
    "`u{2013}" = "-"     # en dash
    "`u{2014}" = "-"     # em dash
}

Write-Output "Replacement map initialized safely."

# --- Restore logic ---
if ($Restore) {
    foreach ($file in $files) {
        $backupFile = "$($file.FullName).bak"
        if (Test-Path $backupFile) {
            Copy-Item $backupFile $file.FullName -Force
            Write-Output "Restored $($file.Name) from backup."
        }
    }
    Write-Output " Restore Complete =  =  = "
    return
}

# --- File scanning and cleaning ---
foreach ($file in $files) {
    # Skip scanning this script itself
    if ($file.FullName -eq $scriptPath) {
        continue
    }

    $lines = -Path 
    $badLines = @()
    $charReport = @()

    for ($i = 0; $i -lt $lines.Count; $i++) {
        foreach ($ch in $lines[$i].ToCharArray()) {
            if ([int]$ch -gt 127) {
                $badLines += "Line $($i+1): $($lines[$i])"
                $charReport += "File: $($file.Name) Line $($i+1) - | '$ch' (U+{0:X4})" -f [int]$ch
            }
        }
    }

    if ($badLines.Count -gt 0) {
        # Backup original
        $backupFile = "$($file.FullName).bak"
        if (-not (Test-Path $backupFile)) {
            Copy-Item $file.FullName $backupFile
        }

        # Apply replacements
        $raw = -Path 
        foreach ($key in $replaceMap.Keys) {
            $raw = $raw -replace $key, $replaceMap[$key]
        }

        # Strip any remaining non-ASCII
        $clean = -join ($raw.ToCharArray() | Where-Object { [int]$_ -le 127 })

        # --- Inject pre-run ASCII validation guard ---
        $guard = @'
# Pre-run ASCII validation guard
$rawSelf = -Path 
if ($rawSelf -match '[^\x00-\x7F]') {
    throw "Non-ASCII characters detected. Please run SanitizeScripts.ps1 before executing."
}
'@
        if ($clean -notmatch 'Pre-run ASCII validation guard') {
            $clean = $guard + "
" + $clean
        }

        Set-Content $file.FullName $clean -Encoding UTF8

        # Write per-file log
        $logFile = "$($file.FullName).removed.log"
        $badLines + " Unicode Report =  =  = " + $charReport | Set-Content $logFile -Encoding UTF8

        # Add to master report
        $masterReport += $charReport
        Write-Output "Cleaned $($file.Name). Backup saved as $($file.Name).bak"
    }
    else {
        Write-Output "No non-ASCII characters found in $($file.Name)"
    }
}

# --- Master report ---
if ($masterReport.Count -gt 0) {
    $masterReport | Set-Content ".\UnicodeMasterReport.log" -Encoding UTF8
    Write-Output "
Master report written to UnicodeMasterReport.log"
}
else {
    Write-Output "
No non-ASCII characters found in project."
}







