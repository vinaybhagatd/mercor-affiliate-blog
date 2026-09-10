# RunScheduler.ps1
$root = "C:\Users\LMTest\promotional\mercor-affiliate-blog"

# Daily at 7 AM
schtasks /Create /SC DAILY /TN "MABS-Daily" /TR "powershell.exe -File $root\RunDaily.ps1" /ST 07:00

# Hourly
schtasks /Create /SC HOURLY /TN "MABS-Hourly" /TR "powershell.exe -File $root\RunHourly.ps1"

# Optional: every 15 minutes
# schtasks /Create /SC MINUTE /MO 15 /TN "MABS-15Min" /TR "powershell.exe -File $root\RunEvery15Minutes.ps1"
