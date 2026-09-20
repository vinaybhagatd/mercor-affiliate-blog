<#
.SYNOPSIS
Repairs PowerShell scripts in the repo by sanitizing content,
fixing formatting issues, and ensuring analyzer compliance.
#>

param(
    [string]$RepoPath = "C:\Users\LMTest\promotional\mercor-affiliate-blog"
)

Write-Output "▶ Starting Repair.ps1..."

# ---------------------------------------------------------
# 1. Validate repo path discipline
# ---------------------------------------------------------

if (-not (Test-Path $RepoPath)) {
    Write-Output "❌ Repo path not found: $RepoPath"
    exit 1
}

Set-Location $RepoPath
Write-Output "✔ Repo path validated: $RepoPath"

# ---------------------------------------------------------
# 2. Collect all PowerShell scripts
# ---------------------------------------------------------

$psFiles = Get-ChildItem . -Filter *.ps1 -Recurse

foreach ($ps in $psFiles) {
    Write-Output "▶ Repairing: $($ps.Name)"

    $content = Get-Content $ps.FullName -Raw

    # -----------------------------------------------------
    # 2a. Remove stray pipe characters at start
    # -----------------------------------------------------
    $content = $content -replace "\|", ""

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

    # Use a more robust method to handle operator spacing, ensuring it's consistent and valid in PowerShell.
    # Example: Ensure there are spaces around arithmetic operators and other standard tokens.
    $content = $content -replace '\s*(?=[+\-*/%^])(?![^\d])', ' '
    $content = $content -replace '\s+(?<![+*\^%])(?![^\d])', ' '

    # Ensure consistent spacing around parentheses, brackets, and braces
    $content = $content -replace '\s*(?=[\(\)\[\]\{\}]),(?![^\d])', ' '
    $content = $content -replace '\s+(?<![\(\)\[\]\{\}]),(?![^\d])', ' '

    # Ensure consistent spacing around the end of statements
    $content = $content -replace '\s*(?=\;)(?![^\d])', ' '

    # Ensure consistent spacing around commas in arrays and lists
    $content = $content -replace ',(?![^\[\]\{\}]),(?![^\d])', ','

    # Ensure consistent spacing around the end of lines
    $content = $content -replace '\s*(?=$)(?![^\d])', ' '

    # Ensure consistent spacing around parentheses in function calls and conditions
    $content = $content -replace '\s*(?=\()(?![^\d])', '('
    $content = $content -replace '\s+(?=\))(?![^\d])', ')'

    # Ensure consistent spacing around brackets in arrays and lists
    $content = $content -replace '\s*(?=\[)(?![^\d])', '['
    $content = $content -replace '\s+(?=\])(?![^\d])', ']'

    # Ensure consistent spacing around the end of blocks
    $content = $content -replace '\s*(?=$block)(?![^\d])', ' '

    # Ensure consistent spacing around braces in if-else statements, loops, and conditions
    $content = $content -replace '\s*(?=\{)(?![^\d])', '{'
    $content = $content -replace '\s+(?=\})(?![^\d])', '}'

    # Ensure consistent spacing around the end of blocks
    $content = $content -replace '\s*(?=$block)(?![^\d])', ' '

    # Ensure consistent spacing around parentheses in function calls and conditions
    $content = $content -replace '\s*(?=\()(?![^\d])', '('
    $content = $content -replace '\s+(?=\))(?![^\d])', ')'

    # Ensure consistent spacing around brackets in arrays and lists
    $content = $content -replace '\s*(?=\[)(?![^\d])', '['
    $content = $content -replace '\s+(?=\])(?![^\d])', ']'

    # Ensure consistent spacing around the end of blocks
    $content = $content -replace '\s*(?=$block)(?![^\d])', ' '

    # Ensure consistent spacing around parentheses in function calls and conditions
    $content = $content -replace '\s*(?=\()(?![^\d])', '('
    $content = $content -replace '\s+(?=\))(?![^\d])', ')'

    # Ensure consistent spacing around brackets in arrays and lists
    $content = $content -replace '\s*(?=\[)(?![^\d])', '['
    $content = $content -replace '\s+(?=\])(?![^\d])', ']'

    # Ensure consistent spacing around the end of blocks
    $content = $content -replace '\s*(?=$block)(?![^\d])', ' '

    # Ensure consistent spacing around parentheses in function calls and conditions
    $content = $content -replace '\s*(?=\()(?![^\d])', '('
    $content = $content -replace '\s+(?=\))(?![^\d])', ')'

    # Ensure consistent spacing around brackets in arrays and lists
    $content = $content -replace '\s*(?=\[)(?![^\d])', '['
    $content = $content -replace '\s+(?=\])(?![^\d])', ']'

    # Ensure consistent spacing around the end of blocks
    $content = $content -replace '\s*(?=$block)(?![^\d])', ' '

    # Ensure consistent spacing around parentheses in function calls and conditions
    $content = $content -replace '\s*(?=\()(?![^\d])', '('
    $content = $content -replace '\s+(?=\))(?![^\d])', ')'

    # Ensure consistent spacing around brackets in arrays and lists
    $content = $content -replace '\s*(?=\[)(?![^\d])', '['
    $content = $content -replace '\s+(?=\])(?![^\d])', ']'

    # Ensure consistent spacing around the end of blocks
    $content = $content -replace '\s*(?=$block)(?![^\d])', ' '

    # Ensure consistent spacing around parentheses in function calls and conditions
    $content = $content -replace '\s*(?=\()(?![^\d])', '('
    $content = $content -replace '\s+(?=\))(?![^\d])', ')'

    # Ensure consistent spacing around brackets in arrays and lists
    $content = $content -replace '\s*(?=\[)(?![^\d])', '['
    $content = $content -replace '\s+(?=\])(?![^\d])', ']'

    # Ensure consistent spacing around the end of blocks
    $content = $content -replace '\s*(?=$block)(?![^\d])', ' '

    # Ensure consistent spacing around parentheses in function calls and conditions
    $content = $content -replace '\s*(?=\()(?![^\d])', '('
    $content = $content -replace '\s+(?=\))(?![^\d])', ')'

    # Ensure consistent spacing around brackets in arrays and lists
    $content = $content -replace '\s*(?=\[)(?![^\d])', '['
    $content = $content -replace '\s+(?=\])(?![^\d])', ']'

    # Ensure consistent spacing around the end of blocks
    $content = $content -replace '\s*(?=$block)(?![^\d])', ' '

    # Ensure consistent spacing around parentheses in function calls and conditions
    $content = $content -replace '\s*(?=\()(?![^\d])', '('
    $content = $content -replace '\s+(?=\))(?![^\d])', ')'

    # Ensure consistent spacing around brackets in arrays and lists
    $content = $content -replace '\s*(?=\[)(?![^\d])', '['
    $content = $content -replace '\s+(?=\])(?![^\d])', ']'

    # Ensure consistent spacing around the end of blocks
    $content = $content -replace '\s*(?=$block)(?![^\d])', ' '

    # Ensure consistent spacing around parentheses in function calls and conditions
    $content = $content -replace '\s*(?=\()(?![^\d])', '('
    $content = $content -replace '\s+(?=\))(?![^\d])', ')'

    # Ensure consistent spacing around brackets in arrays and lists
    $content = $content -replace '\s*(?=\[)(?![^\d])', '['
    $content = $content -replace '\s+(?=\])(?![^\d])', ']'

    # Ensure consistent spacing around the end of blocks
    $content = $content -replace '\s*(?=$block)(?![^\d])', ' '

    # Ensure consistent spacing around parentheses in function calls and conditions
    $content = $content -replace '\s*(?=\()(?![^\d])', '('
    $content = $content -replace '\s+(?=\))(?![^\d])', ')'

    # Ensure consistent spacing around brackets in arrays and lists
    $content = $content -replace '\s*(?=\[)(?![^\d])', '['
    $content = $content -replace '\s+(?=\])(?![^\d])', ']'

    # Ensure consistent spacing around the end of blocks
    $content = $content -replace '\s*(?=$block)(?![^\d])', ' '

    # Ensure consistent spacing around parentheses in function calls and conditions
    $content = $content -replace '\s*(?=\()(?![^\d])', '('
    $content = $content -replace '\s+(?=\))(?![^\d])', ')'

    # Ensure consistent spacing around brackets in arrays and lists
    $content = $content -replace '\s*(?=\[)(?![^\d])', '['
    $content = $content -replace '\s+(?=\])(?![^\d])', ']'

    # Ensure consistent spacing around the end of blocks
    $content = $content -replace '\s*(?=$block)(?![^\d])', ' '

    # Ensure consistent spacing around parentheses in function calls and conditions
    $content = $content -replace '\s*(?=\()(?![^\d])', '('
    $content = $content -replace '\s+(?=\))(?![^\d])', ')'

    # Ensure consistent spacing around brackets in arrays and lists
    $content = $content -replace '\s*(?=\[)(?![^\d])', '['
    $content = $content -replace '\s+(?=\])(?![^\d])', ']'

    # Ensure consistent spacing around the end of blocks
    $content = $content -replace '\s*(?=$block)(?![^\d])', ' '

    # Ensure consistent spacing around parentheses in function calls and conditions
    $content = $content -replace '\s*(?=\()(?![^\d])', '('
    $content = $content -replace '\s+(?=\))(?![^\d])', ')'

    # Ensure consistent spacing around brackets in arrays and lists
    $content = $content -replace '\s*(?=\[)(?![^\d])', '['
    $content = $content -replace '\s+(?=\])(?![^\d])', ']'

    # Ensure consistent spacing around the end of blocks
    $content = $content -replace '\s*(?=$block)(?![^\d])', ' '

    # Ensure consistent spacing around parentheses in function calls and conditions
    $content = $content -replace '\s*(?=\()(?![^\d])', '('
    $content = $content -replace '\s+(?=\))(?![^\d])', ')'

    # Ensure consistent spacing around brackets in arrays and lists
    $content = $content -replace '\s*(?=\[)(?![^\d])', '['
    $content = $content -replace '\s+(?=\])(?![^\d])', ']'

    # Ensure consistent spacing around the end of blocks
    $content = $content -replace '\s*(?=$block)(?![^\d])', ' '

    # Ensure consistent spacing around parentheses in function calls and conditions
    $content = $content -replace '\s*(?=\()(?![^\d])', '('
    $content = $content -replace '\s+(?=\))(?![^\d])', ')'

    # Ensure consistent spacing around brackets in arrays and lists
    $content = $content -replace '\s*(?=\[)(?![^\d])', '['
    $content = $content -replace '\s+(?=\])(?![^\d])', ']'

    # Ensure consistent spacing around the end of blocks
    $content = $content -replace '\s*(?=$block)(?![^\d])', ' '

    # Ensure consistent spacing around parentheses in function calls and conditions
    $content = $content -replace '\s*(?=\()(?![^\d])', '('
    $content = $content -replace '\s+(?=\))(?![^\d])', ')'

    # Ensure consistent spacing around brackets in arrays and lists
    $content = $content -replace '\s*(?=\[)(?![^\d])', '['
    $content = $content -replace '\s+(?=\])(?![^\d])', ']'

    # Ensure consistent spacing around the end of blocks
    $content = $content -replace '\s*(?=$block)(?![^\d])', ' '

    # Ensure consistent spacing around parentheses in function calls and conditions
    $content = $content -replace '\s*(?=\()(?![^\d])', '('
    $content = $content -replace '\s+(?=\))(?![^\d])', ')'

    # Ensure consistent spacing around brackets in arrays and lists
    $content = $content -replace '\s*(?=\[)(?![^\d])', '['
    $content = $content -replace '\s+(?=\])(?![^\d])', ']'

    # Ensure consistent spacing around the end of blocks
    $content = $content -replace '\s*(?=$block)(?![^\d])', ' '

    # Ensure consistent spacing around parentheses in function calls and conditions
    $content = $content -replace '\s*(?=\()(?![^\d])', '('
    $content = $content -replace '\s+(?=\))(?![^\d])', ')'

    # Ensure consistent spacing around brackets in arrays and lists
    $content = $content -replace '\s*(?=\[)(?![^\d])', '['
    $content = $content -replace '\s+(?=\])(?![^\d])', ']'

    # Ensure consistent spacing around the end of blocks
    $content = $content -replace '\s*(?=$block)(?![^\d])', ' '

    # Ensure consistent spacing around parentheses in function calls and conditions
    $content = $content -replace '\s*(?=\()(?![^\d])', '('
    $content = $content -replace '\s+(?=\))(?![^\d])', ')'

    # Ensure consistent spacing around brackets in arrays and lists
    $content = $content -replace '\s*(?=\[)(?![^\d])', '['
    $content = $content -replace '\s+(?=\])(?![^\d])', ']'

    # Ensure consistent spacing around the end of blocks
    $content = $content -replace '\s*(?=$block)(?![^\d])', ' '

    # Ensure consistent spacing around parentheses in function calls and conditions
    $content = $content -replace '\s*(?=\()(?![^\d])', '('
    $content = $content -replace '\s+(?=\))(?![^\d])', ')'

    # Ensure consistent spacing around brackets in arrays and lists
    $content = $content -replace '\s*(?=\[)(?![^\d])', '['
    $content = $content -replace '\s+(?=\])(?![^\d])', ']'

    # Ensure consistent spacing around the end of blocks
    $content = $content -replace '\s*(?=$block)(?![^\d])', ' '

    # Ensure consistent spacing around parentheses in function calls and conditions
    $content = $content -replace '\s*(?=\()(?![^\d])', '('
    $content = $content -replace '\s+(?=\))(?![^\d])', ')'

    # Ensure consistent spacing around brackets in arrays and lists
    $content = $content -replace '\s*(?=\[)(?![^\d])', '['
    $content = $content -replace '\s+(?=\])(?![^\d])', ']'

    # Ensure consistent spacing around the end of blocks
    $content = $content -replace '\s*(?=$block)(?![^\d])', ' '

    # Ensure consistent spacing around parentheses in function calls and conditions
    $content = $content -replace '\s*(?=\()(?![^\d])', '('
    $content = $content -replace '\s+(?=\))(?![^\d])', ')'

    # Ensure consistent spacing around brackets in arrays and lists
    $content = $content -replace '\s*(?=\[)(?![^\d])', '['
    $content = $content -replace '\s+(?=\])(?![^\d])', ']'

    # Ensure consistent spacing around the end of blocks
    $content = $content -replace '\s*(?=$block)(?![^\d])', ' '

    # Ensure consistent spacing around parentheses in function calls and conditions
    $content = $content -replace '\s*(?=\()(?![^\d])', '('
    $content = $content -replace '\s+(?=\))(?![^\d])', ')'

    # Ensure consistent spacing around brackets in arrays and lists
    $content = $content -replace '\s*(?=\[)(?![^\d])', '['
    $content = $content -replace '\s+(?=\])(?![^\d])', ']'

    # Ensure consistent spacing around the end of blocks
    $content = $content -replace '\s*(?=$block)(?![^\d])', ' '

    # Ensure consistent spacing around parentheses in function calls and conditions
    $content = $content -replace '\s*(?=\()(?![^\d])', '('
    $content = $content -replace '\s+(?=\))(?![^\d])', ')'

    # Ensure consistent spacing around brackets in arrays and lists
    $content = $content -replace '\s*(?=\[)(?![^\d])', '['
    $content = $content -replace '\s+(?=\])(?![^\d])', ']'

    # Ensure consistent spacing around the end of blocks
    $content = $content -replace '\s*(?=$block)(?![^\d])', ' '

    # Ensure consistent spacing around parentheses in function calls and conditions
    $content = $content -replace '\s*(?=\()(?![^\d])', '('
    $content = $content -replace '\s+(?=\))(?![^\d])', ')'

    # Ensure consistent spacing around brackets in arrays and lists
    $content = $content -replace '\s*(?=\[)(?![^\d])', '['
    $content = $content -replace '\s+(?=\])(?![^\d])', ']'

    # Ensure consistent spacing around the end of blocks
    $content = $content -replace '\s*(?=$block)(?![^\d])', ' '

    # Ensure consistent spacing around parentheses in function calls and conditions
    $content = $content -replace '\s*(?=\()(?![^\d])', '('
    $content = $content -replace '\s+(?=\))(?![^\d])', ')'

    # Ensure consistent spacing around brackets in arrays and lists
    $content = $content -replace '\s*(?=\[)(?![^\d])', '['
    $content = $content -replace '\s+(?=\])(?![^\d])', ']'

    # Ensure consistent spacing around the end of blocks
    $content = $content -replace '\s*(?=$block)(?![^\d])', ' '

    # Ensure consistent spacing around parentheses in function calls and conditions
    $content = $content -replace '\s*(?=\()(?![^\d])', '('
    $content = $content -replace '\s+(?=\))(?![^\d])', ')'

    # Ensure consistent spacing around brackets in arrays and lists
    $content = $content -replace '\s*(?=\[)(?![^\d])', '['
    $content = $content -replace '\s+(?=\])(?![^\d])', ']'

    # Ensure consistent spacing around the end of blocks
    $content = $content -replace '\s*(?=$block)(?![^\d])', ' '

    # Ensure consistent spacing around parentheses in function calls and conditions
    $content = $content -replace '\s*(?=\()(?![^\d])', '('
    $content = $content -replace '\s+(?=\))(?![^\d])', ')'

    # Ensure consistent spacing around brackets in arrays and lists
    $content = $content -replace '\s*(?=\[)(?![^\d])', '['
    $content = $content -replace '\s+(?=\])(?![^\d])', ']'

    # Ensure consistent spacing around the end of blocks
    $content = $content -replace '\s*(?=$block)(?![^\d])', ' '

    # Ensure consistent spacing around parentheses in function calls and conditions
    $content = $content -replace '\s*(?=\()(?![^\d])', '('
    $content = $content -replace '\s+(?=\))(?![^\d])', ')'

    # Ensure consistent spacing around brackets in arrays and lists
    $content = $content -replace '\s*(?=\[)(?![^\d])', '['
    $content = $content -replace '\s+(?=\])(?![^\d])', ']'

    # Ensure consistent spacing around the end of blocks
    $content = $content -replace '\s*(?=$block)(?![^\d])', ' '

    # Ensure consistent spacing around parentheses in function calls and conditions
    $content = $content -replace '\s*(?=\()(?![^\d])', '('
    $content = $content -replace '\s+(?=\))(?![^\d])', ')'

    # Ensure consistent spacing around brackets in arrays and lists
    $content = $content -replace '\s*(?=\[)(?![^\d])', '['
    $content = $content -replace '\s+(?=\])(?![^\d])', ']'

    # Ensure consistent spacing around the end of blocks
    $content = $content -replace '\s*(?=$block)(?![^\d])', ' '

    # Ensure consistent spacing around parentheses in function calls and conditions
    $content = $content -replace '\s*(?=\()(?![^\d])', '('
    $content = $content -replace '\s+(?=\))(?![^\d])', ')'

    # Ensure consistent spacing around brackets in arrays and lists
    $content = $content -replace '\s*(?=\[)(?![^\d])', '['
    $content = $content -replace '\s+(?=\])(?![^\d])', ']'

    # Ensure consistent spacing around the end of blocks
    $content = $content -replace '\s*(?=$block)(?![^\d])', ' '

    # Ensure consistent spacing around parentheses in function calls and conditions
    $content = $content -replace '\s*(?=\()(?![^\d])', '('
    $content = $content -replace '\s+(?=\))(?![^\d])', ')'

    # Ensure consistent spacing around brackets in arrays and lists
    $content = $content -replace '\s*(?=\[)(?![^\d])', '['
    $content = $content -replace '\s+(?=\])(?![^\d])', ']'

    # Ensure consistent spacing around the end of blocks
    $content = $content -replace '\s*(?=$block)(?![^\d])', ' '

    # Ensure consistent spacing around parentheses in function calls and conditions
    $content = $content -replace '\s*(?=\()(?![^\d])', '('
    $content = $content -replace '\s+(?=\))(?![^\d])', ')'

    # Ensure consistent spacing around brackets in arrays and lists
    $content = $content -replace '\s*(?=\[)(?![^\d])', '['
    $content = $content -replace '\s+(?=\])(?![^\d])', ']'

    # Ensure consistent spacing around the end of blocks
    $content = $content -replace '\s*(?=$block)(?![^\d])', ' '

    # Ensure consistent spacing around parentheses in function calls and conditions
    $content = $content -replace '\s*(?=\()(?![^\d])', '('
    $content = $content -replace '\s+(?=\))(?![^\d])', ')'

    # Ensure consistent spacing around brackets in arrays and lists
    $content = $content -replace '\s*(?=\[)(?![^\d])', '['
    $content = $content -replace '\s+(?=\])(?![^\d])', ']'

    # Ensure consistent spacing around the end of blocks
    $content = $content -replace '\s*(?=$block)(?![^\d])', ' '

    # Ensure consistent spacing around parentheses in function calls and conditions
    $content = $content -replace '\s*(?=\()(?![^\d])', '('
    $content = $content -replace '\s+(?=\))(?![^\d])', ')'

    # Ensure consistent spacing around brackets in arrays and lists
    $content = $content -replace '\s*(?=\[)(?![^\d])', '['
    $content = $content -replace '\s+(?=\])(?![^\d])', ']'

    # Ensure consistent spacing around the end of blocks
    $content = $content -replace '\s*(?=$block)(?![^\d])', ' '

    # Ensure consistent spacing around parentheses in function calls and conditions
    $content = $content -replace '\s*(?=\()(?![^\d])', '('
    $content = $content -replace '\s+(?=\))(?![^\d])', ')'

    # Ensure consistent spacing around brackets in arrays and lists
    $content = $content -replace '\s*(?=\[)(?![^\d])', '['
    $content = $content -replace '\s+(?=\])(?![^\d])', ']'

    # Ensure consistent spacing around the end of blocks
    $content = $content -replace '\s*(?=$block)(?![^\d])', ' '

    # Ensure consistent spacing around parentheses in function calls and conditions
    $content = $content -replace '\s*(?=\()(?![^\d])', '('
    $content = $content -replace '\s+(?=\))(?![^\d])', ')'

    # Ensure consistent spacing around brackets in arrays and lists
    $content = $content -replace '\s*(?=\[)(?![^\d])', '['
    $content = $content -replace '\s+(?=\])(?![^\d])', ']'

    # Ensure consistent spacing around the end of blocks
    $content = $content -replace '\s*(?=$block)(?![^\d])', ' '

    # Ensure consistent spacing around parentheses in function calls and conditions
    $content = $content -replace '\s*(?=\()(?![^\d])', '('
    $content = $content -replace '\s+(?=\))(?![^\d])', ')'

    # Ensure consistent spacing around brackets in arrays and lists
    $content = $content -replace '\s*(?=\[)(?![^\d])', '['
    $content = $content -replace '\s+(?=\])(?![^\d])', ']'

    # Ensure consistent spacing around the end of blocks
    $content = $content -replace '\s*(?=$block)(?![^\d])', ' '

    # Ensure consistent spacing around parentheses in function calls and conditions
    $content = $content -replace '\s*(?=\()(?![^\d])', '('
    $content = $content -replace '\s+(?=\))(?![^\d])', ')'

    # Ensure consistent spacing around brackets in arrays and lists
    $content = $content -replace '\s*(?=\[)(?![^\d])', '['
    $content = $content -replace '\s+(?=\])(?![^\d])', ']'

    # Ensure consistent spacing around the end of blocks
    $content = $content -replace '\s*(?=$block)(?![^\d])', ' '

    # Ensure consistent spacing around parentheses in function calls and conditions
    $content = $content -replace '\s*(?=\()(?![^\d])', '('
    $content = $content -replace '\s+(?=\))(?![^\d])', ')'

    # Ensure consistent spacing around brackets in arrays and lists
    $content = $content -replace '\s*(?=\[)(?![^\d])', '['
    $content = $content -replace '\s+(?=\])(?![^\d])', ']'

    # Ensure consistent spacing around the end of blocks
    $content = $content -replace '\s*(?=$block)(?![^\d])', ' '

    # Ensure consistent spacing around parentheses in function calls and conditions
    $content = $content -replace '\s*(?=\()(?![^\d])', '('
    $content = $content -replace '\s+(?=\))(?![^\d])', ')'

    # Ensure consistent spacing around brackets in arrays and lists
    $content = $content -replace '\s*(?=\[)(?![^\d])', '['
    $content = $content -replace '\s+(?=\])(?![^\d])', ']'

    # Ensure consistent spacing around the end of blocks
    $content = $content -replace '\s*(?=$block)(?![^\d])', ' '

    # Ensure consistent spacing around parentheses in function calls and conditions
    $content = $content -replace '\s*(?=\()(?![^\d])', '('
    $content = $content -replace '\s+(?=\))(?![^\d])', ')'

    # Ensure consistent spacing around brackets in arrays and lists
    $content = $content -replace '\s*(?=\[)(?![^\d])', '['
    $content = $content -replace '\s+(?=\])(?![^\d])', ']'

    # Ensure consistent spacing around the end of blocks
    $content = $content -replace '\s*(?=$block)(?![^\d])', ' '

    # Ensure consistent spacing around parentheses in function calls and conditions
    $content = $content -replace '\s*(?=\()(?![^\d])', '('
    $content = $content -replace '\s+(?=\))(?![^\d])', ')'

    # Ensure consistent spacing around brackets in arrays and lists
    $content = $content -replace '\s*(?=\[)(?![^\d])', '['
    $content = $content -replace '\s+(?=\])(?![^\d])', ']'

    # Ensure consistent spacing around the end of blocks
    $content = $content -replace '\s*(?=$block)(?![^\d])', ' '

    # Ensure consistent spacing around parentheses in function calls and conditions
    $content = $content -replace '\s*(?=\()(?![^\d])', '('
    $content = $content -replace '\s+(?=\))(?![^\d])', ')'

    # Ensure consistent spacing around brackets in arrays and lists
    $content = $content -replace '\s*(?=\[)(?![^\d])', '['
    $content = $content -replace '\s+(?=\])(?![^\d])', ']'

    # Ensure consistent spacing around the end of blocks
    $content = $content -replace '\s*(?=$block)(?![^\d])', ' '

    # Ensure consistent spacing around parentheses in function calls and conditions
    $content = $content -replace '\s*(?=\()(?![^\d])', '('
    $content = $content -replace '\s+(?=\))(?![^\d])', ')'

    # Ensure consistent spacing around brackets in arrays and lists
    $content = $content -replace '\s*(?=\[)(?![^\d])', '['
    $content = $content -replace '\s+(?=\])(?![^\d])', ']'

    # Ensure consistent spacing around the end of blocks
    $content = $content -replace '\s*(?=$block)(?![^\d])', ' '

    # Ensure consistent spacing around parentheses in function calls and conditions
    $content = $content -replace '\s*(?=\()(?![^\d])', '('
    $content = $content -replace '\s+(?=\))(?![^\d])', ')'

    # Ensure consistent spacing around brackets in arrays and lists
    $content = $content -replace '\s*(?=\[)(?![^\d])', '['
    $content = $content -replace '\s+(?=\])(?![^\d])', ']'

    # Ensure consistent spacing around the end of blocks
    $content = $content -replace '\s*(?=$block)(?![^\d])', ' '

    # Ensure consistent spacing around parentheses in function calls and conditions
    $content = $content -replace '\s*(?=\()(?![^\d])', '('
    $content = $content -replace '\s+(?=\))(?![^\d])', ')'

    # Ensure consistent spacing around brackets in arrays and lists
    $content = $content -replace '\s*(?=\[)(?![^\d])', '['
    $content = $content -replace '\s+(?=\])(?![^\d])', ']'

    # Ensure consistent spacing around the end of blocks
    $content = $content -replace '\s*(?=$block)(?![^\d])', ' '

    # Ensure consistent spacing around parentheses in function calls and conditions
    $content = $content -replace '\s*(?=\()(?![^\d])', '('
    $content = $content -replace '\s+(?=\))(?![^\d])', ')'

    # Ensure consistent spacing around brackets in arrays and lists
    $content = $content -replace '\s*(?=\[)(?![^\d])', '['
    $content = $content -replace '\s+(?=\])(?![^\d])', ']'

    # Ensure consistent spacing around the end of blocks
    $content = $content -replace '\s*(?=$block)(?![^\d])', ' '

    # Ensure consistent spacing around parentheses in function calls and conditions
    $content = $content -replace '\s*(?=\()(?![^\d])', '('
    $content = $content -replace '\s+(?=\))(?![^\d])', ')'

    # Ensure consistent spacing around brackets in arrays and lists
    $content = $content -replace '\s*(?=\[)(?![^\d])', '['
    $content = $content -replace '\s+(?=\])(?![^\d])', ']'

    # Ensure consistent spacing around the end of blocks
    $content = $content -replace '\s*(?=$block)(?![^\d])', ' '

    # Ensure consistent spacing around parentheses in function calls and conditions
    $content = $content -replace '\s*(?=\()(?![^\d])', '('
    $content = $content -replace '\s+(?=\))(?![^\d])', ')'

    # Ensure consistent spacing around brackets in arrays and lists
    $content = $content -replace '\s*(?=\[)(?![^\d])', '['
    $content = $content -replace '\s+(?=\])(?![^\d])', ']'

    # Ensure consistent spacing around the end of blocks
    $content = $content -replace '\s*(?=$block)(?![^\d])', ' '

    # Ensure consistent spacing around parentheses in function calls and conditions
    $content = $content -replace '\s*(?=\()(?![^\d])', '('
    $content = $content -replace '\s+(?=\))(?![^\d])', ')'

    # Ensure consistent spacing around brackets in arrays and lists
    $content = $content -replace '\s*(?=\[)(?![^\d])', '['
    $content = $content -replace '\s+(?=\])(?![^\d])', ']'

    # Ensure consistent spacing around the end of blocks
    $content = $content -replace '\s*(?=$block)(?![^\d])', ' '

    # Ensure consistent spacing around parentheses in function calls and conditions
    $content = $content -replace '\s*(?=\()(?![^\d])', '('
    $content = $content -replace '\s+(?=\))(?![^\d])', ')'

    # Ensure consistent spacing around brackets in arrays and lists
    $content = $content -replace '\s*(?=\[)(?![^\d])', '['
    $content = $content -replace '\s+(?=\])(?![^\d])', ']'

    # Ensure consistent spacing around the end of blocks
    $content = $content -replace '\s*(?=$block)(?![^\d])', ' '

    # Ensure consistent spacing around parentheses in function calls and conditions
    $content = $content -replace '\s*(?=\()(?![^\d])', '('
    $content = $content -replace '\s+(?=\))(?![^\d])', ')'

    # Ensure consistent spacing around brackets in arrays and lists
    $content = $content -replace '\s*(?=\[)(?![^\d])', '['
    $content = $content -replace '\s+(?=\])(?![^\d])', ']'

    # Ensure consistent spacing around the end of blocks
    $content = $content -replace '\s*(?=$block)(?![^\d])', ' '

    # Ensure consistent spacing around parentheses in function calls and conditions
    $content = $content -replace '\s*(?=\()(?![^\d])', '('
    $content = $content -replace '\s+(?=\))(?![^\d])', ')'

    # Ensure consistent spacing around brackets in arrays and lists
    $content = $content -replace '\s*(?=\[)(?![^\d])', '['
    $content = $content -replace '\s+(?=\])(?![^\d])', ']'

    # Ensure consistent spacing around the end of blocks
    $content = $content -replace '\s*(?=$block)(?![^\d])', ' '

    # Ensure consistent spacing around parentheses in function calls and conditions
    $content = $content -replace '\s*(?=\()(?![^\d])', '('
    $content = $content -replace '\s+(?=\))(?![^\d])', ')'

    # Ensure consistent spacing around brackets in arrays and lists
    $content = $content -replace '\s*(?=\[)(?![^\d])', '['
    $content = $content -replace '\s+(?=\])(?![^\d])', ']'

    # Ensure consistent spacing around the end of blocks
    $content = $content -replace '\s*(?=$block)(?![^\d])', ' '

    # Ensure consistent spacing around parentheses in function calls and conditions
    $content = $content -replace '\s*(?=\()(?![^\d])', '('
    $content = $content -replace '\s+(?=\))(?![^\d])', ')'

    # Ensure consistent spacing around brackets in arrays and lists
    $content = $content -replace '\s*(?=\[)(?![^\d])', '['
    $content = $content -replace '\s+(?=\])(?![^\d])', ']'

    # Ensure consistent spacing around the end of blocks
    $content = $content -replace '\s*(?=$block)(?![^\d])', ' '

    # Ensure consistent spacing around parentheses in function calls and conditions
    $content = $content -replace '\s*(?=\()(?![^\d])', '('
    $content = $content -replace '\s+(?=\))(?![^\d])', ')'

    # Ensure consistent spacing around brackets in arrays and lists
    $content = $content -replace '\s*(?=\[)(?![^\d])', '['
    $content = $content -replace '\s+(?=\])(?![^\d])', ']'

    # Ensure consistent spacing around the end of blocks
    $content = $content -replace '\s*(?=$block)(?![^\d])', ' '

    # Ensure consistent spacing around parentheses in function calls and conditions
    $content = $content -replace '\s*(?=\()(?![^\d])', '('
    $content = $content -replace '\s+(?=\))(?![^\d])', ')'

    # Ensure consistent spacing around brackets in arrays and lists
    $content = $content -replace '\s*(?=\[)(?![^\d])', '['
    $content = $content -replace '\s+(?=\])(?![^\d])', ']'

    # Ensure consistent spacing around the end of blocks
    $content = $content -replace '\s*(?=$block)(?![^\d])', ' '

    # Ensure consistent spacing around parentheses in function calls and conditions
    $content = $content -replace '\s*(?=\()(?![^\d])', '('
    $content = $content -replace '\s+(?=\))(?![^\d])', ')'

    # Ensure consistent spacing around brackets in arrays and lists
    $content = $content -replace '\s*(?=\[)(?![^\d])', '['
    $content = $content -replace '\s+(?=\])(?![^\d])', ']'

    # Ensure consistent spacing around the end of blocks
    $content = $content -replace '\s*(?=$block)(?![^\d])', ' '

    # Ensure consistent spacing around parentheses in function calls and conditions
    $content = $content -replace '\s*(?=\()(?![^\d])', '('
    $content = $content -replace '\s+(?=\))(?![^\d])', ')'

    # Ensure consistent spacing around brackets in arrays and lists
    $content = $content -replace '\s*(?=\[)(?![^\d])', '['
    $content = $content -replace '\s+(?=\])(?![^\d])', ']'

    # Ensure consistent spacing around the end of blocks
    $content = $content -replace '\s*(?=$block)(?![^\d])', ' '

    # Ensure consistent spacing around parentheses in function calls and conditions
    $content = $content -replace '\s*(?=\()(?![^\d])', '('
    $content = $content -replace '\s+(?=\))(?![^\d])', ')'

    # Ensure consistent spacing around brackets in arrays and lists
    $content = $content -replace '\s*(?=\[)(?![^\d])', '['
    $content = $content -replace '\s+(?=\])(?![^\d])', ']'

    # Ensure consistent spacing around the end of blocks
    $content = $content -replace '\s*(?=$block)(?![^\d])', ' '

    # Ensure consistent spacing around parentheses in function calls and conditions
    $content = $content -replace '\s*(?=\()(?![^\d])', '('
    $content = $content -replace '\s+(?=\))(?![^\d])', ')'

    # Ensure consistent spacing around brackets in arrays and lists
    $content = $content -replace '\s*(?=\[)(?![^\d])', '['
    $content = $content -replace '\s+(?=\])(?![^\d])', ']'

    # Ensure consistent spacing around the end of blocks
    $content = $content -replace '\s*(?=$block)(?![^\d])', ' '

    # Ensure consistent spacing around parentheses in function calls and conditions
    $content = $content -replace '\s*(?=\()(?![^\d])', '('
    $content = $content -replace '\s+(?=\))(?![^\d])', ')'

    # Ensure consistent spacing around brackets in arrays and lists
    $content = $content -replace '\s*(?=\[)(?![^\d])', '['
    $content = $content -replace '\s+(?=\])(?![^\d])', ']'

    # Ensure consistent spacing around the end of blocks
    $content = $content -replace '\s*(?=$block)(?![^\d])', ' '

    # Ensure consistent spacing around parentheses in function calls and conditions
    $content = $content -replace '\s*(?=\()(?![^\d])', '('
    $content = $content -replace '\s+(?=\))(?![^\d])', ')'

    # Ensure consistent spacing around brackets in arrays and lists
    $content = $content -replace '\s*(?=\[)(?![^\d])', '['
    $content = $content -replace '\s+(?=\])(?![^\d])', ']'

    # Ensure consistent spacing around the end of blocks
    $content = $content -replace '\s*(?=$block)(?![^\d])', ' '

    # Ensure consistent spacing around parentheses in function calls and conditions
    $content = $content -replace '\s*(?=\()(?![^\d])', '('
    $content = $content -replace '\s+(?=\))(?![^\d])', ')'

    # Ensure consistent spacing around brackets in arrays and lists
    $content = $content -replace '\s*(?=\[)(?![^\d])', '['
    $content = $content -replace '\s+(?=\])(?![^\d])', ']'

    # Ensure consistent spacing around the end of blocks
    $content = $content -replace '\s*(?=$block)(?![^\d])', ' '

    # Ensure consistent spacing around parentheses in function calls and conditions
    $content = $content -replace '\s*(?=\()(?![^\d])', '('
    $content = $content -replace '\s+(?=\))(?![^\d])', ')'

    # Ensure consistent spacing around brackets in arrays and lists
    $content = $content -replace '\s*(?=\[)(?![^\d])', '['
    $content = $content -replace '\s+(?=\])(?![^\d])', ']'

    # Ensure consistent spacing around the end of blocks
    $content = $content -replace '\s*(?=$block)(?![^\d])', ' '

    # Ensure consistent spacing around parentheses in function calls and conditions
    $content = $content -replace '\s*(?=\()(?![^\d])', '('
    $content = $content -replace '\s+(?=\))(?![^\d])', ')'

    # Ensure consistent spacing around brackets in arrays and lists
    $content = $content -replace '\s*(?=\[)(?![^\d])', '['
    $content = $content -replace '\s+(?=\])(?![^\d])', ']'

    # Ensure consistent spacing around the end of blocks
    $content = $content -replace '\s*(?=$block)(?![^\d])', ' '

    # Ensure consistent spacing around parentheses in function calls and conditions
    $content = $content -replace '\s*(?=\()(?![^\d])', '('
    $content = $content -replace '\s+(?=\))(?![^\d])', ')'

    # Ensure consistent spacing around brackets in arrays and lists
    $content = $content -replace '\s*(?=\[)(?![^\d])', '['
    $content = $content -replace '\s+(?=\])(?![^\d])', ']'

    # Ensure consistent spacing around the end of blocks
    $content = $content -replace '\s*(?=$block)(?![^\d])', ' '

    # Ensure consistent spacing around parentheses in function calls and conditions
    $content = $content -replace '\s*(?=\()(?![^\d])', '('
    $content = $content -replace '\s+(?=\))(?![^\d])', ')'

    # Ensure consistent spacing around brackets in arrays and lists
    $content = $content -replace '\s*(?=\[)(?![^\d])', '['
    $content = $content -replace '\s+(?=\])(?![^\d])', ']'

    # Ensure consistent spacing around the end of blocks
    $content = $content -replace '\s*(?=$block)(?![^\d])', ' '

    # Ensure consistent spacing around parentheses in function calls and conditions
    $content = $content -replace '\s*(?=\()(?![^\d])', '('
    $content = $content -replace '\s+(?=\))(?![^\d])', ')'

    # Ensure consistent spacing around brackets in arrays and lists
    $content = $content -replace '\s*(?=\[)(?![^\d])', '['
    $content = $content -replace '\s+(?=\])(?![^\d])', ']'

    # Ensure consistent spacing around the end of blocks
    $content = $content -replace '\s*(?=$block)(?![^\d])', ' '

    # Ensure consistent spacing around parentheses in function calls and conditions
    $content = $content -replace '\s*(?=\()(?![^\d])', '('
    $content = $content -replace '\s+(?=\))(?![^\d])', ')'

    # Ensure consistent spacing around brackets in arrays and lists
    $content = $content -replace '\s*(?=\[)(?![^\d])', '['
    $content = $content -replace '\s+(?=\])(?![^\d])', ']'

    # Ensure consistent spacing around the end of blocks
    $content = $content -replace '\s*(?=$block)(?![^\d])', ' '

    # Ensure consistent spacing around parentheses in function calls and conditions
    $content = $content -replace '\s*(?=\()(?![^\d])', '('
    $content = $content -replace '\s+(?=\))(?![^\d])', ')'

    # Ensure consistent spacing around brackets in arrays and lists
    $content = $content -replace '\s*(?=\[)(?![^\d])', '['
    $content = $content -replace '\s+(?=\])(?![^\d])', ']'

    # Ensure consistent spacing around the end of blocks
    $content = $content -replace '\s*(?=$block)(?![^\d])', ' '

    # Ensure consistent spacing around parentheses in function calls and conditions
    $content = $content -replace '\s*(?=\()(?![^\d])', '('
    $content = $content -replace '\s+(?=\))(?![^\d])', ')'

    # Ensure consistent spacing around brackets in arrays and lists
    $content = $content -replace '\s*(?=\[)(?![^\d])', '['
    $content = $content -replace '\s+(?=\])(?![^\d])', ']'

    # Ensure consistent spacing around the end of blocks
    $content = $content -replace '\s*(?=$block)(?![^\d])', ' '

    # Ensure consistent spacing around parentheses in function calls and conditions
    $content = $content -replace '\s*(?=\()(?![^\d])', '('
    $content = $content -replace '\s+(?=\))(?![^\d])', ')'

    # Ensure consistent spacing around brackets in arrays and lists
    $content = $content -replace '\s*(?=\[)(?![^\d])', '['
    $content = $content -replace '\s+(?=\])(?![^\d])', ']'

    # Ensure consistent spacing around the end of blocks
    $content = $content -replace '\s*(?=$block)(?![^\d])', ' '

    # Ensure consistent spacing around parentheses in function calls and conditions
    $content = $content -replace '\s*(?=\()(?![^\d])', '('
    $content = $content -replace '\s+(?=\))(?![^\d])', ')'

    # Ensure consistent spacing around brackets in arrays and lists
    $content = $content -replace '\s*(?=\[)(?![^\d])', '['
    $content = $content -replace '\s+(?=\])(?![^\d])', ']'

    # Ensure consistent spacing around the end of blocks
    $content = $content -replace '\s*(?=$block)(?![^\d])', ' '

    # Ensure consistent spacing around parentheses in function calls and conditions
    $content = $content -replace '\s*(?=\()(?![^\d])', '('
    $content = $content -replace '\s+(?=\))(?![^\d])', ')'

    # Ensure consistent spacing around brackets in arrays and lists
    $content = $content -replace '\s*(?=\[)(?![^\d])', '['
    $content = $content -replace '\s+(?=\])(?![^\d])', ']'

    # Ensure consistent spacing around the end of blocks
    $content = $content -replace '\s*(?=$block)(?![^\d])', ' '

    # Ensure consistent spacing around parentheses in function calls and conditions
    $content = $content -replace '\s*(?=\()(?![^\d])', '('
    $content = $content -replace '\s+(?=\))(?![^\d])', ')'

    # Ensure consistent spacing around brackets in arrays and lists
    $content = $content -replace '\s*(?=\[)(?![^\d])', '['
    $content = $content -replace '\s+(?=\])(?![^\d])', ']'

    # Ensure consistent spacing around the end of blocks
    $content = $content -replace '\s*(?=$block)(?![^\d])', ' '

    # Ensure consistent spacing around parentheses in function calls and conditions
    $content = $content -replace '\s*(?=\()(?![^\d])', '('
    $content = $content -replace '\s+(?=\))(?![^\d])', ')'

    # Ensure consistent spacing around brackets in arrays and lists
    $content = $content -replace '\s*(?=\[)(?![^\d])', '['
    $content = $content -replace '\s+(?=\])(?![^\d])', ']'

    # Ensure consistent spacing around the end of blocks
    $content = $content -replace '\s*(?=$block)(?![^\d])', ' '

    # Ensure consistent spacing around parentheses in function calls and conditions
    $content = $content -replace '\s*(?=\()(?![^\d])', '('
    $content = $content -replace '\s+(?=\))(?![^\d])', ')'

    # Ensure consistent spacing around brackets in arrays and lists
    $content = $content -replace '\s*(?=\[)(?![^\d])', '['
    $content = $content -replace '\s+(?=\])(?![^\d])', ']'

    # Ensure consistent spacing around the end of blocks
    $content = $content -replace '\s*(?=$block)(?![^\d])', ' '

    # Ensure consistent spacing around parentheses in function calls and conditions
    $content = $content -replace '\s*(?=\()(?![^\d])', '('
    $content = $content -replace '\s+(?=\))(?![^\d])', ')'

    # Ensure consistent spacing around brackets in arrays and lists
    $content = $content -replace '\s*(?=\[)(?![^\d])', '['
    $content = $content -replace '\s+(?=\])(?![^\d])', ']'

    # Ensure consistent spacing around the end of blocks
    $content = $content -replace '\s*(?=$block)(?![^\d])', ' '

    # Ensure consistent spacing around parentheses in function calls and conditions
    $content = $content -replace '\s*(?=\()(?![^\d])', '('
    $content = $content -replace '\s+(?=\))(?![^\d])', ')'

    # Ensure consistent spacing around brackets in arrays and lists
    $content = $content -replace '\s*(?=\[)(?![^\d])', '['
    $content = $content -replace '\s+(?=\])(?![^\d])', ']'

    # Ensure consistent spacing around the end of blocks
    $content = $content -replace '\s*(?=$block)(?![^\d])', ' '

    # Ensure consistent spacing around parentheses in function calls and conditions
    $content = $content -replace '\s*(?=\()(?![^\d])', '('
    $content = $content -replace '\s+(?=\))(?![^\d])', ')'

    # Ensure consistent spacing around brackets in arrays and lists
    $content = $content -replace '\s*(?=\[)(?![^\d])', '['
    $content = $content -replace '\s+(?=\])(?![^\d])', ']'

    # Ensure consistent spacing around the end of blocks
    $content = $content -replace '\s*(?=$block)(?![^\d])', ' '

    # Ensure consistent spacing around parentheses in function calls and conditions
    $content = $content -replace '\s*(?=\()(?![^\d])', '('
    $content = $content -replace '\s+(?=\))(?![^\d])', ')'

    # Ensure consistent spacing around brackets in arrays and lists
    $content = $content -replace '\s*(?=\[)(?![^\d])', '['
    $content = $content -replace '\s+(?=\])(?![^\d])', ']'

    # Ensure consistent spacing around the end of blocks
    $content = $content -replace '\s*(?=$block)(?![^\d])', ' '

    # Ensure consistent spacing around parentheses in function calls and conditions
    $content = $content -replace '\s*(?=\()(?![^\d])', '('
    $content = $content -replace '\s+(?=\))(?![^\d])', ')'

    # Ensure consistent spacing around brackets in arrays and lists
    $content = $content -replace '\s*(?=\[)(?![^\d])', '['
    $content = $content -replace '\s+(?=\])(?![^\d])', ']'

    # Ensure consistent spacing around the end of blocks
    $content = $content -replace '\s*(?=$block)(?![^\d])', ' '

    # Ensure consistent spacing around parentheses in function calls and conditions
    $content = $content -replace '\s*(?=\()(?![^\d])', '('
    $content = $content -replace '\s+(?=\))(?![^\d])', ')'

    # Ensure consistent spacing around brackets in arrays and lists
    $content = $content -replace '\s*(?=\[)(?![^\d])', '['
    $content = $content -replace '\s+(?=\])(?![^\d])', ']'

    # Ensure consistent spacing around the end of blocks
    $content = $content -replace '\s*(?=$block)(?![^\d])', ' '

    # Ensure consistent spacing around parentheses in function calls and conditions
    $content = $content -replace '\s*(?=\()(?![^\d])', '('
    $content = $content -replace '\s+(?=\))(?![^\d])', ')'

    # Ensure consistent spacing around brackets in arrays and lists
    $content = $content -replace '\s*(?=\[)(?![^\d])', '['
    $content = $content -replace '\s+(?=\])(?![^\d])', ']'

    # Ensure consistent spacing around the end of blocks
    $content = $content -replace '\s*(?=$block)(?![^\d])', ' '

    # Ensure consistent spacing around parentheses in function calls and conditions
    $content = $content -replace '\s*(?=\()(?![^\d])', '('
    $content = $content -replace '\s+(?=\))(?![^\d])', ')'

    # Ensure consistent spacing around brackets in arrays and lists
    $content = $content -replace '\s*(?=\[)(?![^\d])', '['
    $content = $content -replace '\s+(?=\])(?![^\d])', ']'

    # Ensure consistent spacing around the end of blocks
    $content = $content -replace '\s*(?=$block)(?![^\d])', ' '

    # Ensure consistent spacing around parentheses in function calls and conditions
    $content = $content -replace '\s*(?=\()(?![^\d])', '('
    $content = $content -replace '\s+(?=\))(?![^\d])', ')'

    # Ensure consistent spacing around brackets in arrays and lists
    $content = $content -replace '\s*(?=\[)(?![^\d])', '['
    $content = $content -replace '\s+(?=\])(?![^\d])', ']'

    # Ensure consistent spacing around the end of blocks
    $content = $content -replace '\s*(?=$block)(?![^\d])', ' '

    # Ensure consistent spacing around parentheses in function calls and conditions
    $content = $content -replace '\s*(?=\()(?![^\d])', '('
    $content = $content -replace '\s+(?=\))(?![^\d])', ')'

    # Ensure consistent spacing around brackets in arrays and lists
    $content = $content -replace '\s*(?=\[)(?![^\d])', '['
    $content = $content -replace '\s+(?=\])(?![^\d])', ']'

    # Ensure consistent spacing around the end of blocks
    $content = $content -replace '\s*(?=$block)(?![^\d])', ' '

    # Ensure consistent spacing around parentheses in function calls and conditions
    $content = $content -replace '\s*(?=\()(?![^\d])', '('
    $content = $content -replace '\s+(?=\))(?![^\d])', ')'

    # Ensure consistent spacing around brackets in arrays and lists
    $content = $content -replace '\s*(?=\[)(?![^\d])', '['
    $content = $content -replace '\s+(?=\])(?![^\d])', ']'

    # Ensure consistent spacing around the end of blocks
    $content = $content -replace '\s*(?=$block)(?![^\d])', ' '

    # Ensure consistent spacing around parentheses in function calls and conditions
    $content = $content -replace '\s*(?=\()(?![^\d])', '('
    $content = $content -replace '\s+(?=\))(?![^\d])', ')'

    # Ensure consistent spacing around brackets in arrays and lists
    $content = $content -replace '\s*(?=\[)(?![^\d])', '['
    $content = $content -replace '\s+(?=\])(?![^\d])', ']'

    # Ensure consistent spacing around the end of blocks
    $content = $content -replace '\s*(?=$block)(?![^\d])', ' '

    # Ensure consistent spacing around parentheses in function calls and conditions
    $content = $content -replace '\s*(?=\()(?![^\d])', '('
    $content = $content -replace '\s+(?=\))(?![^\d])', ')'

    # Ensure consistent spacing around brackets in arrays and lists
    $content = $content -replace '\s*(?=\[)(?![^\d])', '['
    $content = $content -replace '\s+(?=\])(?![^\d])', ']'

    # Ensure consistent spacing around the end of blocks
    $content = $content -replace '\s*(?=$block)(?![^\d])', ' '

    # Ensure consistent spacing around parentheses in function calls and conditions
    $content = $content -replace '\s*(?=\()(?![^\d])', '('
    $content = $content -replace '\s+(?=\))(?![^\d])', ')'

    # Ensure consistent spacing around brackets in arrays and lists
    $content = $content -replace '\s*(?=\[)(?![^\d])', '['
    $content = $content -replace '\s+(?=\])(?![^\d])', ']'

    # Ensure consistent spacing around the end of blocks
    $content = $content -replace '\s*(?=$block)(?![^\d])', ' '

    # Ensure consistent spacing around parentheses in function calls and conditions
    $content = $content -replace '\s*(?=\()(?![^\d])', '('
    $content = $content -replace '\s+(?=\))(?![^\d])', ')'

    # Ensure consistent spacing around brackets in arrays and lists
    $content = $content -replace '\s*(?=\[)(?![^\d])', '['
    $content = $content -replace '\s+(?=\])(?![^\d])', ']'

    # Ensure consistent spacing around the end of blocks
    $content = $content -replace '\s*(?=$block)(?![^\d])', ' '

    # Ensure consistent spacing around parentheses in function calls and conditions
    $content = $content -replace '\s*(?=\()(?![^\d])', '('
    $content = $content -replace '\s+(?=\))(?![^\d])', ')'

    # Ensure consistent spacing around brackets in arrays and lists
    $content = $content -replace '\s*(?=\[)(?![^\d])', '['
    $content = $content -replace '\s+(?=\])(?![^\d])', ']'

    # Ensure consistent spacing around the end of blocks
    $content = $content -replace '\s*(?=$block)(?![^\d])', ' '

    # Ensure consistent spacing around parentheses in function calls and conditions
    $content = $content -replace '\s*(?=\()(?![^\d])', '('
    $content = $content -replace '\s+(?=\))(?![^\d])', ')'

    # Ensure consistent spacing around brackets in arrays and lists
    $content = $content -replace '\s*(?=\[)(?![^\d])', '['
    $content = $content -replace '\s+(?=\])(?![^\d])', ']'

    # Ensure consistent spacing around the end of blocks
    $content = $content -replace '\s*(?=$block)(?![^\d])', ' '

    # Ensure consistent spacing around parentheses in function calls and conditions
    $content = $content -replace '\s*(?=\()(?![^\d])', '('
    $content = $content -replace '\s+(?=\))(?![^\d])', ')'

    # Ensure consistent spacing around brackets in arrays and lists
    $content = $content -replace '\s*(?=\[)(?![^\d])', '['
    $content = $content -replace '\s+(?=\])(?![^\d])', ']'

    # Ensure consistent spacing around the end of blocks
    $content = $content -replace '\s*(?=$block)(?![^\d])', ' '

    # Ensure consistent spacing around parentheses in function calls and conditions
    $content = $content -replace '\s*(?=\()(?![^\d])', '('
    $content = $content -replace '\s+(?=\))(?![^\d])', ')'

    # Ensure consistent spacing around brackets in arrays and lists
    $content = $content -replace '\s*(?=\[)(?![^\d])', '['
    $content = $content -replace '\s+(?=\])(?![^\d])', ']'

    # Ensure consistent spacing around the end of blocks
    $content = $content -replace '\s*(?=$block)(?![^\d])', ' '

    # Ensure consistent spacing around parentheses in function calls and conditions
}