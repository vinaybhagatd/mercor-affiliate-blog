<#
.SYNOPSIS
  QA Validator with Pre-Release Audit mode.
.DESCRIPTION
  - Validates blog posts for category and affiliate link compliance
  - Generates QAValidatorReport.txt
  - Companion mode: prints a concise pre-release audit summary after BulkFix-Posts.ps1
#>

param(
  [string]$PostsDir = "C:\Users\LMTest\promotional\mercor-affiliate-blog\src\posts",
  [string]$AffiliateFile = "C:\Users\LMTest\promotional\mercor-affiliate-blog\affiliate-links.md",
  [string]$ReportFile = "QAValidatorReport.txt",
  [switch]$PreReleaseAudit
)

function Log {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $Message" | Out-File -FilePath $ReportFile -Append
}

# Reset report
Clear-Content $ReportFile -ErrorAction SilentlyContinue
Log "=== Starting QA Validation ==="

# ✅ Canonical categories
$allowedCategories = @(
    "creative","data","engineering","finance","language",
    "law","medicine","misc","operations","sciences","tech"
)

# ✅ Build category→affiliate link map
$affiliateLinks = @{}
if (Test-Path $AffiliateFile) {
    $lines = Get-Content $AffiliateFile
    foreach ($cat in $allowedCategories) {
        $pattern = "Apply for Remote $($cat.Substring(0,1).ToUpper() + $cat.Substring(1)) Roles"
        $match = $lines | Where-Object { $_ -match $pattern }
        if ($match -match '\((https:\/\/t\.mercor\.com\/[A-Za-z0-9]+)\)') {
            $affiliateLinks[$cat] = $matches[1]
        }
    }
}

# Counters
$validCount = 0
$invalidCategoryCount = 0
$missingCategoryCount = 0
$missingAffiliateCount = 0
$mismatchedAffiliateCount = 0

try {
    $files = Get-ChildItem $PostsDir -Filter *.md -ErrorAction SilentlyContinue
    foreach ($file in $files) {
        $content = Get-Content $file.FullName -Raw

        $cat = $null
        $affiliateLinkInPost = $null

        # ✅ Category check
        if ($content -match 'category:\s*(\w+)') {
            $cat = $matches[1]
            if ($allowedCategories -contains $cat) {
                Log "✅ $($file.Name) has valid category [$cat]"
            } else {
                Log "❌ $($file.Name) has invalid category [$cat]"
                $invalidCategoryCount++
            }
        } else {
            Log "❌ $($file.Name) missing category in front matter"
            $missingCategoryCount++
        }

        # ✅ Affiliate link check
        if ($content -match '\(https:\/\/t\.mercor\.com\/[A-Za-z0-9]+\)') {
            $affiliateLinkInPost = $matches[0].Trim('()')
            if ($cat -and $affiliateLinks.ContainsKey($cat)) {
                if ($affiliateLinkInPost -eq $affiliateLinks[$cat]) {
                    Log "✅ $($file.Name) contains correct affiliate link for [$cat]"
                    if ($cat -and ($allowedCategories -contains $cat)) {
                        $validCount++
                    }
                } else {
                    Log "❌ $($file.Name) affiliate link mismatch. Found [$affiliateLinkInPost], expected [$($affiliateLinks[$cat])]"
                    $mismatchedAffiliateCount++
                }
            }
        } else {
            Log "❌ $($file.Name) missing affiliate link"
            $missingAffiliateCount++
        }
    }
}
catch {
    Log "❌ QAValidator encountered error: $($_.Exception.Message)"
}
finally {
    Log "=== QA Validation Complete ==="
    Log "Summary:"
    Log "   ✅ Valid posts: $validCount"
    Log "   ❌ Invalid category posts: $invalidCategoryCount"
    Log "   ❌ Missing category posts: $missingCategoryCount"
    Log "   ❌ Missing affiliate link posts: $missingAffiliateCount"
    Log "   ❌ Mismatched affiliate link posts: $mismatchedAffiliateCount"
}

# ✅ Conditional success/warning logic
if ($invalidCategoryCount -eq 0 -and 
    $missingCategoryCount -eq 0 -and 
    $missingAffiliateCount -eq 0 -and 
    $mismatchedAffiliateCount -eq 0) {
    Write-Host "QA validation passed. All blogs are clean." -ForegroundColor Green
} else {
    Write-Warning "QA validation completed with issues. See QAValidatorReport.txt for details."
}

# ✅ Pre-Release Audit Mode
if ($PreReleaseAudit) {
    Write-Host "`n=== Pre-Release Audit Summary ===" -ForegroundColor Cyan
    Write-Host "Valid posts: $validCount"
    Write-Host "Invalid category posts: $invalidCategoryCount"
    Write-Host "Missing category posts: $missingCategoryCount"
    Write-Host "Missing affiliate link posts: $missingAffiliateCount"
    Write-Host "Mismatched affiliate link posts: $mismatchedAffiliateCount"
    Write-Host "=================================" -ForegroundColor Cyan
}
