<# 
.SYNOPSIS
Runs full diagnostics for the MABS system:
LM Studio, JSON validity, Markdown validity, QA, Eleventy, Git, folder structure.
#>

param(
    [string]$JsonFolder = ".\BlogData",
    [string]$BlogsFolder = ".\GeneratedBlogs",
    [string]$SiteFolder = ".\mercor-affiliate-blog\_site"
)

$errors = @()
$warnings = @()

Write-Output "▶ Running MABS Diagnostics..."

# ---------------------------------------------------------
# 1. LM Studio CLI Check
# ---------------------------------------------------------

$lmPath = "C:\Users\LMTest\.lmstudio\bin\lms.exe"

if (-not (Test-Path $lmPath)) {
    $errors += "LM Studio CLI not found at expected path."
} else {
    Write-Output "✔ LM Studio CLI detected."
}

# ---------------------------------------------------------
# 2. Model Availability Check
# ---------------------------------------------------------

$model = "qwen2.5-coder-1.5b-instruct"

try {
    $modelList = & $lmPath list-models
    if ($modelList -notmatch $model) {
        $errors += "Model missing: $model"
    } else {
        Write-Output "✔ Model available: $model"
    }
}
catch {
    $errors += "Unable to query LM Studio models."
}

# ---------------------------------------------------------
# 3. JSON Folder Check
# ---------------------------------------------------------

if (-not (Test-Path $JsonFolder)) {
    $errors += "JSON folder missing: $JsonFolder"
} else {
    Write-Output "✔ JSON folder exists."
}

# ---------------------------------------------------------
# 4. JSON Validity Check
# ---------------------------------------------------------

$jsonFiles = Get-ChildItem $JsonFolder -Filter *.json

foreach ($file in $jsonFiles) {
    try {
        $null = Get-Content $file.FullName -Raw | ConvertFrom-Json
        Write-Output "✔ Valid JSON: $($file.Name)"
    }
    catch {
        $errors += "Invalid JSON: $($file.Name)"
    }
}

# ---------------------------------------------------------
# 5. Markdown Folder Check
# ---------------------------------------------------------

if (-not (Test-Path $BlogsFolder)) {
    $warnings += "Markdown folder missing: $BlogsFolder"
} else {
    Write-Output "✔ Markdown folder exists."
}

# ---------------------------------------------------------
# 6. Markdown Validity Check
# ---------------------------------------------------------

$mdFiles = Get-ChildItem $BlogsFolder -Filter *.md -ErrorAction SilentlyContinue

foreach ($md in $mdFiles) {
    if ($md -notmatch "\.md$") {
        $warnings += "Non-Markdown file detected: $($md.Name)"
    } else {
        Write-Output "✔ Markdown file detected: $($md.Name)"
    }
}

# ---------------------------------------------------------
# 7. QAValidator Presence Check
# ---------------------------------------------------------

if (-not (Test-Path ".\QAValidator.ps1")) {
    $errors += "QAValidator.ps1 missing."
} else {
    Write-Output "✔ QAValidator.ps1 exists."
}

# ---------------------------------------------------------
# 8. Eleventy Installation Check
# ---------------------------------------------------------

try {
    $eleventy = npx @11ty/eleventy --version
    Write-Output "✔ Eleventy installed."
}
catch {
    $errors += "Eleventy not installed or not accessible."
}

# ---------------------------------------------------------
# 9. Git Remote Check
# ---------------------------------------------------------

try {
    $remote = git remote -v
    if ($remote -match "origin") {
        Write-Output "✔ Git remote 'origin' configured."
    } else {
        $warnings += "Git remote 'origin' not configured."
    }
}
catch {
    $errors += "Git not accessible."
}

# ---------------------------------------------------------
# 10. Folder Structure Check
# ---------------------------------------------------------

$requiredFolders = @(
    ".\BlogData",
    ".\GeneratedBlogs",
    ".\mercor-affiliate-blog",
    ".\mercor-affiliate-blog\_site"
)

foreach ($folder in $requiredFolders) {
    if (-not (Test-Path $folder)) {
        $warnings += "Missing folder: $folder"
    } else {
        Write-Output "✔ Folder OK: $folder"
    }
}

# ---------------------------------------------------------
# 11. Unicode + Stray Character Check
# ---------------------------------------------------------

$psFiles = Get-ChildItem . -Filter *.ps1 -Recurse

foreach ($ps in $psFiles) {
    $content = Get-Content $ps.FullName -Raw

    if ($content -match "\\u[0-9A-Fa-f]{4}") {
        $errors += "Invalid Unicode escape in: $($ps.Name)"
    }

    if ($content -match "^\|") {
        $errors += "Stray pipe character at start of: $($ps.Name)"
    }
}

# ---------------------------------------------------------
# 12. ScriptAnalyzer Compliance
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
# Final Output
# ---------------------------------------------------------

Write-Output "`n==============================="
Write-Output "        MABS DIAGNOSTICS"
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

Write-Output "`nDiagnostics complete."
