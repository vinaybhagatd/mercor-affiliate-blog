# TestPipeline.ps1
# Harness to run each pipeline script individually with error trapping
# Logs results to PipelineReport.txt

$ReportFile = "PipelineReport.txt"
$Scripts = @(
    "GenerateBlogData.ps1",
    "BatchCreateBlogs.ps1",
    "QAValidator.ps1",
    "Orchestrator.ps1",
    "SelfHeal.ps1",
    "DebugAllWithQwen.ps1"
)

# Start fresh log
"=== Mercor Affiliate Blog System Test Report ===" | Out-File $ReportFile -Encoding UTF8
"Run started: $(Get-Date)" | Out-File $ReportFile -Append

foreach ($script in $Scripts) {
    $path = Join-Path (Get-Location) $script
    if (Test-Path $path) {
        try {
            Write-Host "▶ Running $script ..."
            . $path
            $msg = "✔ $script executed successfully at $(Get-Date)"
            Write-Host $msg
            $msg | Out-File $ReportFile -Append
        }
        catch {
            $err = "❌ $script failed at $(Get-Date): $($_.Exception.Message)"
            Write-Host $err
            $err | Out-File $ReportFile -Append
        }
    }
    else {
        $warn = "⚠️ $script not found in repo root at $(Get-Date)"
        Write-Host $warn
        $warn | Out-File $ReportFile -Append
    }
}

"=== Run complete ===" | Out-File $ReportFile -Append
Write-Host "📄 Test report written to $ReportFile"
 





