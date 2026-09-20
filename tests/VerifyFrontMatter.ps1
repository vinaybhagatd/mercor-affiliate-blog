$hasErrors = $false

Get-ChildItem -Path $postsPath -Recurse -Filter *.md | ForEach-Object {
    $file = $_.FullName
    $content = Get-Content $file -Raw
    $logEntry = "▶ Verifying front matter: $($_.Name)`n"

    if ($content -match "(?s)^---(.*?)---") {
        $yamlBlock = $matches[1]

        $required = @("title", "description", "category", "tags", "thumbnail", "affiliate", "keywords", "layout")
        foreach ($field in $required) {
            if ($yamlBlock -notmatch "(?m)^${field}:") {
                $logEntry += "❌ Missing $field in $($_.Name)`n"
                $hasErrors = $true
            }
        }

        # Ensure category is present in tags
        $categoryMatch = [regex]::Match($yamlBlock, "(?m)^category:\s*(\w+)")
        $tagsMatch = [regex]::Match($yamlBlock, "(?m)^tags:\s*\[(.*?)\]")

        if ($categoryMatch.Success -and $tagsMatch.Success) {
            $categoryNorm = $categoryMatch.Groups[1].Value.Trim().ToLower()
            $tagsNorm = $tagsMatch.Groups[1].Value.Split(',') | ForEach-Object { $_.Trim().ToLower() }
            if (-not ($tagsNorm -contains $categoryNorm)) {
                $logEntry += "❌ Tags missing category in $($_.Name)`n"
                $hasErrors = $true
            }
        }
        if ($logEntry -notmatch "❌") {
            Write-Host "✔ Valid: $($_.Name)" -ForegroundColor Green
            "Valid: $($_.Name)" | Out-File -FilePath $reportFile -Encoding UTF8 -Append
        }
        else {
            Write-Host $logEntry -ForegroundColor Red
            $logEntry | Out-File -FilePath $reportFile -Encoding UTF8 -Append
        }
    }
    else {
        Write-Host "❌ Missing front matter in $($_.Name)" -ForegroundColor Red
        "❌ Missing front matter in $($_.Name)" | Out-File -FilePath $reportFile -Encoding UTF8 -Append
        $hasErrors = $true
    }
}

"=== Run complete: $(Get-Date) ===`n" | Out-File -FilePath $reportFile -Encoding UTF8 -Append
Write-Host "=== VerifyFrontMatter.ps1 complete ===" -ForegroundColor Cyan

if ($hasErrors) {
    exit 1
}
else {
    exit 0
}
