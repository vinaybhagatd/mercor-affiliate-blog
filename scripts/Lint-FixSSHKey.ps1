<# 
Lint-FixSSHKey.ps1
Minimal linting script to detect unbalanced quotes and here-strings
#>

$ScriptPath = "C:\Users\LMTest\Scripts\Fix-SSHKey.ps1"
$lines = Get-Content $ScriptPath

$lineNumber = 0
$errors = @()

foreach ($line in $lines) {
    $lineNumber++

    # Count single and double quotes
    $singleQuotes = ($line -split "'").Count - 1
    $doubleQuotes = ($line -split '"').Count - 1

    if ($singleQuotes % 2 -ne 0) {
        $errors += "Line ${lineNumber}: Unbalanced single quotes -> ${line}"
    }
    if ($doubleQuotes % 2 -ne 0) {
        $errors += "Line ${lineNumber}: Unbalanced double quotes -> ${line}"
    }

    # Detect here-string start/end
    if ($line.Trim() -eq '@"' -or $line.Trim() -eq '"@') {
        $errors += "Line ${lineNumber}: Here-string marker detected -> ${line}"
    }
}

if ($errors.Count -eq 0) {
    Write-Host "✅ No obvious unbalanced quotes or here-string markers found."
} else {
    Write-Host "⚠️ Potential issues detected:"
    $errors | ForEach-Object { Write-Host $_ }
}
