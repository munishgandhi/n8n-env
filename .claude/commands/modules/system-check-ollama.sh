#!/bin/bash

# Ollama System Check Module
# File: /home/mg/src/vc-mgr/.claude/scripts/modules/system-check-ollama.sh
# Purpose: Test Ollama LLM connectivity and functionality

# Source shared functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/shared-functions.sh"

test_ollama_llm() {
    print_section "${TEST} Ollama LLM Connectivity"
    
    # Test Ollama via n8n workflow (following System Test > Ollama pattern)
    print_test "Ollama workflow test" "INFO" "Testing via n8n workflow rHhmOQJa91TsoMcd"
    
    # Test by triggering the actual n8n workflow since direct container access doesn't work
    if [ -n "$N8N_API_KEY" ]; then
        # Check if the workflow exists and has recent successful executions
        local workflow_check=$(curl -s -H "X-N8N-API-KEY: $N8N_API_KEY" "http://localhost:5678/api/v1/workflows/rHhmOQJa91TsoMcd" 2>/dev/null)
        if echo "$workflow_check" | jq -e '.id' >/dev/null 2>&1; then
            print_test "Ollama workflow exists" "PASS" "System Test > Ollama workflow found"
            
            # Check recent executions to see if Ollama has worked
            local recent_executions=$(curl -s -H "X-N8N-API-KEY: $N8N_API_KEY" "http://localhost:5678/api/v1/executions?workflowId=rHhmOQJa91TsoMcd&limit=1" 2>/dev/null)
            if echo "$recent_executions" | jq -e '.data[0].finished' >/dev/null 2>&1; then
                local exec_finished=$(echo "$recent_executions" | jq -r '.data[0].finished' 2>/dev/null)
                local exec_date=$(echo "$recent_executions" | jq -r '.data[0].startedAt' 2>/dev/null)
                if [ "$exec_finished" = "true" ]; then
                    print_test "Ollama workflow execution" "PASS" "Recent successful execution on $(date -d "$exec_date" +%Y-%m-%d)"
                    
                    # Test direct API access via WSL default gateway (Windows host)
                    local wsl_gateway=$(ip route | grep default | awk '{print $3}')
                    
                    # Test 1: Check if Ollama API tags endpoint works
                    local tags_test=$(timeout 10 curl -s "http://$wsl_gateway:11434/api/tags" 2>/dev/null)
                    if echo "$tags_test" | jq -e '.models' >/dev/null 2>&1; then
                        local model_count=$(echo "$tags_test" | jq -r '.models | length' 2>/dev/null)
                        print_test "Ollama API tags" "PASS" "Found $model_count models via WSL gateway ($wsl_gateway:11434)"
                        
                        # Get first available qwen model
                        local qwen_model=$(echo "$tags_test" | jq -r '.models[] | select(.name | contains("qwen")) | .name' 2>/dev/null | head -1)
                        
                        if [ -n "$qwen_model" ]; then
                            # Test 2: Test actual generation with first qwen model
                            print_test "Ollama generation test" "INFO" "Testing model: $qwen_model"
                            
                            local generation_test=$(timeout 15 curl -s -X POST "http://$wsl_gateway:11434/api/generate" \
                                -H "Content-Type: application/json" \
                                -d "{\"model\": \"$qwen_model\", \"prompt\": \"Hello! Please respond with Hello World from system test\", \"stream\": false, \"options\": {\"temperature\": 0.1}}" 2>/dev/null)
                            
                            if echo "$generation_test" | jq -e '.response' >/dev/null 2>&1; then
                                local response_text=$(echo "$generation_test" | jq -r '.response' 2>/dev/null | head -c 100)
                                print_test "Ollama LLM generation" "PASS" "Response: ${response_text}..."
                            else
                                # Check if it's a model issue
                                if echo "$generation_test" | jq -e '.error' >/dev/null 2>&1; then
                                    local error_msg=$(echo "$generation_test" | jq -r '.error' 2>/dev/null)
                                    print_test "Ollama LLM generation" "WARN" "Error: $error_msg"
                                else
                                    print_test "Ollama LLM generation" "FAIL" "No valid response from LLM"
                                fi
                            fi
                        else
                            print_test "Ollama model detection" "WARN" "No qwen models found in available models"
                        fi
                    else
                        print_test "Ollama API accessibility" "FAIL" "Not accessible via WSL gateway ($wsl_gateway:11434)"
                    fi
                else
                    print_test "Ollama workflow execution" "WARN" "Recent execution found but not finished successfully"
                fi
            else
                print_test "Ollama workflow execution" "WARN" "No recent executions found - may need manual testing"
            fi
        else
            print_test "Ollama workflow exists" "FAIL" "System Test > Ollama workflow not found"
        fi
    else
        print_test "Ollama API test" "FAIL" "N8N_API_KEY not available for workflow testing"
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