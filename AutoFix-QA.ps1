# Automated analyzer, debugger, and fixer for MABS scripts.
# Implements the four guardrail solutions from RunQwenFix.ps1:
# 1. Remove stray pipe characters at script start
# 2. Wrap metadata in <# ... #> blocks
# 3. Correct operator spacing and quoting
# 4. Auto-retry loop with ScriptAnalyzer validation

param(
    [string]$TargetDir = "C:\Users\LMTest\promotional\mercor-affiliate-blog",
    [switch]$All
)

function Log {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Output "$timestamp - $Message"
}

function Analyze-And-Fix($file) {
    Log "Fixing $($file.FullName) ..."

    $content = Get-Content $file.FullName -Raw

    # 1. Remove stray pipe characters at start
    $content = $content -replace "^\|+", ""

    # 2. Wrap metadata in comment-based help if missing
    if ($content -match "^\s*\.SYNOPSIS") {
        $content = $content -replace "^\s*(\.SYNOPSIS.*?)(?=\r?\n)", "<#`n$1"
        if ($content -notmatch "<#.*\.DESCRIPTION") {
            $content = $content -replace "(\.DESCRIPTION.*?)(?=\r?\n)", "$1`n#>"
        }
    }

    # 3. Correct operator spacing and wildcard quoting
    $content = $content -replace "\+=", "+="
    $content = $content -replace "-Filter\s+\*\.md", '-Filter "*.md"'

    # 4. Save temp file and run ScriptAnalyzer with auto-retry
    $tempFile = "$($file.FullName).tmp"
    $content | Out-File -FilePath $tempFile -Encoding UTF8

    $maxRetries = 3
    $retry = 0
    $success = $false

    while (-not $success -and $retry -lt $maxRetries) {
        Log "Running ScriptAnalyzer (attempt $($retry+1)) ..."
        $results = Invoke-ScriptAnalyzer -Path $tempFile -Severity Error -ErrorAction SilentlyContinue
        if (-not $results) {
            Log "$($file.Name) passed ScriptAnalyzer validation."
            Move-Item -Force $tempFile $file.FullName
            $success = $true
        } else {
            Log "Errors found in $($file.Name):"
            $results | ForEach-Object { Log $_.Message }
            # Attempt auto-fix: sanitize headers/comments
            $content = $content -replace "^\s*using\s+.*", "# Removed invalid using"
            $content = $content -replace "^\s*`", ""   # remove stray backticks
            $content | Out-File -FilePath $tempFile -Encoding UTF8
        }
        $retry++
    }

    if (-not $success) {
        Log "Failed to auto-fix $($file.Name) after $maxRetries retries."
        Remove-Item $tempFile -ErrorAction SilentlyContinue
    }
}

# Main execution
if ($All) {
    $files = Get-ChildItem -Path $TargetDir -Recurse -Filter "*.ps1"
    foreach ($file in $files) {
        Analyze-And-Fix $file
    }
} else {
    Log "Please specify -All or provide a file path."
}

