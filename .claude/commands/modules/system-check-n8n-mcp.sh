#!/bin/bash

# n8n-MCP System Check Module
# File: /home/mg/src/vc-mgr/.claude/scripts/modules/system-check-n8n-mcp.sh
# Purpose: Test n8n-MCP server connectivity and functionality

# Source shared functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/shared-functions.sh"

test_mcp_server() {
    print_section "${GEAR} MCP Server Connectivity"
    
    # Load environment if not already loaded (for standalone testing)
    if [ -z "$N8N_MCP_AUTH_TOKEN" ] && [ -f "$(git rev-parse --show-toplevel)/.env" ]; then
        source "$(git rev-parse --show-toplevel)/.env"
    fi
    
    # Test MCP health endpoint (proper way)
    if run_test_command "curl -f http://localhost:3001/health" 5; then
        local health_response=$(curl -s http://localhost:3001/health 2>/dev/null)
        if echo "$health_response" | jq -e '.status' >/dev/null 2>&1; then
            local status=$(echo "$health_response" | jq -r '.status' 2>/dev/null)
            local version=$(echo "$health_response" | jq -r '.version' 2>/dev/null)
            print_test "MCP server health" "PASS" "Status: $status, Version: $version"
        else
            print_test "MCP server health" "PASS" "Server responding but health format unexpected"
        fi
        
        # Test MCP JSON-RPC protocol with authentication
        local mcp_token="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.n8nmcp.server.token"
        if [ -n "$N8N_MCP_AUTH_TOKEN" ]; then
            mcp_token="$N8N_MCP_AUTH_TOKEN"
        fi
        
        # Test MCP workflow listing capability
        local mcp_response=$(curl -s -X POST http://localhost:3001/mcp \
            -H "Content-Type: application/json" \
            -H "Authorization: Bearer $mcp_token" \
            -d '{
                "jsonrpc": "2.0",
                "id": 1,
                "method": "tools/call",
                "params": {
                    "name": "n8n_list_workflows",
                    "arguments": {
                        "limit": 1
                    }
                }
            }' 2>/dev/null)
        
        if echo "$mcp_response" | jq -e '.result' >/dev/null 2>&1; then
            local workflow_count=$(echo "$mcp_response" | jq -r '.result.content[0].text' 2>/dev/null | jq -r '.data | length' 2>/dev/null || echo "0")
            print_test "MCP JSON-RPC protocol" "PASS" "Successfully listed workflows: $workflow_count"
        else
            local error_msg=$(echo "$mcp_response" | jq -r '.error.message' 2>/dev/null || "Unknown error")
            print_test "MCP JSON-RPC protocol" "WARN" "Error: $error_msg"
        fi
        
        # Test MCP authentication
        if [ -n "$N8N_MCP_AUTH_TOKEN" ]; then
            print_test "MCP authentication" "PASS" "Using configured auth token"
        else
            print_test "MCP authentication" "WARN" "Using default token (consider setting N8N_MCP_AUTH_TOKEN)"
        fi
    else
        print_test "MCP server connectivity" "FAIL" "Server not responding to /health endpoint"
    fi
}

# Main function for this module
main() {
    test_mcp_server
}

# Run if called directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi