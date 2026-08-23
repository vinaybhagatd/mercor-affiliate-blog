<# 
.SYNOPSIS
Runs the full Mercor Affiliate Blog System (MABS) pipeline:
Diagnostics → Blog Data → Blog Generation → QA → Eleventy Build → Publish
#>

param(
    [string]$RepoPath = "C:\Users\LMTest\promotional\mercor-affiliate-blog",
    [string]$ModelPath = "C:\Users\LMTest\.lmstudio\bin\lms.exe",
    [string]$PreferredModel = "qwen2.5-coder-1.5b-instruct"
)

Write-Output "▶ Starting MABS Orchestrator..."

# ---------------------------------------------------------
# 1. Validate repo path
# ---------------------------------------------------------
if (-not (Test-Path $RepoPath)) {
    Write-Output "❌ Repo path not found: $RepoPath"
    exit 1
}
Set-Location $RepoPath
Write-Output "✔ Repo path validated: $RepoPath"

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
# 3. Run Diagnostics
# ---------------------------------------------------------
Write-Output "▶ Running diagnostics..."
.\Diagnostics.ps1
Write-Output "✔ Diagnostics complete."

# ---------------------------------------------------------
# 4. Generate Blog Data (JSON)
# ---------------------------------------------------------
Write-Output "▶ Generating Blog Data..."
if (-not (Test-Path ".\BlogData")) {
    New-Item -ItemType Directory -Path ".\BlogData" | Out-Null
}

for ($i=1; $i -le 10; $i++) {
    $outputFile = ".\BlogData\BlogData_$i.json"
    $prompt = @"
Generate valid JSON for a blog post with this schema:
{
  "title": "string",
  "category": "one of [tech, finance, medicine, sciences, engineering, operations, language, law, creative, misc, data]",
  "date": "YYYY-MM-DD HH:mm:ss",
  "content": "string with publish-ready blog text"
}
Ensure the category matches the intended topic and the JSON is valid.
Blog number: $i
"@
    & $ModelPath chat $ModelName -p $prompt | Out-File $outputFile -Encoding UTF8
    Write-Output "✔ Generated JSON file: $outputFile"
}

# ---------------------------------------------------------
# 5. Generate Blogs (Markdown)
# ---------------------------------------------------------
Write-Output "▶ Generating Blogs..."
if (-not (Test-Path ".\GeneratedBlogs")) {
    New-Item -ItemType Directory -Path ".\GeneratedBlogs" | Out-Null
    Write-Output "✔ Created missing folder: .\GeneratedBlogs"
}

for ($i=1; $i -le 10; $i++) {
    $outputFile = ".\GeneratedBlogs\BlogData_$i.md"
    $prompt = "Generate publish-ready blog post $i with YAML front matter, SEO metadata, and affiliate CTA. Ensure content matches the category and is not placeholder."
    & $ModelPath chat $ModelName -p $prompt | Out-File $outputFile -Encoding UTF8
    Write-Output "✔ Generated blog: $outputFile"
}

# ---------------------------------------------------------
# 6. Run QA Validation
# ---------------------------------------------------------
Write-Output "▶ Running QA validation..."
.\QAValidator.ps1
Write-Output "✔ QA validation complete."

# ---------------------------------------------------------
# 7. Build Eleventy Site
# ---------------------------------------------------------
Write-Output "▶ Building Eleventy site..."
npx eleventy
Write-Output "✔ Eleventy build complete."

# ---------------------------------------------------------
# 8. Git Commit & Publish
# ---------------------------------------------------------
Write-Output "▶ Publishing to GitHub..."
git add .
git commit -m "Automated MABS publish"
git push origin main
Write-Output "✔ Git publish complete."

# ---------------------------------------------------------
# Final Output
# ---------------------------------------------------------
Write-Output "`n==============================="
Write-Output "        MABS ORCHESTRATOR"
Write-Output "==============================="
Write-Output "✔ Full pipeline executed successfully."
