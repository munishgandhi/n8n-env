#!/bin/bash

# Gmail System Check Module
# File: /home/mg/src/vc-mgr/.claude/scripts/modules/system-check-gmail.sh
# Purpose: Test Gmail API direct connectivity and functionality

# Source shared functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/shared-functions.sh"

test_gmail_api() {
    print_section "${NETWORK} Gmail API Direct Test"
    
    # Test direct Gmail API access using toolbox script
    if [ -f ".claude/toolbox-gmail/gmail-query.js" ]; then
        print_test "Gmail script available" "PASS" "Found gmail-query.js"
        
        if command -v node >/dev/null 2>&1; then
            print_test "Node.js available" "PASS" "Node.js runtime found"
            
            # Test Gmail connectivity by getting last 5 emails
            print_test "Gmail connectivity test" "INFO" "Testing direct Gmail API access..."
            
            local yesterday=$(date -d "yesterday" +%Y-%m-%d)
            local gmail_result=$(timeout 15 node .claude/toolbox-gmail/gmail-query.js --date "$yesterday" --max 5 2>/dev/null)
            
            if echo "$gmail_result" | grep -q "Query complete:"; then
                local message_count=$(echo "$gmail_result" | grep "Query complete:" | sed 's/.*: \([0-9]*\) messages.*/\1/')
                print_test "Gmail API connectivity" "PASS" "Successfully retrieved $message_count messages"
                
                # Show some message details
                if [ "$message_count" -gt 0 ]; then
                    local first_message=$(echo "$gmail_result" | grep -A 1 "Message Details:" | tail -1 | sed 's/^[ ]*//')
                    print_test "Gmail message retrieval" "PASS" "Sample: $first_message"
                else
                    print_test "Gmail message retrieval" "WARN" "No messages found for yesterday"
                fi
            else
                # Check for common errors
                if echo "$gmail_result" | grep -q "401\|unauthorized\|expired"; then
                    print_test "Gmail API connectivity" "WARN" "Authentication expired - token needs refresh"
                elif echo "$gmail_result" | grep -q "credentials"; then
                    print_test "Gmail API connectivity" "FAIL" "Credential configuration error"
                else
                    print_test "Gmail API connectivity" "FAIL" "Could not connect to Gmail API"
                fi
            fi
        else
            print_test "Node.js available" "FAIL" "Node.js not found - required for Gmail testing"
        fi
    else
        print_test "Gmail script available" "FAIL" "gmail-query.js not found in .claude/toolbox-gmail/"
    fi
}

# Main function for this module
main() {
    test_gmail_api
}

# Run if called directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi