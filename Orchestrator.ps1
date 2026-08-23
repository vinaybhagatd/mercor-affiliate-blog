<# 
.SYNOPSIS
Runs the full MABS pipeline:
Generate JSON → Generate Blogs → QA → Eleventy → Git Publish.
#>

param(
    [string]$JsonFolder = ".\BlogData",
    [string]$BlogsFolder = ".\GeneratedBlogs",
    [string]$SiteFolder = ".\mercor-affiliate-blog\_site"
)

Write-Output "▶ Starting MABS Orchestrator..."

# ---------------------------------------------------------
# Step 1: Ensure LM Studio model available
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
# Step 2: Generate JSON files
# ---------------------------------------------------------

Write-Output "▶ Generating JSON files..."
.\GenerateBlogData.ps1 -OutputDir $JsonFolder
Write-Output "✔ JSON generation complete."

# ---------------------------------------------------------
# Step 3: Generate Blogs from JSON
# ---------------------------------------------------------

Write-Output "▶ Generating blogs..."
.\BatchCreateBlogs.ps1 -JsonFolder $JsonFolder -OutputDir $BlogsFolder
Write-Output "✔ Blog generation complete."

# ---------------------------------------------------------
# Step 4: Run QA Validator
# ---------------------------------------------------------

Write-Output "▶ Running QA validation..."
.\QAValidator.ps1 -InputDir $BlogsFolder
Write-Output "✔ QA validation complete."

# ---------------------------------------------------------
# Step 5: Build Eleventy Site
# ---------------------------------------------------------

Write-Output "▶ Building Eleventy site..."
npx @11ty/eleventy --input $BlogsFolder --output $SiteFolder
Write-Output "✔ Eleventy build complete."

# ---------------------------------------------------------
# Step 6: Git Commit + Push
# ---------------------------------------------------------

try {
    git add .
    git commit -m "Automated MABS publish"
    git push origin main
    Write-Output "✔ Git publish complete."
}
catch {
    Write-Output "⚠️ Git publish failed. Check remote configuration."
}

# ---------------------------------------------------------
# Final Output
# ---------------------------------------------------------

Write-Output "`n==============================="
Write-Output "        MABS ORCHESTRATOR"
Write-Output "==============================="
Write-Output "✔ Full pipeline executed successfully."
