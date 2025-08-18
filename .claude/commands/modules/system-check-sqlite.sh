#!/bin/bash

# SQLite System Check Module
# File: /home/mg/src/vc-mgr/.claude/scripts/modules/system-check-sqlite.sh
# Purpose: Test SQLite database integrity and accessibility

# Source shared functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/shared-functions.sh"

test_sqlite_database() {
    print_section "${DATABASE} SQLite Database Integrity"
    
    # Test database via Docker container (following debugging-methodology.md pattern)
    if docker ps --format "table {{.Names}}" | grep -q "^n8n$"; then
        print_test "n8n container access" "PASS" "n8n container is running"
        
        # Get workflow count using Docker exec with Node.js sqlite3
        local workflow_count=$(docker exec n8n node -e "
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
        
        if [ "$workflow_count" != "Error" ] && [ -n "$workflow_count" ]; then
            print_test "Workflow count" "PASS" "$workflow_count workflows"
        else
            print_test "Workflow count" "WARN" "Could not query workflow table"
        fi
        
        # Get execution count
        local execution_count=$(docker exec n8n node -e "
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
        
        if [ "$execution_count" != "Error" ] && [ -n "$execution_count" ]; then
            print_test "Execution count" "PASS" "$execution_count executions"
        else
            print_test "Execution count" "WARN" "Could not query execution table"
        fi
        
        # Get credential count
        local credential_count=$(docker exec n8n node -e "
            const sqlite3 = require('/usr/local/lib/node_modules/n8n/node_modules/.pnpm/sqlite3@5.1.7/node_modules/sqlite3');
            const db = new sqlite3.Database('/home/node/.n8n/database.sqlite');
            db.get('SELECT COUNT(*) as count FROM credentials_entity', (err, row) => {
                if (err) {
                    console.log('Error');
                } else {
                    console.log(row.count);
                }
                db.close();
            });
        " 2>/dev/null || echo "Error")
        
        if [ "$credential_count" != "Error" ] && [ -n "$credential_count" ]; then
            print_test "Credential count" "PASS" "$credential_count credentials"
        else
            print_test "Credential count" "WARN" "Could not query credential table"
        fi
        
        # Test database file size within container
        local db_size=$(docker exec n8n ls -lh /home/node/.n8n/database.sqlite 2>/dev/null | awk '{print $5}')
        if [ -n "$db_size" ]; then
            print_test "Database file size" "PASS" "Size: $db_size"
        else
            print_test "Database file size" "WARN" "Could not check database file"
        fi
        
    else
        print_test "SQLite database test" "FAIL" "n8n container not running"
    fi
}

# Main function for this module
main() {
    test_sqlite_database
}

# Run if called directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi