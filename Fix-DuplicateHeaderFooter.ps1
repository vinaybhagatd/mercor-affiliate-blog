<# 
Fix-DuplicateHeaderFooter.ps1
- Scans .njk files for duplicate <header> and <footer> blocks outside _includes
- Removes them so only canonical includes are used
- Cleans footer.njk to remove "Invalid DateTime" text
#>

$projectRoot = "C:\Users\LMTest\promotional\mercor-affiliate-blog\src"
$files = Get-ChildItem -Path $projectRoot -Recurse -Include *.njk

foreach ($file in $files) {
    # Skip canonical includes
    if ($file.FullName -match "\\_includes\\header.njk" -or
        $file.FullName -match "\\_includes\\footer.njk") {
        continue
    }

    $content = Get-Content $file.FullName -Raw

    # Detect header/footer blocks
    $hasHeader = $content -match "<header>"
    $hasFooter = $content -match "<footer>"

    if ($hasHeader -or $hasFooter) {
        Write-Host "Duplicate header/footer found in $($file.FullName)"

        # Remove header/footer blocks
        $cleaned = $content -replace "(?s)<header>.*?</header>", ""
        $cleaned = $cleaned -replace "(?s)<footer>.*?</footer>", ""

        # Save cleaned file
        Set-Content -Path $file.FullName -Value $cleaned -Encoding UTF8
        Write-Host "Cleaned header/footer from $($file.Name)"
    }
}

# Fix footer.njk Invalid DateTime issue
$footerPath = Join-Path $projectRoot "_includes\footer.njk"
if (Test-Path $footerPath) {
    $footerContent = Get-Content $footerPath -Raw

    # Replace any Invalid DateTime logic with static text
    $footerCleaned = $footerContent -replace "{{.*?date.*?}}", ""

    # Ensure canonical footer
    $footerCleaned = "<footer>`r`n  <p>&copy; Mercor Affiliate Blog System</p>`r`n</footer>"

    Set-Content -Path $footerPath -Value $footerCleaned -Encoding UTF8
    Write-Host "Fixed footer.njk to remove Invalid DateTime text."
}
