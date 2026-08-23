<# 
.SYNOPSIS
Generates a single blog post (JSON + Markdown) for testing.
#>

param(
    [int]$BlogNumber = 1,
    [string]$RepoPath = "C:\Users\LMTest\promotional\mercor-affiliate-blog",
    [string]$ModelPath = "C:\Users\LMTest\.lmstudio\bin\lms.exe",
    [string]$PreferredModel = "qwen2.5-coder-1.5b-instruct"
)

Write-Output "▶ Starting OneBlog.ps1 for Blog $BlogNumber..."

# ---------------------------------------------------------
# 1. Validate repo path
# ---------------------------------------------------------
if (-not (Test-Path $RepoPath)) {
    Write-Output "❌ Repo path not found: $RepoPath"
    exit 1
}
Set-Location $RepoPath

# ---------------------------------------------------------
# 2. Detect available models
# ---------------------------------------------------------
Write-Output "▶ Checking LM Studio models..."
$availableModels = & $ModelPath ls

if ($availableModels -match $PreferredModel) {
    $ModelName = $PreferredModel
    Write-Output "✔ Using preferred model: $ModelName"
} else {
    $ModelName = ($availableModels | Select-String "LLM" | ForEach-Object {
        ($_ -split '\s+')[0]
    } | Select-Object -First 1)
    Write-Output "⚠️ Preferred model not found. Falling back to: $ModelName"
}

# ---------------------------------------------------------
# 3. Generate BlogData JSON
# ---------------------------------------------------------
if (-not (Test-Path ".\BlogData")) {
    New-Item -ItemType Directory -Path ".\BlogData" | Out-Null
}

$jsonFile = ".\BlogData\BlogData_$BlogNumber.json"
$jsonPrompt = @"
Generate valid JSON for a blog post with this schema:
{
  "title": "string",
  "category": "one of [tech, finance, medicine, sciences, engineering, operations, language, law, creative, misc, data]",
  "date": "YYYY-MM-DD HH:mm:ss",
  "content": "string with publish-ready blog text"
}
Ensure the category matches the intended topic and the JSON is valid.
Blog number: $BlogNumber
"@
& $ModelPath chat $ModelName -p $jsonPrompt | Out-File $jsonFile -Encoding UTF8
Write-Output "✔ Generated JSON file: $jsonFile"

# ---------------------------------------------------------
# 4. Generate Markdown Blog
# ---------------------------------------------------------
if (-not (Test-Path ".\GeneratedBlogs")) {
    New-Item -ItemType Directory -Path ".\GeneratedBlogs" | Out-Null
}

$mdFile = ".\GeneratedBlogs\BlogData_$BlogNumber.md"
$mdPrompt = "Generate publish-ready blog post $BlogNumber with YAML front matter, SEO metadata, and affiliate CTA. Ensure content matches the category and is not placeholder."
& $ModelPath chat $ModelName -p $mdPrompt | Out-File $mdFile -Encoding UTF8
Write-Output "✔ Generated blog: $mdFile"

# ---------------------------------------------------------
# Final Output
# ---------------------------------------------------------
Write-Output "`n==============================="
Write-Output "        ONE BLOG GENERATION"
Write-Output "==============================="
Write-Output "✔ Blog $BlogNumber generated successfully."
      