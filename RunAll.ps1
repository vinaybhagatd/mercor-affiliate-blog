<# 
.SYNOPSIS
Runs the full MABS pipeline in sequence:
Diagnostics → Repair → Diagnostics → SelfHeal → Orchestrator → Status Dashboards.
#>

Write-Output "▶ Starting full MABS pipeline..."

# ---------------------------------------------------------
# Step 1: Initial Diagnostics
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
# Step 4: Self-Heal (auto-diagnose → auto-repair → auto-verify → orchestrate)
# ---------------------------------------------------------

Write-Output "▶ Running SelfHeal..."
.\SelfHeal.ps1

# ---------------------------------------------------------
# Step 5: Full Orchestrator (JSON → blogs → QA → Eleventy → publish)
# ---------------------------------------------------------

Write-Output "▶ Running Orchestrator..."
.\Orchestrator.ps1

# ---------------------------------------------------------
# Step 6: Generate Web Dashboard
# ---------------------------------------------------------

Write-Output "▶ Generating web dashboard..."
.\MABSStatus-Web.ps1

# ---------------------------------------------------------
# Step 7: Terminal Status Dashboard
# ---------------------------------------------------------

Write-Output "▶ Displaying terminal dashboard..."
.\MABSStatus.ps1

Write-Output "🎉 Full MABS pipeline completed."
    