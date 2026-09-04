<# 
.SYNOPSIS
QA Validator for Mercor Affiliate Blog System (MABS).
.DESCRIPTION
Ensures that every post uses only the 11 approved categories.
Fails pipeline if invalid categories are detected.
#>

$logFile = "QAValidator.log"
$postsDir = "src/posts"

function Log($text) {
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $text" | Out-File -FilePath $logFile -Append
}

# Define the 11 approved categories
$allowedCategories = @(
    "misc",
    "creative",
    "engineering",
    "finance",
    "data",
    "law",
    "medicine",
    "language",
    "operations",
    "sciences",
    "tech"
)

try {
    Log "Starting QA Validator..."
    $qaPass = $true

    # Scan all markdown files in src/posts
    $files = Get-ChildItem -Path $postsDir -Recurse -Filter "*.md"

    foreach ($file in $files) {
        $content = Get-Content $file.FullName -Raw

        # Extract tags from front matter (YAML style)
        if ($content -match "(?s)^---(.*?)---") {
            $frontMatter = $matches[1]

            # Find tags line(s)
            $tags = @()
            foreach ($line in $frontMatter -split "`n") {
                if ($line -match "tags:\s*(.+)") {
                    $tags += ($line -replace "tags:\s*", "").Trim()
                }
            }

            foreach ($tag in $tags) {
                if (-not ($allowedCategories -contains $tag)) {
                    Write-Output "Invalid category '$tag' in file: $($file.Name)"
                    Log "Invalid category '$tag' in file: $($file.Name)"
                    $qaPass = $false
                }
                else {
                    Log "Valid category '$tag' in file: $($file.Name)"
                }
            }
        }
        else {
            Write-Output "Missing front matter in file: $($file.Name)"
            Log "Missing front matter in file: $($file.Name)"
            $qaPass = $false
        }
    }

    if ($qaPass) {
        Write-Output "QA PASS: All posts use only approved categories."
        Log "QA PASS: All posts use only approved categories."
    }
    else {
        Write-Output "QA FAIL: One or more posts use invalid categories."
        Log "QA FAIL: One or more posts use invalid categories."
        exit 1  # Non-zero exit code signals failure
    }
}
catch {
    Log "Error: $($_.Exception.Message)"
    Write-Output "Error in QA Validator: $($_.Exception.Message)"
    exit 1
}
