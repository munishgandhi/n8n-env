#!/bin/bash

# n8n System Check Module
# File: /home/mg/src/n8n-env/.claude/commands/modules/system-check-n8n.sh
# Purpose: Test n8n API connectivity and database consistency

# Source shared functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/shared-functions.sh"

test_n8n_workflow() {
    print_section "${TEST} n8n System Connectivity"
    
    # Load environment if not already loaded (for standalone testing)
    if [ -z "$N8N_API_KEY" ] && [ -f "$(git rev-parse --show-toplevel)/.env" ]; then
        source "$(git rev-parse --show-toplevel)/.env"
    fi
    
    # Test 1: n8n health endpoint
    if run_test_command "curl -f http://localhost:5678/healthz" 5; then
        print_test "n8n health endpoint" "PASS" "n8n service is healthy"
    else
        print_test "n8n health endpoint" "FAIL" "n8n health check failed"
        return 1
    fi
    
    # Test 2: n8n API authentication and workflow listing
    if [ -n "$N8N_API_KEY" ]; then
        print_test "n8n API key" "PASS" "API key configured"
        
        # Get workflow list via API
        local workflows=$(curl -s -H "X-N8N-API-KEY: $N8N_API_KEY" \
            "http://localhost:5678/api/v1/workflows" 2>/dev/null)
        
        if echo "$workflows" | jq -e '.data' >/dev/null 2>&1; then
            local workflow_count=$(echo "$workflows" | jq '.data | length' 2>/dev/null)
            local total_count=$(echo "$workflows" | jq '.count' 2>/dev/null)
            print_test "n8n API workflow count" "PASS" "$workflow_count workflows"
            
            # Test active workflow count
            local active_count=$(echo "$workflows" | jq '[.data[] | select(.active == true)] | length' 2>/dev/null)
            print_test "n8n API active workflows" "PASS" "$active_count active workflows"
        else
            local error_msg=$(echo "$workflows" | jq -r '.message' 2>/dev/null || "API request failed")
            print_test "n8n API workflow listing" "FAIL" "Error: $error_msg"
        fi
        
        # Note: n8n API doesn't provide execution count endpoint, so we skip this
        print_test "n8n API execution count" "SKIP" "Not available via API (use SQLite for count)"
        local execution_count="N/A"
        
        # Cross-validate with SQLite data (if n8n container is running)
        if docker ps --format "table {{.Names}}" | grep -q "^n8n$"; then
            local sqlite_workflow_count=$(docker exec n8n node -e "
                const sqlite3 = require('/usr/local/lib/node_modules/n8n/node_modules/.pnpm/sqlite3@5.1.7/node_modules/sqlite3');
                const db = new sqlite3.Database('/home/node/.n8n/database.sqlite');
                db.get('SELECT COUNT(*) as count FROM workflow_entity', (err, row) => {
                    if (err) {
                        console.log('Error');
                    } else {
                        console.log(row.count);
                    }
                    db.close();
                });
            " 2>/dev/null || echo "Error")
            
            local sqlite_active_count=$(docker exec n8n node -e "
                const sqlite3 = require('/usr/local/lib/node_modules/n8n/node_modules/.pnpm/sqlite3@5.1.7/node_modules/sqlite3');
                const db = new sqlite3.Database('/home/node/.n8n/database.sqlite');
                db.get('SELECT COUNT(*) as count FROM workflow_entity WHERE active = 1', (err, row) => {
                    if (err) {
                        console.log('Error');
                    } else {
                        console.log(row.count);
                    }
                    db.close();
                });
            " 2>/dev/null || echo "Error")
            
            local sqlite_execution_count=$(docker exec n8n node -e "
                const sqlite3 = require('/usr/local/lib/node_modules/n8n/node_modules/.pnpm/sqlite3@5.1.7/node_modules/sqlite3');
                const db = new sqlite3.Database('/home/node/.n8n/database.sqlite');
                db.get('SELECT COUNT(*) as count FROM execution_entity', (err, row) => {
                    if (err) {
                        console.log('Error');
                    } else {
                        console.log(row.count);
                    }
                    db.close();
                });
            " 2>/dev/null || echo "Error")
            
            # Validate workflow count consistency
            if [ "$sqlite_workflow_count" != "Error" ] && [ -n "$sqlite_workflow_count" ]; then
                if [ "$workflow_count" -eq "$sqlite_workflow_count" ]; then
                    print_test "Workflow count consistency" "PASS" "API: $workflow_count, SQLite: $sqlite_workflow_count ✓"
                else
                    print_test "Workflow count consistency" "WARN" "API: $workflow_count, SQLite: $sqlite_workflow_count (mismatch)"
                fi
            else
                print_test "SQLite workflow validation" "WARN" "Could not query SQLite database"
            fi
            
            # Validate active workflow count consistency
            if [ "$sqlite_active_count" != "Error" ] && [ -n "$sqlite_active_count" ]; then
                if [ "$active_count" -eq "$sqlite_active_count" ]; then
                    print_test "Active workflow consistency" "PASS" "API: $active_count, SQLite: $sqlite_active_count ✓"
                else
                    print_test "Active workflow consistency" "WARN" "API: $active_count, SQLite: $sqlite_active_count (mismatch)"
                fi
            else
                print_test "SQLite active workflow validation" "WARN" "Could not query active workflows from SQLite"
            fi
            
            # Skip execution count consistency since API doesn't provide this
            if [ "$sqlite_execution_count" != "Error" ] && [ -n "$sqlite_execution_count" ]; then
                print_test "Execution count (SQLite only)" "PASS" "SQLite: $sqlite_execution_count executions"
            else
                print_test "SQLite execution validation" "WARN" "Could not query executions from SQLite"
            fi
        else
            print_test "Database cross-validation" "SKIP" "n8n container not running"
        fi
    else
        print_test "n8n API key" "FAIL" "N8N_API_KEY not configured"
        print_test "n8n API workflow listing" "SKIP" "API key required"
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