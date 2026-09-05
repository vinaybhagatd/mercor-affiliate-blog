# Path to your Jekyll posts folder
$postsPath = "C:\Users\User\promotional\mercor-affiliate-blog\_posts"

# Loop through all markdown files
Get-ChildItem -Path $postsPath -Filter "*.md" | ForEach-Object {

    $file = $_.FullName
    $content = -Path 

    # Replace incorrect category format:
    # categories: creative
    # categories: engineering
    # categories: data
    # etc.
    $fixed = $content -replace '^categories:\s*([A-Za-z0-9_-]+)$', "categories:
  - `$1"

    # Save the updated file
    Set-Content -Path $file -Value $fixed

    Write-Output "Fixed categories in: $file"
}

Write-Output "Bulk category fix complete."







