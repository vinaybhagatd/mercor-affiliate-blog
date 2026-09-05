<# 
<# <# <# <# <# .SYNOPSIS #> #> #> #> #>
    Verify that .gitignore rules are correctly ignoring noisy files.
.DESCRIPTION
    Auto-creates dummy files/folders for known artifacts, runs git check-ignore,
    reports results, then cleans up afterwards.
#>

# Auto-create dummy files/folders for verification
New-Item -ItemType File -Force _site/test.html | Out-Null
New-Item -ItemType File -Force node_modules/test.js | Out-Null
New-Item -ItemType File -Force diagnostics.log | Out-Null
New-Item -ItemType File -Force QAReport.txt | Out-Null
New-Item -ItemType File -Force PreCommitReport.txt | Out-Null
New-Item -ItemType File -Force WarningsReport.txt | Out-Null
New-Item -ItemType File -Force ScriptAnalyzerReport_123.txt | Out-Null
New-Item -ItemType File -Force FormatterReport_123.txt | Out-Null
New-Item -ItemType File -Force BulkFixReport.txt | Out-Null
New-Item -ItemType File -Force UnicodeMasterReport.log | Out-Null
New-Item -ItemType File -Force deploy.yml | Out-Null
New-Item -ItemType File -Force build.log | Out-Null
New-Item -ItemType File -Force createblog.log | Out-Null
New-Item -ItemType Directory -Force pipeline-logs | Out-Null
New-Item -ItemType Directory -Force hermes-logs | Out-Null
New-Item -ItemType File -Force hermes-logs/test.log | Out-Null
New-Item -ItemType File -Force .DS_Store | Out-Null
New-Item -ItemType File -Force Thumbs.db | Out-Null

# List of files and folders to verify
$pathsToCheck = @(
    "_site/test.html",
    "node_modules/test.js",
    "diagnostics.log",
    "QAReport.txt",
    "PreCommitReport.txt",
    "WarningsReport.txt",
    "ScriptAnalyzerReport_123.txt",
    "FormatterReport_123.txt",
    "BulkFixReport.txt",
    "UnicodeMasterReport.log",
    "deploy.yml",
    "build.log",
    "createblog.log",
    "pipeline-logs/",
    "hermes-logs/test.log",
    ".DS_Store",
    "Thumbs.db"
)

Write-Host "🔎 Verifying .gitignore rules..." -ForegroundColor Cyan

foreach ($path in $pathsToCheck) {
    $result = git check-ignore -v $path 2>$null
    if ($result) {
        Write-Host "✅ Ignored: $path ($result)" -ForegroundColor Green
    } else {
        Write-Host "⚠️ Not ignored: $path" -ForegroundColor Yellow
    }
}

Write-Host "`nVerification complete." -ForegroundColor Cyan

# Cleanup dummy files/folders after verification
Remove-Item -Force BulkFixReport.txt, QAReport.txt, PreCommitReport.txt, WarningsReport.txt, ScriptAnalyzerReport_123.txt, FormatterReport_123.txt, UnicodeMasterReport.log, deploy.yml, build.log, createblog.log, diagnostics.log, .DS_Store, Thumbs.db -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force _site, node_modules, pipeline-logs, hermes-logs -ErrorAction SilentlyContinue






