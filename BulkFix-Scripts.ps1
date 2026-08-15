<#
.SYNOPSIS
    BulkFix-Scripts.ps1
    Provides Invoke-BulkFix function to sanitize PowerShell scripts and generate a summary report.

.DESCRIPTION
    Iterates through all .ps1 files in the target directory, applies fixes (ASCII sanitization, whitespace cleanup),
    and writes a summary report with counts of changes per file.
#>

function Invoke-BulkFix {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$TargetDir,

        [switch]$AsciiOnly,

        [string]$SummaryPath = ".\BulkFixReport.txt"
    )

    Write-Host "Running BulkFix in $TargetDir..." -ForegroundColor Cyan

    $errors = @()
    $reportLines = @()
    $linesChanged = 0

    # Get all PowerShell scripts
    $files = Get-ChildItem -Path $TargetDir -Recurse -Filter *.ps1 |
        Where-Object { $_.FullName -notmatch 'mercor_backups|orchestrator_backups|node_modules' }

    foreach ($file in $files) {
        Write-Host "Processing $($file.FullName)..."

        $original = Get-Content $file.FullName -Raw
        $fixed = $original

        # Example sanitization: enforce ASCII only if requested
        if ($AsciiOnly) {
            $fixed = -join ($fixed.ToCharArray() | ForEach-Object {
                    if ([int][char]$_ -le 127) { $_ } else { '?' }
                })
        }

        # Example whitespace cleanup
        $fixed = $fixed -replace '\s+$', ''

        # Compare differences
        $diff = Compare-Object ($original -split "`r?`n") ($fixed -split "`r?`n")
        if ($diff.Count -gt 0) {
            $linesChanged += $diff.Count
            $reportLines += "Changes detected in: $($file.FullName) ($($diff.Count) lines)"
            Set-Content -Path $file.FullName -Value $fixed -Encoding UTF8
        }
    }

    # Write summary
    $summary = @()
    $summary += "BulkFix Summary"
    $summary += "==============="
    $summary += "TargetDir: $TargetDir"
    $summary += "AsciiOnly: $AsciiOnly"
    $summary += "Files processed: $($files.Count)"
    $summary += "Lines changed: $linesChanged"
    $summary += ""
    $summary += $reportLines

    Set-Content -Path $SummaryPath -Value $summary -Encoding UTF8
    Write-Host "BulkFix complete. Summary written to $SummaryPath" -ForegroundColor Green
}

# Auto-run if script is executed directly
if ($MyInvocation.InvocationName -eq $MyInvocation.MyCommand.Name) {
    Invoke-BulkFix -TargetDir . -AsciiOnly -SummaryPath .\BulkFixReport.txt
}
