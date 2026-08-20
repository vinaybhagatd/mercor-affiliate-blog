<#
.SYNOPSIS
QAValidator.ps1
Validates blog .html files for compliance:
- Ensures required <meta> tags (canonical, category, thumbnail) are present
- Reports missing tags to QAReport.txt
#>

$blogDir = "C:\Users\LMTest\promotional\mercor-affiliate-blog\blogs"
$reportFile = "QAReport.txt"

# Clear old report
if (Test-Path $reportFile) {
    Remove-Item $reportFile -Force
}

$issues = @()

Get-ChildItem -Path $blogDir -Filter "*.html" | ForEach-Object {
    $fileContent = Get-Content $_.FullName -Raw
    $fileName = $_.Name

    $missingTags = @()

    if ($fileContent -notmatch '<meta\s+name="canonical"') {
        $missingTags += "canonical"
    }
    if ($fileContent -notmatch '<meta\s+name="category"') {
        $missingTags += "category"
    }
    if ($fileContent -notmatch '<meta\s+name="thumbnail"') {
        $missingTags += "thumbnail"
    }

    if ($missingTags.Count -gt 0) {
        $issue = "$fileName is missing meta tags: $($missingTags -join ', ')"
        $issues += $issue
        Write-Host "⚠️ $issue"
    } else {
        Write-Host "✅ $fileName passed validation"
    }
}

# Write report if issues found
if ($issues.Count -gt 0) {
    $issues | Out-File -FilePath $reportFile -Encoding UTF8
    Write-Host "⚠️ Validation completed with issues. See $reportFile for details."
} else {
    Write-Host "✅ All blog files passed validation."
}
