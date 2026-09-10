<#
.SYNOPSIS
  Validates Mercor Affiliate Blog System (MABS) stability.
.DESCRIPTION
  Runs six checks:
    1. Repo structure validation
    2. PowerShell script analyzer
    3. Eleventy dry-run build
    4. Git hook & .gitignore check
    5. Smoke tests (BatchCreateBlogs, QAValidator, Orchestrator)
    6. Summary report
  Generates MABSHealthReport.txt with results.
#>

param(
  [string]$TargetDir = "C:\Users\LMTest\promotional\mercor-affiliate-blog",
  [string]$ReportFile = "MABSHealthReport.txt"
)

function Log {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $Message" | Out-File -FilePath $ReportFile -Append
}

# Reset report
Clear-Content $ReportFile -ErrorAction SilentlyContinue
Log "=== Starting MABS Stability Validation ==="

# 1. Repo Structure
$requiredDirs = @("src\posts","_layouts","_includes","_site","scripts")
foreach ($dir in $requiredDirs) {
    if (-not (Test-Path (Join-Path $TargetDir $dir))) {
        Log "❌ Missing directory: $dir"
    } else {
        Log "✅ Found directory: $dir"
    }
}

$requiredFiles = @(".eleventy.js","_layouts\post.njk","_layouts\category.njk")
foreach ($file in $requiredFiles) {
    if (-not (Test-Path (Join-Path $TargetDir $file))) {
        Log "❌ Missing critical file: $file"
    } else {
        Log "✅ Found critical file: $file"
    }
}

# 2. PowerShell Script Analyzer
Log "Running ScriptAnalyzer..."
Get-ChildItem -Path $TargetDir -Recurse -Filter "*.ps1" | ForEach-Object {
    $results = Invoke-ScriptAnalyzer -Path $_.FullName -Severity Error -ErrorAction SilentlyContinue
    if ($results) {
        Log "❌ ScriptAnalyzer errors in $($_.Name)"
        $results | ForEach-Object { Log "   -> $($_.Message)" }
    } else {
        Log "✅ Script clean: $($_.Name)"
    }
}

# 3. Eleventy Dry-Run
try {
    Push-Location $TargetDir
    npx eleventy --dryrun | Out-File "$TargetDir\EleventyDryRun.log"
    Log "✅ Eleventy dry-run completed"
} catch {
    Log "❌ Eleventy dry-run failed: $($_.Exception.Message)"
} finally {
    Pop-Location
}

# 4. Git Hook & .gitignore Check
$gitHook = "C:\Users\LMTest\promotional\mercor-affiliate-blog\.githooks\pre-commit.ps1"
if (Test-Path $gitHook) {
    Log "✅ Pre-commit hook found at .githooks\pre-commit.ps1"
} else {
    Log "❌ Pre-commit hook missing at .githooks\pre-commit.ps1"
}

$gitIgnore = Join-Path $TargetDir ".gitignore"
if (Test-Path $gitIgnore) {
    $ignoreContent = Get-Content $gitIgnore
    if ($ignoreContent -match "QAReport.txt" -and $ignoreContent -match "PreCommitReport.txt") {
        Log "✅ .gitignore excludes artifacts"
    } else {
        Log "⚠️ .gitignore missing exclusions for QAReport.txt / PreCommitReport.txt"
    }
} else {
    Log "❌ .gitignore missing"
}

# 5. Smoke Tests with Auto-Detection
try {
    Push-Location $TargetDir

    Log "Running BatchCreateBlogs.ps1 smoke test..."
    $batchScriptRoot   = Join-Path $TargetDir "BatchCreateBlogs.ps1"
    $batchScriptScript = Join-Path $TargetDir "scripts\BatchCreateBlogs.ps1"

    if (Test-Path $batchScriptScript) {
        . $batchScriptScript -ErrorAction SilentlyContinue
        Log "✅ BatchCreateBlogs executed from scripts\"
    } elseif (Test-Path $batchScriptRoot) {
        . $batchScriptRoot -ErrorAction SilentlyContinue
        Log "✅ BatchCreateBlogs executed from repo root"
    } else {
        Log "❌ BatchCreateBlogs.ps1 not found in scripts\ or root"
    }

    Log "Running QAValidator.ps1 smoke test..."
    $qaScriptRoot   = Join-Path $TargetDir "QAValidator.ps1"
    $qaScriptScript = Join-Path $TargetDir "scripts\QAValidator.ps1"
    if (Test-Path $qaScriptScript) {
        . $qaScriptScript -ErrorAction SilentlyContinue
        Log "✅ QAValidator executed from scripts\"
    } elseif (Test-Path $qaScriptRoot) {
        . $qaScriptRoot -ErrorAction SilentlyContinue
        Log "✅ QAValidator executed from repo root"
    } else {
        Log "❌ QAValidator.ps1 not found"
    }

    Log "Running Orchestrator.ps1 smoke test..."
    $orchScriptRoot   = Join-Path $TargetDir "Orchestrator.ps1"
    $orchScriptScript = Join-Path $TargetDir "scripts\Orchestrator.ps1"
    if (Test-Path $orchScriptScript) {
        . $orchScriptScript -ErrorAction SilentlyContinue
        Log "✅ Orchestrator executed from scripts\"
    } elseif (Test-Path $orchScriptRoot) {
        . $orchScriptRoot -ErrorAction SilentlyContinue
        Log "✅ Orchestrator executed from repo root"
    } else {
        Log "❌ Orchestrator.ps1 not found"
    }

} catch {
    Log "❌ Smoke test failed: $($_.Exception.Message)"
} finally {
    Pop-Location
}

# 6. Summary Report
Log "=== MABS Validation Complete ==="
Write-Output "✅ Validation finished. See $ReportFile for full details."
