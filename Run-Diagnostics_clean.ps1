# Invoke-Diagnostics.ps1
# Automates running the Diagnostics Agent in Continue
# Creates a daily timestamped log file

$DateStamp = Get-Date -Format "yyyy-MM-dd"
$LOGFILE = "C:\Users\LMTest\promotional\mercor-affiliate-blog\diagnostics_log_$DateStamp.txt"

Write-Output " =  =  = Running Diagnostics Agent =  =  = "
Add-Content $LOGFILE "
[Diagnostics Agent Output - $(Get-Date)]"

# Run Diagnostics Agent via Continue CLI
continue run Diagnostics | Tee-Object -FilePath $LOGFILE -Append

Write-Output " Diagnostics Complete =  =  = "
Write-Output "Logs saved to: $LOGFILE"
