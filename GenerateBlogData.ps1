<# 
.SYNOPSIS
Generates JSON blog data files for MABS using LM Studio.
Ensures proper folder structure and model availability.
#>

param(
    [string]$OutputDir = ".\BlogData",
    [int]$Count = 11
)

Write-Output "▶ Starting Blog Data Generation..."

# ---------------------------------------------------------
# 1. Ensure output folder exists
# ---------------------------------------------------------

if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir | Out-Null
    Write-Output "✔ Created missing folder: $OutputDir"
} else {
    Write-Output "✔ Output folder exists: $OutputDir"
}

# ---------------------------------------------------------
# 2. Ensure LM Studio model available
# ---------------------------------------------------------

$lmPath = "C:\Users\LMTest\.lmstudio\bin\lms.exe"
$model = "qwen2.5-coder-1.5b-instruct"

try {
    $modelList = & $lmPath ls
    if ($modelList -notmatch $model) {
        Write-Output "⚠️ Model missing. Attempting download..."
        & $lmPath get $model
        Write-Output "✔ Model downloaded: $model"
    } else {
        Write-Output "✔ Model available: $model"
    }
}
catch {
    Write-Output "❌ LM Studio not accessible."
    exit 1
}

# ---------------------------------------------------------
# 3. Generate JSON blog data files
# ---------------------------------------------------------

for ($i = 1; $i -le $Count; $i++) {
    $fileName = Join-Path $OutputDir ("BlogData_$i.json")

    # Example JSON structure (replace with LM Studio inference integration)
    $jsonContent = @{
        id = $i
        title = "Blog Post $i"
        category = "tech"
        content = "Generated content placeholder for blog $i."
        timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    } | ConvertTo-Json -Depth 3

    $jsonContent | Out-File $fileName -Encoding UTF8
    Write-Output "✔ Generated JSON file: $fileName"
}

# ---------------------------------------------------------
# Final Output
# ---------------------------------------------------------

Write-Output "`n==============================="
Write-Output "   BLOG DATA GENERATION SUMMARY"
Write-Output "==============================="
Write-Output "✔ $Count JSON files generated in $OutputDir"
      