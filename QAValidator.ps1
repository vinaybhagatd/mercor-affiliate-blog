# QAValidator.ps1
param(
    [string]$ProjectDir = "C:\Users\LMTest\promotional\mercor-affiliate-blog",
    [string]$QAInputFile = "qa_input.txt",
    [string]$QAOutputFile = "qa_results.txt"
)

function Write-Log {
    param([string]$Message,[string]$Level="INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Output "[${timestamp}][${Level}] ${Message}"
}

function Validate-QA {
    param([string]$InputPath,[string]$OutputPath)

    try {
        if (-not (Test-Path $InputPath)) {
            Write-Log "QA input file not found: ${InputPath}" "ERROR"
            return
        }

        $lines = Get-Content -Path $InputPath
        $results = @()

        foreach ($line in $lines) {
            if ([string]::IsNullOrWhiteSpace($line)) {
                $results += "Line skipped (empty)"
            }
            elseif ($line.Length -lt 5) {
                $results += "Line too short: ${line}"
            }
            else {
                $results += "Line valid: ${line}"
            }
        }

        $results | Out-File -FilePath $OutputPath -Encoding UTF8
        Write-Log "QA validation complete. Results saved to ${OutputPath}"
    }
    catch {
        Write-Log "Error during QA validation: $_" "ERROR"
    }
}

# Run validation
$inputPath = Join-Path $ProjectDir $QAInputFile
$outputPath = Join-Path $ProjectDir $QAOutputFile
Validate-QA -InputPath $inputPath -OutputPath $outputPath
