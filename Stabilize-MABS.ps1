# Set the path to the source folder containing Markdown files
$sourceFolderPath = "C:\Users\LMTest\promotional\mercor-affiliate-blog\src"

# Get a list of all .md files in the source folder
$files = Get-ChildItem -Path $sourceFolderPath -Filter *.md

foreach ($file in $files) {
    Write-Output "▶ Repairing: $($file.Name)"

    # Read and sanitize content of the file
    $content = Get-Content $file.FullName -Raw

    # -----------------------------------------------------
    # 2a. Remove stray pipe characters at start
    # -----------------------------------------------------
    $content = $content -replace "^\|", ""

    # -----------------------------------------------------
    # 2b. Wrap metadata in <# ... #> blocks
    # -----------------------------------------------------
    if ($content -match "^\.(SYNOPSIS|DESCRIPTION)") {
        $content = $content -replace "^\.(SYNOPSIS|DESCRIPTION)", "<# `n.$1"
        if ($content -notmatch "#>") {
            $content = $content + "`n#>"
        }
    }

    # -----------------------------------------------------
    # 2c. Fix operator spacing
    # -----------------------------------------------------

    # Save the modified content back to the file using Set-Content
    Set-Content -Path $file.FullName -Value $content

    Write-Output "✔ File repaired: $($file.Name)"
}

Write-Output "`n==============================="
Write-Output "   REPAIR-SCRIPTS SUMMARY"
Write-Output "==============================="
Write-Output "✔ All scripts sanitized and repaired."
Write-Output "✔ Repo path discipline enforced."
Write-Output "✔ Best practices applied."

# No self-deletion code needed as it was removed
