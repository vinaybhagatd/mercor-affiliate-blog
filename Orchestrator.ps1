<# 
.SYNOPSIS
Runs the full Mercor Affiliate Blog System (MABS) pipeline:
Diagnostics → Blog Data → Blog Generation → QA → Eleventy Build → Publish
#>

param(
    [string]$RepoPath = "C:\Users\LMTest\promotional\mercor-affiliate-blog",
    [string]$ModelPath = "C:\Users\LMTest\.lmstudio\bin\lms.exe",
    [string]$ModelName = "qwen/qwen2.5-coder-1.5b-instruct"
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
# 2. Run Diagnostics
# ---------------------------------------------------------
Write-Output "▶ Running diagnostics..."
.\Diagnostics.ps1
Write-Output "✔ Diagnostics complete."

# ---------------------------------------------------------
# 3. Generate Blog Data (JSON)
# ---------------------------------------------------------
Write-Output "▶ Generating Blog Data..."
for ($i=1; $i -le 10; $i++) {
    $outputFile = ".\BlogData\BlogData_$i.json"
    & $ModelPath chat $ModelName -p "Generate structured JSON blog data for post $i" | Out-File $outputFile -Encoding UTF8
    Write-Output "✔ Generated JSON file: $outputFile"
}

# ---------------------------------------------------------
# 4. Generate Blogs (Markdown)
# ---------------------------------------------------------
Write-Output "▶ Generating Blogs..."
if (-not (Test-Path ".\GeneratedBlogs")) {
    New-Item -ItemType Directory -Path ".\GeneratedBlogs" | Out-Null
    Write-Output "✔ Created missing folder: .\GeneratedBlogs"
}

for ($i=1; $i -le 10; $i++) {
    $outputFile = ".\GeneratedBlogs\BlogData_$i.md"
    & $ModelPath chat $ModelName -p "Generate publish-ready blog post $i with YAML front matter, SEO metadata, and affiliate CTA" | Out-File $outputFile -Encoding UTF8
    Write-Output "✔ Generated blog: $outputFile"
}

# ---------------------------------------------------------
# 5. Run QA Validation
# ---------------------------------------------------------
Write-Output "▶ Running QA validation..."
.\QAValidator.ps1
Write-Output "✔ QA validation complete."

# ---------------------------------------------------------
# 6. Build Eleventy Site
# ---------------------------------------------------------
Write-Output "▶ Building Eleventy site..."
npx eleventy
Write-Output "✔ Eleventy build complete."

# ---------------------------------------------------------
# 7. Git Commit & Publish
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
