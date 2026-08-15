function Get-BadCharInfo {
    param([string]$Text)

    $info = [System.Collections.Generic.List[object]]::new()
    $line = 1
    $column = 1

    foreach ($char in $Text.ToCharArray()) {
        $code = [int]$char
        if ($code -gt 127) {
            $info.Add([pscustomobject]@{
                    Line = $line
                    Column = $column
                    Unicode = ('U+{0:X4}' -f $code)
                    Decimal = $code
                    Character = if ($char -match '\s') { ' | WS | ' } else { $char }
                })
        }

        if ($char -eq "
") {
            $line++
            $column = 1
        }
        elseif ($char -ne "`r") {
            $column++
        }
    }

    return $info
}

function Get-HighlightedText {
    param([string]$Text)

    $annotatedLines = [System.Collections.Generic.List[string]]::new()
    $lines = [System.Text.RegularExpressions.Regex]::Split($Text, "`r
|
|`r")

    for ($i = 0; $i -lt $lines.Length; $i++) {
        $annotated = ''
        foreach ($ch in $lines[$i].ToCharArray()) {
            $annotated += if ([int]$ch -gt 127) { "[BAD $('{0:X4}' -f [int]$ch)]" } else { $ch }
        }

        $annotatedLines.Add(("{0, 4}: {1}" -f ($i + 1), $annotated))
    }

    return $annotatedLines
}

$files = Get-ChildItem -Path . -Filter *.ps1 -Recurse
$totalFiles = 0
$totalCleaned = 0
$totalBadChars = 0

foreach ($file in $files) {
    $totalFiles++
    $raw = -Path 
    $chars = $raw.ToCharArray()
    $bad = $chars | Where-Object { [int]$_ -gt 127 }

    if ($bad) {
        $totalCleaned++
        $totalBadChars += $bad.Count

        $logFile = "$($file.FullName).removed.log"
        $cleanFile = "$($file.DirectoryName)\$($file.BaseName)_clean.ps1"

        $badInfo = Get-BadCharInfo -Text $raw
        $badLog = @(
            "Removed bad characters from $($file.Name)", "Total bad chars: $($badInfo.Count)", ''
        )

        foreach ($entry in $badInfo) {
            $badLog += ("Line {0}, Col {1}: {2} ({3}) {4}" -f `
                    $entry.Line, $entry.Column, $entry.Unicode, $entry.Decimal, $entry.Character)
        }

        $badLog += ''
        $badLog += 'Annotated content with bad-char markers:'
        $badLog += ''
        $badLog += Get-HighlightedText -Text $raw

        $badLog | Set-Content -Path $logFile -Encoding UTF8

        -join ($chars | Where-Object { [int]$_ -le 127 }) | Set-Content -Path $cleanFile -Encoding ASCII

        Write-Output "Cleaned $($file.Name)  $($file.BaseName)_clean.ps1"
        Write-Output "  Bad chars logged to $logFile"
    }
    else {
        Write-Output "No non-ASCII characters found in $($file.Name)"
    }
}

Write-Output " Summary Report =  =  = "
Write-Output "Total .ps1 files scanned : $totalFiles"
Write-Output "Files cleaned            : $totalCleaned"
Write-Output "Total bad characters removed : $totalBadChars"

