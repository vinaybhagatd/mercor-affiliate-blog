# Configure-OpenClaw.ps1
# Purpose: Automate OpenClaw setup in Mercor Affiliate Blog System

$projectRoot = "C:\Users\LMTest\promotional\mercor-affiliate-blog"
$configFile = Join-Path $projectRoot "openclaw.yaml"
$agentsDir = Join-Path $projectRoot "agents"

# 1. Ensure agents directory exists
if (-not (Test-Path $agentsDir)) {
    New-Item -ItemType Directory -Path $agentsDir -Force | Out-Null
    Write-Host "✔ Created agents directory at $agentsDir"
}
else {
    Write-Host "✔ Agents directory already exists at $agentsDir"
}

# 2. Create openclaw.yaml with base configuration
$yamlContent = @""
workspace: C:\Users\LMTest\promotional\mercor-affiliate-blog
agents_dir: agents
scripts_dir: scripts

workflows:
blog_pipeline:
steps:
- FixFrontMatterAgent
- VerifyFrontMatterAgent
- StabilizeAgent
"@"

Set-Content -Path $configFile -Value $yamlContent -Encoding UTF8
Write-Host "✔ Created OpenClaw config file at $configFile"

# 3. Create agent config files in agents/
$fixAgent = @""
name: FixFrontMatterAgent
type: script
description: Normalize front matter in all Markdown posts under src\posts
command: pwsh ./FixFrontMatter.ps1
working_directory: $projectRoot
halt_on_error: true
log_output: true
"@"

$verifyAgent = @""
name: VerifyFrontMatterAgent
type: script
description: Validate that each post has category and tags, and tags include category
command: pwsh ./VerifyFrontMatter.ps1
working_directory: $projectRoot
halt_on_error: true
log_output: true
"@"

$stabilizeAgent = @""
name: StabilizeAgent
type: script
description: Run full stabilization pipeline (fix, verify, sanity check, lint, format, hygiene)
command: pwsh ./Stabilize-MABS.ps1
working_directory: $projectRoot
halt_on_error: true
log_output: true
"@"

Set-Content -Path (Join-Path $agentsDir "FixFrontMatterAgent.yaml") -Value $fixAgent -Encoding UTF8
Set-Content -Path (Join-Path $agentsDir "VerifyFrontMatterAgent.yaml") -Value $verifyAgent -Encoding UTF8
Set-Content -Path (Join-Path $agentsDir "StabilizeAgent.yaml") -Value $stabilizeAgent -Encoding UTF8

Write-Host "✔ Agent configs created in $agentsDir"
Write-Host "=== OpenClaw configuration complete ==="
}

}

}

}

}

}

}

}




}