# Diagnostics.ps1
param(
    [string]$ProjectDir = "C:\Users\LMTest\promotional\mercor-affiliate-blog",
    [string]$DiagnosticsFile = "diagnostics.log"
)

function Write-Log {
    param([string]$Message,[string]$Level="INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Output "[${timestamp}][${Level}] ${Message}"
}

function Run-Diagnostics {
    param([string]$OutputPath)

    try {
        Write-Log "Diagnostics started at ${OutputPath}"

        # Example checks: ensure key files exist
        $filesToCheck = @("HermesAutomation.ps1","Orchestrator.ps1","QAValidator.ps1")
        foreach ($file in $filesToCheck) {
            $path = Join-Path $ProjectDir $file
            if (Test-Path $path) {
                Write-Log "File exists: ${path}"
            } else {
                Write-Log "Missing file: ${path}" "ERROR"
            }
        }

        # Example system info
        $os = Get-CimInstance Win32_OperatingSystem
        $cpu = Get-CimInstance Win32_Processor
        $mem = Get-CimInstance Win32_PhysicalMemory | Measure-Object -Property Capacity -Sum

        $report = @()
        $report += "OS: $($os.Caption) $($os.Version)"
        $report += "CPU: $($cpu.Name)"
        $report += "Total Memory (GB): {0:N2}" -f ($mem.Sum / 1GB)

        $report | Out-File -FilePath $OutputPath -Encoding UTF8
        Write-Log "Diagnostics complete. Report saved to ${OutputPath}"
    }
    catch {
        Write-Log "Error during diagnostics: $_" "ERROR"
    }
}

# Run diagnostics
$outputPath = Join-Path $ProjectDir $DiagnosticsFile
Run-Diagnostics -OutputPath $outputPath
