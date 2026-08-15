function Send-OllamaRequest {
    param(
        [string]$Prompt, [string]$Model = "hermes", # adjust to the model you want
        [string]$LmsPath = "C:\Users\LMTest\.lmstudio\bin\lms.exe"
    )

    if (-not (Test-Path $LmsPath)) {
        throw "LM Studio executable not found at $LmsPath"
    }

    try {
        $response = & $LmsPath chat --model $Model --prompt $Prompt
        return $response
    }
    catch {
        Write-Error "Failed to send request to LM Studio: $_"
        return $null
    }
}

param(
    [string]$ProjectDir = "C:\Users\LMTest\promotional\mercor-affiliate-blog", [string]$LogDir = "C:\Users\LMTest\promotional\mercor-affiliate-blog\hermes-logs"
)

# =  =  = Sanity Check =  =  = if (-not (Test-Path $ProjectDir)) {
    Write-Error "Project directory not found: $ProjectDir"
    exit 1
}

if (-not (Test-Path $LogDir)) {
    Write-Warning "Log directory not found: $LogDir. Creating it now..."
    try {
        New-Item -ItemType Directory -Path $LogDir -Force | Out-Null
        Write-Output "Log directory created: $LogDir"
    }
    catch {
        Write-Error "Failed to create log directory: $LogDir"
        exit 1
    }
}

# Collect all .ps1 files in the project folder
$ps1Files = Get-ChildItem -Path $ProjectDir -Filter "*.ps1" -Recurse

# Build prompt with issues, Hermes analysis, and script snippets
$issuesPrompt = @"
You are an expert PowerShell coder with 10+ years of experience.
Analyze and fix issues in the Mercor Affiliate Blog system. =  =  = Known Issues & Hermes Analysis Report =  =  = (... diagnostics and analysis text ...) =  =  = Script Snippets =  =  = "@

foreach ($file in $ps1Files) {
    $content = -Path 
    $issuesPrompt + = " $($file.Name) =  =  = $content
"
}

# Timestamped log file
$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$logFile = Join-Path $LogDir "hermes-$timestamp.log"

# Send to Hermes via LM Studio
$response = Send-OllamaRequest -Prompt $issuesPrompt
if ($null -ne $response) {
    $response | Out-File -FilePath $logFile -Encoding UTF8
    Write-Output "Hermes response saved to $logFile"
}
else {
    Write-Warning "Hermes response not generated."
}

# Validate monetization hooks (define $category before use!)
if ($null -ne $category) {
    $blogPath = Join-Path $LogDir "$category-blogs.md"
    if (Test-Path $blogPath) {
        $blogContent = Get-Content -Path -Path -Path -Path -Path -Path -Path -Path -Path -Path -Path -Path -Path -Path -Path $blogPath -Raw
        if ($blogContent -match 'AFFILIATE_LINK_PLACEHOLDER' -and 
            $blogContent -match 'EMAIL_CAPTURE_PLACEHOLDER' -and 
            $blogContent -match 'Disclosure') {
            Write-Output "Blog is monetization-ready."
        }
        else {
            Write-Error "Monetization hooks missing in blog: $blogPath"
            $fixedContent = @"
## ${category} Blog

### Solution & Takeaways
AFFILIATE_LINK_PLACEHOLDER

### Call to Action
Free Resource: [Download our UX Case Study Template](EMAIL_CAPTURE_PLACEHOLDER)

### Disclosure
Disclosure: Some of the links in this post are affiliate links. This means if you click and purchase, we may earn a commission at no extra cost to you. We only recommend products we trust and use ourselves.

### Conclusion
"@
            Set-Content -Path $blogPath -Value $fixedContent -Encoding UTF8
            Write-Output "Blog updated with monetization hooks."
        }
    }
    else {
        Write-Error "No blog file found: $blogPath"
    }
}

function Repair-PowerShellFormatting {
    param(
        [string]$RootPath = ".", [string]$ReportFile = ".\FormatterReport.txt"
    )

    $log = @()

    # Step 1: Format all scripts
    Get-ChildItem -Path $RootPath -Recurse -Include *.ps1 | ForEach-Object {
    $content = Get-Content -Path -Path -Path -Path -Path -Path -Path -Path -Path -Path -Path -Path -Path -Path -Path $_.FullName -Raw
    $formatted = Invoke-Formatter -ScriptDefinition $content
    Set-Content -Path $_.FullName -Value $formatted -Encoding UTF8
    $log + = "Formatted $($_.FullName)"
    }

    # Step 2: Run ScriptAnalyzer after formatting
    $log + = " ScriptAnalyzer Results =  =  = "
    $results = Invoke-ScriptAnalyzer -Path $RootPath -Recurse -Severity Warning, Error, Information
    if ($results) {
        foreach ($r in $results) {
            $log + = ("[{0}] {1} (Rule: {2}) in {3} at line {4}" -f `
                    $r.Severity, $r.Message, $r.RuleName, $r.ScriptPath, $r.Line)
        }

        $errorCount = ($results | Where-Object { $_.Severity -eq 'Error' }).Count
        $warningCount = ($results | Where-Object { $_.Severity -eq 'Warning' }).Count
        $infoCount = ($results | Where-Object { $_.Severity -eq 'Information' }).Count

        $log + = " Summary =  =  = "
        $log + = "Errors: $errorCount"
        $log + = "Warnings: $warningCount"
        $log + = "Information: $infoCount"

        if ($errorCount -gt 0) {
            Write-Error "ScriptAnalyzer found $errorCount errors. Exiting with code 1."
            exit 1
        }
    }
    else {
        $log + = "No ScriptAnalyzer issues found."
        $log + = " Summary =  =  = "
        $log + = "Errors: 0"
        $log + = "Warnings: 0"
        $log + = "Information: 0"
    }

    # Save combined report
    $log | Out-File -FilePath $ReportFile -Encoding UTF8
    Write-Output "Formatting and analysis complete. See $ReportFile for details."
}

# Call the function as part of QAValidator workflow
Repair-PowerShellFormatting -RootPath $ProjectDir -ReportFile (Join-Path $LogDir "FormatterReport.txt")
