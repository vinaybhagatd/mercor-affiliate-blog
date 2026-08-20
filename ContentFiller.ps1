<#
.SYNOPSIS
ContentFiller.ps1
Fills blog skeletons for all 11 categories by replacing placeholder instructions
with generated content from Qwen Coder via LM Studio CLI.
#>

$lmStudioPath = "C:\Users\LMTest\.lmstudio\bin\lms.exe"
$blogDir      = "C:\Users\LMTest\promotional\mercor-affiliate-blog\_site"

# Approved categories
$categories = @(
    "creative","data","engineering","finance","language",
    "law","medicine","misc","operations","sciences","tech"
)

# Section placeholders → prompts
$sections = @{
    "Storytelling introduction of a remote" = "Write a 200-word Persona & Context story about a remote {category} professional, their challenges, and aspirations."
    "A structured description of a typical day" = "Generate a 150-word 'Day in the Life' narrative for a remote {category} professional, focusing on workflows, meetings, and productivity strategies."
    "Top {category} Productivity Tool" = "List and describe 3 top productivity tools used by remote {category} professionals, with practical examples."
    "Skill 1" = "Provide a list of 3 essential skills for remote {category} professionals, with one-sentence explanations each."
    "Entry Level: –" = "Give realistic salary ranges for remote {category} professionals at entry, mid, and senior levels."
    "Storytelling arc showing career trajectory" = "Write a 150-word growth path narrative showing how a remote {category} professional advances in their career, including challenges and takeaways."
}

function Generate-Content {
    param(
        [string]$Prompt,
        [string]$Model = "qwen-coder"
    )
    $result = & $lmStudioPath chat --model $Model --prompt $Prompt
    return $result
}

foreach ($cat in $categories) {
    $file = Join-Path $blogDir "$($cat.Substring(0,1).ToUpper() + $cat.Substring(1)).html"

    if (Test-Path $file) {
        Write-Host "🔄 Processing $file"

        $html = Get-Content $file -Raw

        foreach ($kvp in $sections.GetEnumerator()) {
            $placeholder = $kvp.Key
            $promptTemplate = $kvp.Value
            $prompt = $promptTemplate -replace '\{category\}', $cat

            if ($html -match $placeholder) {
                Write-Host "   → Generating content for: $placeholder"
                $generated = Generate-Content -Prompt $prompt
                $html = $html -replace [Regex]::Escape($placeholder), $generated
            }
        }

        Set-Content -Path $file -Value $html -Encoding UTF8
        Write-Host "✅ Finished filling $file"
    } else {
        Write-Warning "File not found: $file"
    }
}

Write-Host "🎉 All categories processed. Blog skeletons now contain generated content."
