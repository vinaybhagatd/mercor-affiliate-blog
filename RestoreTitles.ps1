# RestoreTitles.ps1
$sourceFolderPath = "C:\Users\LMTest\promotional\mercor-affiliate-blog\src\GeneratedBlogs"

Get-ChildItem -Path $sourceFolderPath -Filter *.md | ForEach-Object {
    $filePath = $_.FullName
    $lines = Get-Content $filePath
    $frontMatter = @()
    $body = @()
    $inFrontMatter = $false
    $titleSet = $false
    $headingTitle = $null

    foreach ($line in $lines) {
        if ($line -match '^\s*---\s*$' -and -not $inFrontMatter -and $frontMatter.Count -eq 0) {
            $inFrontMatter = $true
            continue
        }
        elseif ($line -match '^\s*---\s*$' -and $inFrontMatter) {
            $inFrontMatter = $false
            continue
        }

        if ($inFrontMatter) {
            $frontMatter += $line
            if ($line -match '^title:') { $titleSet = $true }
        }
        else {
            $body += $line
            if (-not $headingTitle -and $line -match '^#\s+(.+)$') {
                $headingTitle = $matches[1]
            }
        }
    }

    # If no title in front matter, restore from heading
    if (-not $titleSet -and $headingTitle) {
        $frontMatter = @("title: `"$headingTitle`"") + $frontMatter
    }

    $newContent = @("---") + $frontMatter + @("---") + $body
    Set-Content -Path $filePath -Value $newContent

    Write-Host "Restored title for $($_.Name): $headingTitle"
}
      