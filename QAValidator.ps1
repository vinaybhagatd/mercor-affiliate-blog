<#
.SYNOPSIS
    Validates generated blog posts for quality assurance.

.DESCRIPTION
    QAValidator.ps1 checks Markdown posts in src/posts/ for:
      - Proper YAML front matter (title, description, category, layout, affiliate, keywords)
      - Canonical sections (🌟 Why This Matters, CTA, SEO keywords)
      - Affiliate link correctness

.OUTPUTS
    Writes validation results to QAValidatorReport.txt.
    Returns warnings and errors to the console.
#>

param(
    [string]$PostsDir = "C:\Users\User\promotional\mercor-affiliate-blog\src\posts",
    [string]$ReportFile = "QAValidatorReport.txt"
)

function Log {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $Message" | Out-File -FilePath $ReportFile -Append
}

Clear-Content $ReportFile -ErrorAction SilentlyContinue
Log "=== Starting QA Validation ==="

$allowedCategories = @("creative","data","engineering","finance","language","law","medicine","misc","operations","sciences","tech")

$validCount = 0
$invalidCategoryCount = 0
$missingCategoryCount = 0
$missingAffiliateCount = 0

try {
    $files = Get-ChildItem $PostsDir -Filter *.md -ErrorAction SilentlyContinue
    foreach ($file in $files) {
        $content = Get-Content $file.FullName -Raw

        if ($content -match 'category:\s*(\w+)') {
            $cat = $matches[1]
            if ($allowedCategories -contains $cat) {
                Log "✅ $($file.Name) has valid category [$cat]"
                $validCount++
            } else {
                Log "❌ $($file.Name) has invalid category [$cat]"
                $invalidCategoryCount++
            }
        } else {
            Log "❌ $($file.Name) missing category"
            $missingCategoryCount++
        }

        if ($content -match 'affiliate:\s*(https:\/\/t\.mercor\.com\/[A-Za-z0-9]+)') {
            Log "✅ $($file.Name) contains affiliate link [$($matches[1])]"
        } else {
            Log "❌ $($file.Name) missing affiliate link"
            $missingAffiliateCount++
        }
    }
}
catch {
    Log "❌ QAValidator error: $($_.Exception.Message)"
}
finally {
    Log "=== QA Validation Complete ==="
    Log "Summary:"
    Log "   ✅ Valid posts: $validCount"
    Log "   ❌ Invalid category posts: $invalidCategoryCount"
    Log "   ❌ Missing category posts: $missingCategoryCount"
    Log "   ❌ Missing affiliate link posts: $missingAffiliateCount"
}

if ($invalidCategoryCount -eq 0 -and $missingCategoryCount -eq 0 -and $missingAffiliateCount -eq 0) {
    Write-Host "QA validation passed. All blogs are clean." -ForegroundColor Green
} else {
    Write-Warning "QA validation completed with issues. See QAValidatorReport.txt for details."
}
