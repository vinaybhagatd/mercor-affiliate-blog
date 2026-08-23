<# 
.SYNOPSIS
Schedules and runs the full MABS pipeline daily at 7:00 AM IST.
#>

param(
    [string]$TaskName = "MABS-Daily-Automation",
    [string]$ScriptToRun = ".\RunAll-AndNotify.ps1"
)

Write-Output "▶ Configuring daily MABS automation..."

# Resolve full path
$fullPath = (Resolve-Path $ScriptToRun).Path

# Create scheduled task action
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-File `"$fullPath`""

# Daily trigger at 7 AM IST
$trigger = New-ScheduledTaskTrigger -Daily -At 07:00

# Register task
Register-ScheduledTask -TaskName $TaskName -Action $action -Trigger $trigger -Description "Runs full MABS pipeline daily at 7 AM" -Force

Write-Output "✔ Daily MABS automation scheduled."
Write-Output "▶ Task Name: $TaskName"
Write-Output "▶ Runs: 7:00 AM IST every day"
Write-Output "🎉 MABS Daily Automation Ready."
  