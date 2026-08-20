<#
.SYNOPSIS
RenameFiles.ps1
- Creates a backup of all blog .html files
- Renames *-thumbnail.jpg → .png
- Updates blog .html files to reference new names
- Removes YAML front-matter and injects <meta> tags
#>

$blogDir   = "C:\Users\LMTest\promotional\mercor-affiliate-blog\blogs"
$imageDir  = "C:\Users\LMTest\promotional\mercor-affiliate-blog\_site\assets\images\thumbnails"
$backupDir = Join-Path $blogDir "backup"

# Step 0: Backup blog files
if (-not (Test-Path $backupDir)) {
    New-Item -ItemType Directory -Path $backupDir | Out-Null
}
Get-ChildItem -Path $blogDir -Filter "*.html" | ForEach-Object {
    Copy-Item $_.FullName -Destination $backupDir -Force
}
Write-Host "📂 Backup complete: all blog .html files copied to $backupDir"

# Step 1: Rename image files
if (Test-Path $imageDir) {
    Get-ChildItem -Path $imageDir -Filter "*-thumbnail.jpg" | ForEach-Object {
        $newName = $_.Name -replace "-thumbnail\.jpg$", ".png"
        Rename-Item -Path $_.FullName -NewName $newName
        Write-Host "Renamed $($_.Name) → $newName"
    }
} else {
    Write-Warning "Image directory not found: $imageDir"
}

# Step 2: Update blog HTML files
Get-ChildItem -Path $blogDir -Filter "*.html" | ForEach-Object {
    $content = Get-Content $_.FullName -Raw

    # Remove any YAML front-matter block (--- ... ---)
    $content = $content -replace '(?s)---.*?---', ''

    # Replace thumbnail references with new .png names
    $content = $content -replace '/images/([A-Za-z0-9]+)-thumbnail\.jpg', '/images/$1.png'

    # Infer category from filename (e.g., creative-blogs.html → creative)
$category = ($_.BaseName -split '-')[0]

$metaBlock = @"
    <meta name="canonical" content="https://mercor-affiliate-blog.com/$category/future-remote-careers">
    <meta name="category" content="$category">
    <meta name="thumbnail" content="C:\Users\LMTest\promotional\mercor-affiliate-blog\assets  \images\thumbnails\$category.png">
"@

    # Insert meta tags after <head>
    $content = $content -replace '(<head.*?>)', "`$1`n$metaBlock"


    # Save updated content
    Set-Content -Path $_.FullName -Value $content -Encoding UTF8
    Write-Host "Patched $($_.Name)"
}

Write-Host "✅ Patch complete: backup created, thumbnails renamed, blogs updated, YAML removed."
