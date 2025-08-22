#!/bin/bash

# Ollama System Check Module
# File: /home/mg/src/vc-mgr/.claude/scripts/modules/system-check-ollama.sh
# Purpose: Test Ollama LLM connectivity and functionality

# Source shared functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/shared-functions.sh"

test_ollama_llm() {
    print_section "${TEST} Ollama LLM Connectivity"
    
    # Test Ollama directly via PowerShell (since Ollama runs on Windows host)
    print_test "Ollama service test" "INFO" "Testing Windows Ollama via PowerShell from WSL"
    
    # Check if PowerShell is available from WSL
    if command -v powershell.exe >/dev/null 2>&1; then
        print_test "PowerShell access" "PASS" "PowerShell.exe available from WSL"
        
        # Test 1: Get available models via PowerShell
        local models_result=$(timeout 10 powershell.exe -Command "try { Invoke-RestMethod -Uri 'http://localhost:11434/api/tags' -Method GET | ConvertTo-Json -Depth 2 } catch { Write-Output 'ERROR' }" 2>/dev/null)
        
        if [[ "$models_result" != *"ERROR"* ]] && echo "$models_result" | jq -e '.models' >/dev/null 2>&1; then
            local model_count=$(echo "$models_result" | jq -r '.models | length' 2>/dev/null)
            print_test "Ollama API accessibility" "PASS" "Found $model_count models via Windows localhost:11434"
            
            if [ "$model_count" -gt 0 ]; then
                # Get first available model for testing
                local first_model=$(echo "$models_result" | jq -r '.models[0].name' 2>/dev/null)
                local models_list=$(echo "$models_result" | jq -r '.models[].name' 2>/dev/null | head -3 | tr '\n' ', ' | sed 's/,$//')
                print_test "Ollama models available" "PASS" "Models: $models_list"
                
                if [ -n "$first_model" ]; then
                    print_test "Ollama generation test" "INFO" "Testing model: $first_model"
                    
                    # Test 2: Test text generation via PowerShell
                    local generation_result=$(timeout 20 powershell.exe -Command "
                        try {
                            \$body = @{
                                model = '$first_model'
                                prompt = 'Hello! Please respond with Hello World from Ollama system test'
                                stream = \$false
                                options = @{ temperature = 0.1 }
                            } | ConvertTo-Json -Depth 3
                            Invoke-RestMethod -Uri 'http://localhost:11434/api/generate' -Method POST -ContentType 'application/json' -Body \$body | ConvertTo-Json -Depth 2
                        } catch {
                            Write-Output 'ERROR'
                        }" 2>/dev/null)
                    
                    if [[ "$generation_result" != *"ERROR"* ]] && echo "$generation_result" | jq -e '.response' >/dev/null 2>&1; then
                        local response_text=$(echo "$generation_result" | jq -r '.response' 2>/dev/null | head -c 80)
                        local duration=$(echo "$generation_result" | jq -r '.total_duration' 2>/dev/null)
                        local duration_sec=$(( duration / 1000000000 ))
                        print_test "Ollama LLM generation" "PASS" "Response: ${response_text}... (${duration_sec}s)"
                    else
                        print_test "Ollama LLM generation" "FAIL" "Failed to generate text with model $first_model"
                    fi
                else
                    print_test "Ollama model selection" "FAIL" "Could not identify model for testing"
                fi
            else
                print_test "Ollama models available" "WARN" "No models found - Ollama may need models installed"
            fi
        else
            print_test "Ollama API accessibility" "FAIL" "Ollama not accessible on Windows localhost:11434"
        fi
    else
        print_test "PowerShell access" "FAIL" "PowerShell.exe not available from WSL"
    fi
}

# Main function for this module
main() {
    test_ollama_llm
}

# Run if called directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi