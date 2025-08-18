#!/bin/bash

# Notion System Check Module
# File: /home/mg/src/vc-mgr/.claude/scripts/modules/system-check-notion.sh
# Purpose: Test Notion API connectivity and database accessibility

# Source shared functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/shared-functions.sh"

test_notion_api() {
    print_section "${DATABASE} Notion API Deep Function Test"
    
    if [ -z "$NOTION_API_KEY" ]; then
        print_test "Notion API setup" "FAIL" "NOTION_API_KEY not configured"
        return 1
    fi
    
    # Test each database
    local databases=("BACKLOG_DB_ID:Backlog" "PLANNER_EMAIL_DB_ID:PlannerEmail" "PLANNER_PERSON_DB_ID:PlannerPerson" "PLANNER_FIRM_DB_ID:PlannerFirm" "PEOPLE_DB_ID:People" "FIRMS_DB_ID:Firms" "EMAIL_DB_ID:Email")
    
    for db_info in "${databases[@]}"; do
        local db_var=$(echo "$db_info" | cut -d: -f1)
        local db_name=$(echo "$db_info" | cut -d: -f2)
        local db_id="${!db_var}"
        
        if [ -n "$db_id" ]; then
            local response=$(curl -s -X POST "https://api.notion.com/v1/databases/$db_id/query" \
                -H "Authorization: Bearer $NOTION_API_KEY" \
                -H "Notion-Version: 2022-06-28" \
                -H "Content-Type: application/json" \
                -d '{"page_size": 1}' 2>/dev/null)
            
            if echo "$response" | jq -e '.results' >/dev/null 2>&1; then
                local row_count=$(echo "$response" | jq '.results | length' 2>/dev/null)
                print_test "$db_name database" "PASS" "Accessible, sample rows: $row_count"
            else
                local error=$(echo "$response" | jq -r '.message // "Unknown error"' 2>/dev/null)
                print_test "$db_name database" "FAIL" "Error: $error"
            fi
        else
            print_test "$db_name database" "FAIL" "$db_var not configured"
        fi
    done
}

# Main function for this module
main() {
    test_notion_api
}

# Run if called directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi