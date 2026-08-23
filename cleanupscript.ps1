param(
    [string]$scriptDir = "C:\Users\LMTest\promotional\mercor-affiliate-blog",
    [string]$outputDir = "$scriptDir\cleaned"
)

# Ensure output directory exists
if (-not (Test-Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir | Out-Null
}

# Get all .ps1 files in the script directory
Get-ChildItem -Path $scriptDir -Filter "*.ps1" | ForEach-Object {
    $filePath = $_.FullName
    $fileContent = Get-Content -Path $filePath -Raw

    # Clean content: remove comments, blank lines, and non-essential code
    $cleanedContent = $fileContent |
        Where-Object { !($_.Trim() -eq '') } |  # Keep only non-empty lines
        Where-Object { $_ -notmatch '^\s*#.*$' } |  # Remove comments starting with #
        Where-Object { $_ -notmatch '^$\s*$' } |  # Remove empty lines
        Where-Object { $_ -notmatch '^[ \t\r\n]*|[^a-zA-Z0-9 ]+$' } |  # Remove special characters

    # Replace specific strings in the cleaned content
    $cleanedContent = $cleanedContent -replace 'md-coder-qwen3-8b:5', 'md-coder-qwen3-8b'

    # Write cleaned content back to the file
    Set-Content -Path $filePath -Value $cleanedContent -Encoding UTF8
}
