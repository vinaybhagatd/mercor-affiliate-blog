<#
.SYNOPSIS
  Validate-And-Serve.ps1
.DESCRIPTION
  Runs smoke tests, validates folder structure, and launches Eleventy.
#>

$Root = "C:\Users\LMTest\promotional\mercor-affiliate-blog"

Write-Output "=== Validate-And-Serve.ps1 ==="
Write-Output "Running smoke test..."

# Basic folder checks
$folders = @("src\_layouts","src\_includes","src\posts","src\categories","src\assets\css")
foreach ($f in $folders) {
    $path = Join-Path $Root $f
    if (-not (Test-Path $path)) {
        Write-Output "FAIL: Missing $f"
        exit 1
    } else {
        Write-Output "PASS: Found $f"
    }
}

# Launch Eleventy
Write-Output "✅ Smoke test passed. Launching Eleventy..."
npx @11ty/eleventy --serve
