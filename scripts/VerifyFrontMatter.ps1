<#
.SYNOPSIS
Verifies the front matter of Markdown posts for categories and tags.

.DESCRIPTION
This script checks each Markdown file in the 'src/posts' directory for valid category and tag fields.
It ensures that categories are correctly formatted and that tags include a mandatory category field, followed by optional tags.

.EXAMPLE
VerifyFrontMatter.ps1

.NOTES
- This script uses regex to validate front matter fields. It is designed to be efficient and easy to understand.
- The script does not use external modules, ensuring it can run on any Windows system.
- The script prints detailed rules indicating whether each file's front matter is valid or not.

#>
param()

# Define the path to the source directory containing Markdown files
$sourceFolderPath = "C:\Users\LMTest\promotional\mercor-affiliate-blog\src\posts"

# Get a list of all .md files in the source folder
$files = Get-ChildItem -Path $sourceFolderPath -Filter *.md

foreach ($file in $files) {
    Write-Output "▶ Verifying front matter: $($file.Name)"

    # Read and parse the content of the Markdown file using regex
    $content = [regex]::Matches((Get-Content $file.FullName -Raw), '<%.*?>(.*?)</%.*?>')
    if ($content.Count -eq 0) {
        Write-Output "❌ Missing front matter in $($file.Name)"
        continue
    }

    # Extract and normalize the category and tags from the front matter
    $categoryMatch = $content[1].Groups["Category"]
    $tagsMatch = $content[1].Groups["Tags"]

    if (-not $categoryMatch.Success) {
        Write-Output "⚠ <filename> tags do not include category [<category>]"
        continue
    }

    $category = $categoryMatch.Groups[1].Value.ToLower()
    $tags = $tagsMatch.Groups[1].Value.ToLower().Split(',')

    # Check if the category field is present and contains a mandatory tag
    if (-not $category) {
        Write-Output "❌ Missing category or tags in <filename>"
        continue
    }

    # Output the status of each file's front matter
    if ($tags -contains $category) {
        Write-Output "✅ <filename> front matter valid"
    } else {
        Write-Output "⚠ <filename> tags do not include category [<category>]"
    }
}

# Completion message
Write-Output "=== VerifyFrontMatter.ps1 complete. ==="
