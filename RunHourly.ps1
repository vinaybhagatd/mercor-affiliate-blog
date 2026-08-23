<# 
.SYNOPSIS
Schedules and runs the full MABS pipeline every hour.
#>

param(
    [string]$TaskName = "MABS-Hourly-Automation",
    [string]$ScriptToRun = ".\RunAll-AndNotify.ps1"
)

Write-Output "▶ Configuring hourly MABS automation..."

# Resolve full path
$fullPath = (Resolve-Path $ScriptToRun).Path

# Scheduled task action
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-File `"$fullPath`""

# Hourly trigger
$trigger = New-ScheduledTaskTrigger -Once -At (Get-Date).AddMinutes(1)
$trigger.RepetitionInterval = (New-TimeSpan -Hours 1)
$trigger.RepetitionDuration = (New-TimeSpan -Days 3650)

# Register task
Register-ScheduledTask -TaskName $TaskName -Action $action -Trigger $trigger -Description "Runs full MABS pipeline every hour" -Force

Write-Output "✔ Hourly MABS automation scheduled."
Write-Output "▶ Task Name: $TaskName"
Write-Output "▶ Runs: Every hour"
Write-Output "🎉 MABS Hourly Automation Ready."
  