#!/bin/bash

# n8n Workflow System Check Module
# File: /home/mg/src/vc-mgr/.claude/scripts/modules/system-check-n8n-workflow.sh
# Purpose: Test n8n workflow execution and webhook functionality

# Source shared functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/shared-functions.sh"

test_n8n_workflow() {
    print_section "${TEST} n8n Workflow Execution Test"
    
    local webhook_id="c9unHIWl045BuIDf"
    local test_data='{"test": "system-check", "timestamp": "'$(date -Iseconds)'"}'
    
    print_test "Webhook test preparation" "INFO" "Testing webhook: $webhook_id"
    
    # Trigger webhook
    local response=$(curl -s -X POST "http://localhost:5678/webhook/$webhook_id" \
        -H "Content-Type: application/json" \
        -d "$test_data" 2>/dev/null)
    
    if [ $? -eq 0 ] && [ -n "$response" ]; then
        print_test "Webhook trigger" "PASS" "Webhook responded successfully"
        
        # Check recent executions if N8N_API_KEY is available
        if [ -n "$N8N_API_KEY" ]; then
            sleep 2  # Give execution time to complete
            local executions=$(curl -s -H "X-N8N-API-KEY: $N8N_API_KEY" \
                "http://localhost:5678/api/v1/executions?limit=1" 2>/dev/null)
            
            if echo "$executions" | jq -e '.data[0]' >/dev/null 2>&1; then
                local status=$(echo "$executions" | jq -r '.data[0].finished' 2>/dev/null)
                local mode=$(echo "$executions" | jq -r '.data[0].mode' 2>/dev/null)
                if [ "$status" = "true" ] && [ "$mode" = "webhook" ]; then
                    print_test "Workflow execution" "PASS" "Execution completed successfully"
                else
                    print_test "Workflow execution" "WARN" "Execution may be running or failed"
                fi
            else
                print_test "Execution validation" "WARN" "Could not verify execution status"
            fi
        else
            print_test "Execution validation" "WARN" "N8N_API_KEY not available for validation"
        fi
    else
        print_test "Webhook trigger" "FAIL" "Webhook did not respond"
    fi
}

# Main function for this module
main() {
    test_n8n_workflow
}

# Run if called directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi