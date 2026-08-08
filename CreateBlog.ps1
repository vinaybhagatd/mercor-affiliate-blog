param(
    [string]$OutputDirectory = "C:\Users\LMTest\promotional\mercor-affiliate-blog\src\posts",
    [string]$LogFile = "C:\Users\LMTest\promotional\mercor-affiliate-blog\createblog.log"
)

function Log($text) {
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $text" | Out-File -FilePath $LogFile -Append
}

# Define the 11 Mercor job categories
$categories = @(
    "Medicine",
    "Law",
    "Engineering",
    "Data",
    "Finance",
    "Operations",
    "Sciences",
    "Creative",
    "Language",
    "Tech",
    "Misc"
)

try {
    Log "Starting CreateBlog Agent..."
    Write-Output "Starting CreateBlog Agent..."

    # Ensure output directory exists
    if (-not (Test-Path $OutputDirectory)) {
        New-Item -ItemType Directory -Path $OutputDirectory -Force | Out-Null
        Log "Created output directory: $OutputDirectory"
    }

    foreach ($category in $categories) {
        $safeCategory = $category -replace '\s','-'
        $filePath = Join-Path $OutputDirectory "$safeCategory.md"

        # Special case: Medical category gets full sample content
        if ($category -eq "Medicine") {
            $content = @"
---
title: "Remote Medical Support Roles: Why They Matter More Than Ever"
date: $(Get-Date -Format "yyyy-MM-dd")
category: $category
description: "Exploring the importance of remote medical support roles."
tags: []
style: "Blended conversational Marketing Style of Molly Keyser + Sam Browne — story driven, punchy, emotional, no emojis"
---

If you’ve ever felt the pull toward meaningful work — the kind that actually helps people breathe easier — remote medical support roles are exactly that. You don’t need a hospital hallway or a white coat to make an impact. You just need your brain, your empathy, and a laptop.

And honestly? The world needs you more than ever.

A Day in the Life (The Real Version)
You start your morning reviewing patient notes. Not the scary kind — the human kind. Someone’s confused about their medication. Someone else needs help scheduling a follow up. You’re the calm voice in the chaos.

Midday, you’re coordinating with doctors, updating digital records, and helping patients navigate telehealth platforms. It’s structured, but never boring. Every message you send makes someone’s day a little easier.

Tools You’ll Use
• Telemedicine platforms (Practo, Doxy.me)
• EMR/EHR systems
• Secure messaging tools
• Google Workspace
• Scheduling dashboards

Skills You Need
• Clear communication
• Medical terminology basics
• Patient empathy
• Attention to detail
• Ability to stay calm under pressure

Salary Range
\$800 – \$1,500 per month depending on specialization and experience.

Growth Path
You can start in patient coordination and grow into telehealth operations, medical QA, EMR administration, or even remote clinical support roles. The ladder is real, and every step opens a new door.

Ready to Step Into a Medical Role That Actually Matters?
Mercor connects you with global startups hiring remote medical support talent right now. Explore remote medical roles
"@
        }
        else {
            # Placeholder content for other categories
            $content = @"
---
title: "Remote $category Roles: Opportunities and Growth"
date: $(Get-Date -Format "yyyy-MM-dd")
category: $category
description: "Exploring remote $category opportunities in the Mercor Affiliate system."
tags: []
style: "Blended conversational Marketing Style of Molly Keyser + Sam Browne — story driven, punchy, emotional, no emojis"
---

This is a placeholder blog for the $category category. Expand with story-driven, punchy, emotional content in the Molly Keyser + Sam Browne blended marketing style (no emojis).
"@
        }

        $content | Out-File -FilePath $filePath -Encoding utf8
        Log "Created blog post for category: $category at $filePath"
        Write-Output "Blog post created: $filePath"
    }

    Log "All 11 blog posts generated successfully."
    Write-Output "All 11 blog posts generated successfully."
}
catch {
    Log "Error: $($_.Exception.Message)"
    Write-Output "Error creating blog posts: $($_.Exception.Message)"
}
