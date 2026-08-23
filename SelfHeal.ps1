<# 
.SYNOPSIS
Runs full self-healing cycle for MABS:
Diagnostics → Repair → Diagnostics → Orchestrator (only if clean).
#>

param(
    [string]$JsonFolder = ".\BlogData",
    [string]$BlogsFolder = ".\GeneratedBlogs",
    [string]$SiteFolder = ".\mercor-affiliate-blog\_site"
)

Write-Output "▶ Starting MABS Self-Heal Cycle..."

# ---------------------------------------------------------
# Step 1: Initial Diagnostics
# ---------------------------------------------------------

Write-Output "▶ Running initial diagnostics..."
.\diagnostics.ps1

$diag1 = Get-Content ".\diagnostics.log" -ErrorAction SilentlyContinue

if ($diag1 -match "❌ Blocking Errors") {
    Write-Output "⚠️ Blocking errors detected. Proceeding to repair..."
} else {
    Write-Output "✔ No blocking errors detected. Proceeding to verification..."
}

# ---------------------------------------------------------
# Step 2: Repair
# ---------------------------------------------------------

Write-Output "▶ Running repair suite..."
.\Repair.ps1

# ---------------------------------------------------------
# Step 3: Post-Repair Diagnostics
# ---------------------------------------------------------

Write-Output "▶ Running post-repair diagnostics..."
.\diagnostics.ps1

$diag2 = Get-Content ".\diagnostics.log" -ErrorAction SilentlyContinue

if ($diag2 -match "❌ Blocking Errors") {
    Write-Output "❌ System still has blocking errors after repair."
    Write-Output "▶ Manual intervention required."
    exit 1
}

Write-Output "✔ System healthy after repair."
Write-Output "▶ Proceeding to full MABS Orchestrator..."

# ---------------------------------------------------------
# Step 4: Run Orchestrator (Full Pipeline)
# ---------------------------------------------------------

.\Orchestrator.ps1

Write-Output "🎉 MABS Self-Heal + Publish complete."
