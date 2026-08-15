<#
.SYNOPSIS
    QAValidator.ps1 - Validates Mercor Affiliate Blog posts for compliance
    and blocks commits if validation fails.
.DESCRIPTION
    Checks front matter, categories, required sections, disclosure, and placeholder text.
    Produces QAReport.txt with summary and details. Blocks commits if any failures exist.
#>

param (
    [string] $SiteDir = ".\_site",
    [string] $OutputFile = ".\QAReport.txt"
)

$approvedCategories = @("creative", "data", "engineering", "finance", "language", "law", "medicine", "misc", "operations", "sciences", "tech")
$requiredSections = @("Day in the Life", "Tools Used", "Skills Required", "Salary Range", "Growth Path", "Want Better Remote", "Explore Remote")

$results = @()
$hasFailures = $false
$passedCount = 0
$failedCount = 0
$failedFiles = @()

# Enumerate all markdown files in the site directory
Get-ChildItem -Path $SiteDir -Recurse -Filter "*.md" | ForEach-Object {
    $file = $_.FullName
    $content = Get-Content $file -Raw

    $issues = @()

    # Front matter checks
    if ($content -notmatch "layout\s+post") { $issues += "Missing or incorrect layout front matter." }
    if ($content -notmatch "title\s+") { $issues += "Missing title in front matter." }
    if ($content -notmatch "categories\s+") { $issues += "Missing categories in front matter." }
    if ($content -notmatch "thumbnail\s+/assets/images/thumbnails/") { $issues += "Missing thumbnail path in front matter." }

    # Category validation
    $categoryMatch = [regex]::Match($content, "categories\s+(\w+)")
    if ($categoryMatch.Success) {
        $category = $categoryMatch.Groups[1].Value
        if ($approvedCategories -notcontains $category) {
            $issues += "Invalid category '$category'. Must be one of: $($approvedCategories -join ', ')."
        }
    }
    else {
        $issues += "No category found in front matter."
    }

    # Required sections
    foreach ($section in $requiredSections) {
        if ($content -notmatch $section) {
            $issues += "Missing required section: $section"
        }
    }

    # Disclosure check
    if ($content -notmatch "Disclosure: Some of the links in this post are affiliate links") {
        $issues += "Missing Disclosure section at end of blog."
    }

    # Placeholder text check
    if ($content -match "Lorem ipsum" -or $content -match "Placeholder") {
        $issues += "Placeholder text detected."
    }

    if ($issues.Count -gt 0) {
        $results += "Validation failed for $file:`n - " + ($issues -join "`n - ")
        $hasFailures = $true
        $failedCount++
        $failedFiles += $file
    }
    else {
        $results += "Validation passed for $file"
        $passedCount++
    }
}

# Build summary line
$summary = "Summary: $passedCount blog(s) passed, $failedCount blog(s) failed."
if ($failedCount -gt 0) {
    $summary += "`nFailed files:`n" + ($failedFiles -join "`n")
}

# Save results with summary at top
Set-Content -Path $OutputFile -Value ($summary + "`n`n" + ($results -join "`n`n")) -Encoding UTF8

if ($hasFailures) {
    Write-Error "QA validation failed. See $OutputFile for details."
    exit 1   # Non-zero exit code blocks commit
}
else {
    Write-Host "QA validation passed. Results saved to $OutputFile"
    exit 0   # Success
}
