$ModelPath = "C:\Users\LMTest\.lmstudio\bin\lms.exe"
$ModelName = "qwen2.5-coder-1.5b-instruct"
$targetFolder = "C:\Users\LMTest\promotional\mercor-affiliate-blog\src\GeneratedBlogs"

# Verify LM Studio CLI exists
if (-not (Test-Path $ModelPath)) {
    Write-Host "Error: LM Studio CLI not found at $ModelPath"
    exit 1
}

for ($i = 1; $i -le 11; $i++) {
    $prompt = @"
You are an expert JSON generator.
Output ONLY valid JSON. Do not include explanations, comments, or text outside the JSON object.

Schema:
{
  "title": "string",
  "category": "string",
  "date": "YYYY-MM-DD HH:mm:ss",
  "content": "string with publish-ready blog text"
}

Blog number: $i
"@

    # Run Qwen model and pipe directly to file
    & $ModelPath chat $ModelName -p $prompt | Out-File "$targetFolder\BlogData_$i.json" -Encoding UTF8

    Write-Host "Generated BlogData_$i.json"
}
