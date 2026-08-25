# Set the path to the source folder containing Markdown files
$sourceFolderPath = "C:\Users\LMTest\promotional\mercor-affiliate-blog\src\GeneratedBlogs"

# Get a list of all .md files in the source folder
$files = Get-ChildItem -Path $sourceFolderPath -Filter *.md

foreach ($file in $files) {
    # Construct the full file path
    $filePath = Join-Path -Path $sourceFolderPath -ChildPath $file.Name

    # Read the content of the file
    $content = Get-Content $filePath -Raw

    # Check if the front matter starts with 'date:'
    if ($content.StartsWith("date: ")) {
        # Extract the date part before the first space
        $datePart = $content.Split(' ')[0]
        
        # Ensure that there's only one space between 'date:' and the date part
        if ($datePart -notmatch " ") {
            Write-Host "Warning: Invalid date format in $filePath. Original content:"
            Write-Output $content
            Write-Host "Corrected content:"
            $correctedContent = "date: `"$datePart`""
            Write-Output $correctedContent
            
            # Update the file content
            Set-Content -Path $filePath -Value $correctedContent
            
            # Print a log message
            Write-Output "Fixed $file → date corrected"
        } else {
            Write-Host "Warning: Multiple spaces in front matter for $filePath. Original content:"
            Write-Output $content
            Write-Host "Corrected content:"
            $correctedContent = "date: `"$datePart`""
            Write-Output $correctedContent
            
            # Update the file content
            Set-Content -Path $filePath -Value $correctedContent
            
            # Print a log message
            Write-Output "Fixed $file → date corrected"
        }
    } else {
        Write-Host "No front matter found in $filePath. Skipping."
    }
}
