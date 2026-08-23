# TestLMStudio.ps1
# Smoke test for LM Studio CLI after reinstall

$lmStudioPath = "C:\Users\LMTest\.lmstudio\bin\lms.exe"

Write-Host "🔍 Checking LM Studio CLI version..."
& $lmStudioPath --version

Write-Host "`n📦 Listing available models..."
& $lmStudioPath ls

Write-Host "`n🧩 Checking loaded models..."
$modelLine = & $lmStudioPath ps | Select-String "LOADED"
if ($modelLine) {
    $model = ($modelLine -split '\s+')[0]
    Write-Host "✅ Detected loaded model: $model"
} else {
    Write-Host "⚠️ No model loaded. Loading default md-coder-qwen3-8b..."
    & $lmStudioPath load md-coder-qwen3-8b | Out-Null
    $modelLine = & $lmStudioPath ps | Select-String "LOADED"
    $model = ($modelLine -split '\s+')[0]
    Write-Host "✅ Loaded model: $model"
}

Write-Host "`n💬 Running sample chat prompt..."
try {
    $output = & $lmStudioPath chat $model -p "Write a 20-word summary of why automation helps affiliate blogging." 2>$null
    $cleanOutput = $output -replace '\x1B

\[[0-9;]*[A-Za-z]', ''
    if ($cleanOutput.Trim()) {
        Write-Host "✅ Model responded successfully:"
        Write-Host $cleanOutput
    } else {
        Write-Error "❌ Model output was empty. Check GUI/CLI version alignment."
    }
} catch {
    Write-Error "❌ Chat command failed: $_"
}
