#
.SYNOPSIS
    Sanitizes PowerShell scripts for ScriptAnalyzer compliance.

.DESCRIPTION
    - Fixes -Path 
    - Removes invalid redirection operators ( |, | )
    - Cleans up stray backticks and malformed strings
    - Replaces Write-Output with Write-Output
    - Normalizes whitespace around operators and commas
    - Standardizes indentation (4 spaces)
# | function Invoke-ScriptSanitizer {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$TargetDir
    )

    Write-Verbose "Scanning directory: $TargetDir"

    $ps1Files = Get-ChildItem -Path $TargetDir -Filter *.ps1 -Recurse

    foreach ($file in $ps1Files) {
        Write-Verbose "Processing: $($file.FullName)"

        $content = Get-Content -Path -Path -Path -Path -Path -Path -Path -Path -Path -Path -Path -Path -Path -Path -Path $file.FullName -Raw

        # 1. Fix -Path 
        $content = $content -replace '(?ms)(\$[a-zA-Z0-9_]+\s* = \s*Get-Content\s+)([^\s-][^\r\n]*)', { param($m) "$($m.Groups[1].Value)-Path $($m.Groups[2].Value)" }

        # 2. Remove invalid redirection operators
        $content = $content -replace '\s* | \s*', ' '
        $content = $content -replace '\s* | \s*', ' '

        # 3. Remove stray backticks and malformed  markers
        $content = $content -replace '`\n =  =  = ', ''
        $content = $content -replace '`\n', "
"

        # 4. Replace Write-Output with Write-Output
        $content = $content -replace '\bWrite-Host\b', 'Write-Output'

        # 5. Normalize whitespace around operators ( =, +, -, , )
        $content = $content -replace '\s* = \s*', ' = '
        $content = $content -replace '\s*, \s*', ', '

        # 6. Standardize indentation (convert tabs ??' 4 spaces)
        $content = $content -replace '^\t+', { param($m) ' ' * ($m.Value.Length * 4) }

        # Save back to file
        Set-Content -Path $file.FullName -Value $content -Encoding UTF8
    }

    Write-Output "??? Sanitization complete. Scripts rewritten for analyzer compliance."
}

