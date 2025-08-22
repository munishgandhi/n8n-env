#!/bin/bash

# n8n-MCP System Check Module
# File: /home/mg/src/vc-mgr/.claude/scripts/modules/system-check-n8n-mcp.sh
# Purpose: Test n8n-MCP server connectivity and functionality

# Source shared functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/shared-functions.sh"

test_mcp_server() {
    print_section "${GEAR} MCP Server Connectivity"
    
    # Test 1: MCP Diagnostic Check (comprehensive status)
    print_test "MCP diagnostic check" "INFO" "Testing comprehensive MCP functionality..."
    local diagnostic_result=$(claude --mcp-call 'mcp__n8n-mcp__n8n_diagnostic' '{}' 2>/dev/null)
    if echo "$diagnostic_result" | jq -e '.success' >/dev/null 2>&1; then
        local tools_count=$(echo "$diagnostic_result" | jq -r '.data.toolsAvailability.totalAvailable' 2>/dev/null || "unknown")
        local api_status=$(echo "$diagnostic_result" | jq -r '.data.apiConfiguration.configured' 2>/dev/null || "unknown")
        print_test "MCP diagnostic check" "PASS" "Tools available: $tools_count, API configured: $api_status"
    else
        print_test "MCP diagnostic check" "FAIL" "MCP tools not responding via Claude Code"
        return 1
    fi
    
    # Test 2: Database Statistics Check
    local stats_result=$(claude --mcp-call 'mcp__n8n-mcp__get_database_statistics' '{}' 2>/dev/null)
    if echo "$stats_result" | jq -e '.totalNodes' >/dev/null 2>&1; then
        local total_nodes=$(echo "$stats_result" | jq -r '.totalNodes' 2>/dev/null)
        local ai_tools=$(echo "$stats_result" | jq -r '.statistics.aiTools' 2>/dev/null)
        print_test "MCP database statistics" "PASS" "Nodes: $total_nodes, AI tools: $ai_tools"
    else
        print_test "MCP database statistics" "FAIL" "Could not retrieve node statistics"
    fi
    
    # Test 3: Tools Documentation Check
    local docs_result=$(claude --mcp-call 'mcp__n8n-mcp__tools_documentation' '{}' 2>/dev/null)
    if echo "$docs_result" | grep -q "n8n MCP Tools Reference" 2>/dev/null; then
        print_test "MCP tools documentation" "PASS" "Documentation system operational"
    else
        print_test "MCP tools documentation" "FAIL" "Documentation system not responding"
    fi
    
    # Test 4: Search Nodes Functionality
    local search_result=$(claude --mcp-call 'mcp__n8n-mcp__search_nodes' '{"query":"webhook","limit":2}' 2>/dev/null)
    if echo "$search_result" | jq -e '.results' >/dev/null 2>&1; then
        local result_count=$(echo "$search_result" | jq -r '.results | length' 2>/dev/null || "0")
        print_test "MCP search nodes" "PASS" "Search returned $result_count results"
    else
        print_test "MCP search nodes" "FAIL" "Node search functionality not working"
    fi
    
    # Test 5: Workflow Retrieval Check
    local workflows_result=$(claude --mcp-call 'mcp__n8n-mcp__n8n_list_workflows' '{"limit":1}' 2>/dev/null)
    if echo "$workflows_result" | jq -e '.data' >/dev/null 2>&1; then
        local workflow_count=$(echo "$workflows_result" | jq -r '.data | length' 2>/dev/null || "0")
        print_test "MCP workflow retrieval" "PASS" "Retrieved workflow data: $workflow_count workflows"
    else
        print_test "MCP workflow retrieval" "WARN" "Workflow API may not be accessible"
    fi
    
    # Legacy HTTP test (for reference, expected to fail in STDIO mode)
    if run_test_command "curl -f http://localhost:3001/health" 2 >/dev/null 2>&1; then
        print_test "MCP HTTP endpoint" "INFO" "HTTP endpoint available (unexpected in STDIO mode)"
    else
        print_test "MCP HTTP endpoint" "INFO" "No HTTP endpoint (correct for STDIO mode)"
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