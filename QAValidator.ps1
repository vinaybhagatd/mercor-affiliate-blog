<# 
.SYNOPSIS
Validates generated Markdown blogs for MABS.
Checks formatting, metadata, ScriptAnalyzer compliance, and LM Studio model availability.
#>

param(
    [string]$InputDir = ".\GeneratedBlogs",
    [string]$ReportFile = ".\QAReport.txt"
)

Write-Output "▶ Starting QA Validation..."

$errors = @()
$warnings = @()

# ---------------------------------------------------------
# 1. Ensure LM Studio model available
# ---------------------------------------------------------

$lmPath = "C:\Users\LMTest\.lmstudio\bin\lms.exe"
$model = "qwen2.5-coder-1.5b-instruct"

try {
    $modelList = & $lmPath ls
    if ($modelList -notmatch $model) {
        $errors += "Model missing: $model"
    } else {
        Write-Output "✔ Model available: $model"
    }
}
catch {
    $errors += "LM Studio not accessible."
}

# ---------------------------------------------------------
# 2. Validate Markdown folder
# ---------------------------------------------------------

if (-not (Test-Path $InputDir)) {
    $errors += "Markdown folder missing: $InputDir"
} else {
    Write-Output "✔ Markdown folder exists."
}

$mdFiles = Get-ChildItem $InputDir -Filter *.md -ErrorAction SilentlyContinue

if ($mdFiles.Count -eq 0) {
    $warnings += "No Markdown files found in $InputDir"
}

# ---------------------------------------------------------
# 3. Validate Markdown metadata
# ---------------------------------------------------------

foreach ($file in $mdFiles) {
    $content = Get-Content $file.FullName -Raw

    if ($content -notmatch "^---") {
        $errors += "Missing metadata block in: $($file.Name)"
    }

    if ($content -notmatch "title:") {
        $errors += "Missing title in metadata: $($file.Name)"
    }

    if ($content -notmatch "category:") {
        $warnings += "Missing category in metadata: $($file.Name)"
    }

    if ($content -notmatch "date:") {
        $warnings += "Missing date in metadata: $($file.Name)"
    }
}

# ---------------------------------------------------------
# 4. ScriptAnalyzer compliance
# ---------------------------------------------------------

try {
    $analysis = Invoke-ScriptAnalyzer -Path . -Recurse -Settings ".\PSScriptAnalyzerSettings.psd1"
    foreach ($issue in $analysis) {
        if ($issue.Severity -eq "Error") {
            $errors += "ScriptAnalyzer Error: $($issue.RuleName) in $($issue.ScriptName)"
        } else {
            $warnings += "ScriptAnalyzer Warning: $($issue.RuleName) in $($issue.ScriptName)"
        }
    }
    Write-Output "✔ ScriptAnalyzer executed."
}
catch {
    $warnings += "ScriptAnalyzer not available."
}

# ---------------------------------------------------------
# 5. Write QA Report
# ---------------------------------------------------------

"===============================" | Out-File $ReportFile -Encoding UTF8
"        MABS QA REPORT" | Out-File $ReportFile -Append -Encoding UTF8
"===============================" | Out-File $ReportFile -Append -Encoding UTF8

if ($errors.Count -eq 0) {
    "✅ No blocking errors detected." | Out-File $ReportFile -Append -Encoding UTF8
} else {
    "❌ Blocking Errors:" | Out-File $ReportFile -Append -Encoding UTF8
    $errors | ForEach-Object { " - $_" | Out-File $ReportFile -Append -Encoding UTF8 }
}

if ($warnings.Count -gt 0) {
    "`n⚠️ Warnings:" | Out-File $ReportFile -Append -Encoding UTF8
    $warnings | ForEach-Object { " - $_" | Out-File $ReportFile -Append -Encoding UTF8 }
}

Write-Output "✔ QA report written to $ReportFile"

# ---------------------------------------------------------
# Final Output
# ---------------------------------------------------------

Write-Output "`n==============================="
Write-Output "        MABS QA VALIDATION"
Write-Output "==============================="

if ($errors.Count -eq 0) {
    Write-Output "✅ No blocking errors detected."
} else {
    Write-Output "❌ Blocking Errors:"
    $errors | ForEach-Object { Write-Output " - $_" }
}

if ($warnings.Count -gt 0) {
    Write-Output "`n⚠️ Warnings:"
    $warnings | ForEach-Object { Write-Output " - $_" }
}

Write-Output "`nQA validation complete."
