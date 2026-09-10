# Define Log() function to log to console and report file
function Log {
    param([string]$message)
    Write-Host "[GenerateBlogData] $message"
}
# Example usage of Log() function
Log ("This is a test message")
# Example data generation logic
function GenerateBlogData {
    param([string]$title, [string]$content)
    Log ("Generating blog data for: $title")
    $blog = @{
        Title   = $title
        Content = $content
        Date    = (Get-Date).ToString("yyyy-MM-dd")
    }
    # Save as JSON
    $jsonPath = Join-Path $PSScriptRoot "src\posts\BlogData.json"
    $blog | ConvertTo-Json | Set-Content -Path $jsonPath -Force
    Log ("Blog data written to $jsonPath")
}
# Example call
GenerateBlogData -title "Sample Post" -content "This is a sample blog post."

