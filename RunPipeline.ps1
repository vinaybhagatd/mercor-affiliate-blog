# RunPipeline.ps1
# Wrapper to execute the full Mercor Affiliate Blog System pipeline

Write-Host "🚀 Starting Mercor Affiliate Blog System pipeline..."

try {
    # Step 1: Generate blog posts from JSON → Markdown
    .\GenerateBlogData.ps1

    # Step 2: Batch run across multiple JSON files
    .\BatchCreateBlogs.ps1

    # Step 3: Validate posts and categories
    .\QAValidator.ps1

    # Step 4: Orchestrate the full pipeline
    .\Orchestrator.ps1

    # Step 5: Self-heal missing layouts/config
    .\SelfHeal.ps1

    # Step 6: Debug all scripts with Qwen fixes
    .\DebugAllWithQwen.ps1

    Write-Host "✅ Pipeline scripts executed successfully."

    # Step 7: Build and serve with Eleventy
    Write-Host "🌐 Launching Eleventy server..."
    npx eleventy --serve
}
catch {
    Write-Host "❌ Pipeline execution failed: $($_.Exception.Message)"
    exit 1
}
 