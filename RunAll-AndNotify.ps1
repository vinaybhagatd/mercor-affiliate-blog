<# 
.SYNOPSIS
Runs the full MABS pipeline and sends a Windows toast notification when complete.
#>

# Toast notification function
function Send-Toast {
    param([string]$Message)

    $template = @"
<toast>
    <visual>
        <binding template="ToastGeneric">
            <text>MABS Pipeline</text>
            <text>$Message</text>
        </binding>
    </visual>
</toast>
"@

    $xml = New-Object Windows.Data.Xml.Dom.XmlDocument
    $xml.LoadXml($template)

    $toast = [Windows.UI.Notifications.ToastNotification]::new($xml)
    $notifier = [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier("MABS")
    $notifier.Show($toast)
}

Write-Output "▶ Starting full MABS pipeline..."

# ---------------------------------------------------------
# Step 1: Diagnostics
# ---------------------------------------------------------

Write-Output "▶ Running diagnostics..."
.\diagnostics.ps1

# ---------------------------------------------------------
# Step 2: Repair
# ---------------------------------------------------------

Write-Output "▶ Running repair..."
.\Repair.ps1

# ---------------------------------------------------------
# Step 3: Post-Repair Diagnostics
# ---------------------------------------------------------

Write-Output "▶ Running post-repair diagnostics..."
.\diagnostics.ps1

# ---------------------------------------------------------
# Step 4: Self-Heal
# ---------------------------------------------------------

Write-Output "▶ Running SelfHeal..."
.\SelfHeal.ps1

# ---------------------------------------------------------
# Step 5: Orchestrator
# ---------------------------------------------------------

Write-Output "▶ Running Orchestrator..."
.\Orchestrator.ps1

# ---------------------------------------------------------
# Step 6: Web Dashboard
# ---------------------------------------------------------

Write-Output "▶ Generating web dashboard..."
.\MABSStatus-Web.ps1

# ---------------------------------------------------------
# Step 7: Terminal Dashboard
# ---------------------------------------------------------

Write-Output "▶ Displaying terminal dashboard..."
.\MABSStatus.ps1

# ---------------------------------------------------------
# Step 8: Toast Notification
# ---------------------------------------------------------

Send-Toast -Message "MABS pipeline completed successfully."

Write-Output "🎉 Full MABS pipeline completed with notification."
