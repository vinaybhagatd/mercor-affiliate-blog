<#
.SYNOPSIS
  Validates blog posts in MABS for category and affiliate link compliance.
.DESCRIPTION
  Scans src/posts/*.md files, checks front matter for required fields,
  validates categories against Eleventy collections,
  and cross-checks affiliate links against affiliate-links.md.
  Outputs QAValidatorReport.txt with results and totals.
#>

param(
  [string]$PostsDir = "C:\Users\LMTest\promotional\mercor-affiliate-blog\src\posts",
  [string]$AffiliateFile = "C:\Users\LMTest\promotional\mercor-affiliate-blog\affiliate-links.md",
  [string]$ReportFile = "QAValidatorReport.txt"
)

function Log {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $Message" | Out-File -FilePath $ReportFile -Append
}

# Reset report
Clear-Content $ReportFile -ErrorAction SilentlyContinue
Log "=== Starting QA Validation ==="

# ✅ Canonical categories (from Eleventy collections)
$allowedCategories = @(
    "creative","data","engineering","finance","language",
    "law","medicine","misc","operations","sciences","tech"
)

# ✅ Parse affiliate-links.md to build category→link map
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

        # ✅ Regex for category in front matter
        if ($content -match 'category:\s*(\w+)') {
            $cat = $matches[1]
            if ($allowedCategories -contains $cat) {
                Log "✅ $($file.Name) has valid category [$cat]"
            } else {
                Log "❌ $($file.Name) has invalid category [$cat] (not in canonical list)"
                $invalidCategoryCount++
            }
        } else {
            Log "❌ $($file.Name) missing category in front matter"
            $missingCategoryCount++
        }

        # ✅ Extract affiliate link from post body
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
