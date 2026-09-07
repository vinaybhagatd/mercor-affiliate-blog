<#
.SYNOPSIS
  Repairs front matter in MABS blog posts.
.DESCRIPTION
  Iterates through all Markdown files in src/posts,
  replaces `category:` with `tags: ["…"]`,
  enforces `layout: post.njk`,
  and ensures a single valid `date:` line (YYYY-MM-DD).
  If no valid date is found, inserts today's date.
#>

$postsPath = "C:\Users\LMTest\promotional\mercor-affiliate-blog\src\posts"

Get-ChildItem $postsPath -Filter *.md | ForEach-Object {
    $file = $_.FullName
    $content = Get-Content $file -Raw

    # Replace category: value with tags: ["value"]
    $content = $content -replace '(?m)^category:\s*(\S+)', 'tags: ["$1"]'

    # Ensure layout: post.njk exists in front matter
    if ($content -notmatch '(?m)^layout:\s*post\.njk') {
        $content = $content -replace '(?m)^---(\r?\n)(.*?)(\r?\n)---', {
            param($m)
            "---$($m.Groups[1].Value)$($m.Groups[2].Value)`r`nlayout: post.njk$($m.Groups[3].Value)---"
        }
    }

    # Remove ALL existing date lines (to avoid duplicates)
    $content = $content -replace '(?m)^date:.*$', ''

    # Insert a single valid date line
    $today = Get-Date -Format "yyyy-MM-dd"
    if ($content -match '(?m)^title:.*$') {
        $content = $content -replace '(?m)(^title:.*$)', "`$1`r`ndate: `"$today`""
    } else {
        # If no title found, just add date at the top of front matter
        $content = $content -replace '(?m)^---$', "---`r`ndate: `"$today`""
    }

    # Write back to file
    Set-Content $file $content -NoNewline
    Write-Host "Fixed front matter in $($_.Name)"
}

Write-Host "✅ Front matter repair complete. Run QAValidator.ps1 to confirm."
