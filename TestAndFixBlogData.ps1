<#
.SYNOPSIS
  Repairs blog post front matter by inserting or correcting affiliate links.

.DESCRIPTION
  Scans all Markdown files in src/posts/, ensures each has the canonical
  affiliate link https://t.mercor.com/a2rcw. Missing links are inserted,
  mismatched links are replaced. Logs all changes to console.
#>

$repoRoot = "C:\Users\LMTest\promotional\mercor-affiliate-blog"
$postsPath = Join-Path $repoRoot "src\posts"
$canonicalLink = "https://t.mercor.com/a2rcw"

Write-Host "=== TestAndFixBlogData.ps1 started ==="

Get-ChildItem -Path $postsPath -Filter "*.md" | ForEach-Object {
    $file = $_.FullName
    $content = Get-Content $file -Raw

    if ($content -match "https://t\.mercor\.com/") {
        if ($content -notmatch [Regex]::Escape($canonicalLink)) {
            # Replace any mismatched link
            $fixed = $content -replace "https://t\.mercor\.com/[A-Za-z0-9]+", $canonicalLink
            Set-Content -Path $file -Value $fixed
            Write-Host "Replaced mismatched affiliate link in $($_.Name)"
        } else {
            Write-Host "Affiliate link already correct in $($_.Name)"
        }
    } else {
        # Hardened fallback insertion logic
        $lines = Get-Content $file
        $frontMatterIndices = ($lines | Select-String "^---$").LineNumber

        if ($frontMatterIndices.Count -ge 2) {
            # Normal case: insert before closing ---
            $insertIndex = $frontMatterIndices[1] - 1
            $lines = $lines[0..$insertIndex] + "affiliate: $canonicalLink" + $lines[($insertIndex+1)..($lines.Length-1)]
            Set-Content -Path $file -Value $lines
            Write-Host "Inserted missing affiliate link into $($_.Name)"
        }
        elseif ($frontMatterIndices.Count -eq 1) {
            # Malformed front matter: only one ---
            $insertIndex = $frontMatterIndices[0]
            $lines = $lines[0..$insertIndex] + "affiliate: $canonicalLink" + "---" + $lines[($insertIndex+1)..($lines.Length-1)]
            Set-Content -Path $file -Value $lines
            Write-Host "Inserted affiliate link into malformed front matter in $($_.Name)"
        }
        else {
            # No front matter at all: create one
            $newContent = @("---","affiliate: $canonicalLink","---") + $lines
            Set-Content -Path $file -Value $newContent
            Write-Host "Created front matter and inserted affiliate link into $($_.Name)"
        }
    }
}

Write-Host "=== TestAndFixBlogData.ps1 complete. Affiliate links normalized. ==="
