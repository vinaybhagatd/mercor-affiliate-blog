Describe "RunPrompt.ps1 Parameter Binding and Output Files" {

    Context "PromptFile parameter" {
        It "Shows error when PromptFile is missing" {
            $result = & { .\RunPrompt.ps1 } 2 | &1
            $result | Should -Match "Prompt file not found"
        }

        It "Runs successfully when PromptFile is provided" {
            $result = & { .\RunPrompt.ps1 -PromptFile "prompts\blog-template.txt" } 2 | &1
            $result | Should -Not -Match "Error"
        }

        It "Fails gracefully when PromptFile does not exist" {
            $result = & { .\RunPrompt.ps1 -PromptFile "nonexistent.txt" } 2 | &1
            $result | Should -Match "Prompt file not found"
        }
    }

    Context "Model parameter" {
        It "Uses default model when not specified" {
            $result = & { .\RunPrompt.ps1 -PromptFile "prompts\blog-template.txt" } 2 | &1
            $result | Should -Match "md-coder-qwen3-8b"
        }

        It "Accepts a custom model name" {
            $result = & { .\RunPrompt.ps1 -PromptFile "prompts\blog-template.txt" -Model "qwen2.5-7b-instruct" } 2 | &1
            $result | Should -Match "qwen2.5-7b-instruct"
        }
    }

    Context "Help parameter" {
        It "Shows help text and exits cleanly" {
            $result = & { .\RunPrompt.ps1 -Help } 2 | &1
            $result | Should -Match "Usage"
        }
    }

    Context "Output files" {
        It "Creates an .out.txt file" {
            .\RunPrompt.ps1 -PromptFile "prompts\blog-template.txt" -Model "qwen2.5-7b-instruct"
            $files = Get-ChildItem -Path ".\outputs" -Filter "blog-template-*.out.txt"
            $files.Count | Should -BeGreaterThan 0
        }
    }
}

