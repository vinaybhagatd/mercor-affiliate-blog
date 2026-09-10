Describe "RunPrompt.ps1 Parameter Binding and Output Files" {

    Context "PromptFile parameter" {
        It "Throws when PromptFile is missing" {
            { .\RunPrompt.ps1 } | Should -Throw "PromptFile parameter is required"
        }

        It "Throws when PromptFile does not exist" {
            { .\RunPrompt.ps1 -PromptFile "nonexistent.txt" } | Should -Throw "Prompt file not found"
        }

        It "Throws when PromptFile is empty" {
            $emptyFile = "empty.txt"
            Set-Content -Path $emptyFile -Value ""
            { .\RunPrompt.ps1 -PromptFile $emptyFile } | Should -Throw "Prompt file is empty"
            Remove-Item $emptyFile
        }

        It "Outputs success message when PromptFile is valid" {
            $result = .\RunPrompt.ps1 -PromptFile "prompts\blog-template.txt"
            $result | Should -Match "Output written successfully"
        }
    }

    Context "Model parameter" {
        It "Throws when Model is empty" {
            { .\RunPrompt.ps1 -PromptFile "prompts\blog-template.txt" -Model "" } | Should -Throw "Model parameter cannot be empty"
        }

        It "Outputs default model when not specified" {
            $result = .\RunPrompt.ps1 -PromptFile "prompts\blog-template.txt"
            $result | Should -Match "md-coder-qwen3-8b"
        }

        It "Outputs custom model name when specified" {
            $result = .\RunPrompt.ps1 -PromptFile "prompts\blog-template.txt" -Model "qwen2.5-7b-instruct"
            $result | Should -Match "qwen2.5-7b-instruct"
        }
    }

    Context "Help parameter" {
        It "Outputs usage text and exits cleanly" {
            $result = .\RunPrompt.ps1 -Help
            $result | Should -Match "Usage"
        }
    }

    Context "Output files" {
        BeforeAll {
            Remove-Item ".\outputs\blog-template-*.out.txt" -ErrorAction SilentlyContinue
            Remove-Item ".\outputs\blog-template-*.notes.txt" -ErrorAction SilentlyContinue
            Remove-Item ".\scripts\blog-template-*.updated.ps1" -ErrorAction SilentlyContinue
        }

        It "Creates a non-empty .out.txt file" {
            .\RunPrompt.ps1 -PromptFile "prompts\blog-template.txt" -Model "qwen2.5-7b-instruct"
            $files = Get-ChildItem -Path ".\outputs" -Filter "blog-template-*.out.txt"
            $files.Count | Should -BeGreaterThan 0
            (-Path 
        }

        It "Creates a notes file" {
            .\RunPrompt.ps1 -PromptFile "prompts\blog-template.txt" -Model "qwen2.5-7b-instruct"
            $files = Get-ChildItem -Path ".\outputs" -Filter "blog-template-*.notes.txt"
            $files.Count | Should -BeGreaterThan 0
        }

        It "Creates an updated script file" {
            .\RunPrompt.ps1 -PromptFile "prompts\blog-template.txt" -Model "qwen2.5-7b-instruct"
            $files = Get-ChildItem -Path ".\scripts" -Filter "blog-template-*.updated.ps1"
            $files.Count | Should -BeGreaterThan 0
        }
    }
}







