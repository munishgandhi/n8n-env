#!/bin/bash
# n8n Environment System Checks Script
# Usage: ./.claude/commands/system-checks.sh
# Last Edit: 20250811-152800

set -e  # Exit on any error

PROJECT_ROOT="$(git rev-parse --show-toplevel)"
cd "$PROJECT_ROOT"  # Ensure we're in project root

# Get script directory for modules
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODULES_DIR="$SCRIPT_DIR/modules"

# Source shared functions
source "$MODULES_DIR/shared-functions.sh"

# Environment loading function
load_environment() {
    print_section "${GEAR} Loading Environment Configuration"
    
    if [ -f ".env" ]; then
        source .env
        print_test "Environment variables loaded" "PASS" "Loaded .env file"
        
        # Check critical environment variables
        if [ -n "$NOTION_API_KEY" ]; then
            print_test "Notion API key configured" "PASS" "Key length: ${#NOTION_API_KEY} characters"
        else
            print_test "Notion API key configured" "FAIL" "NOTION_API_KEY not found in .env"
        fi
        
        if [ -n "$N8N_API_KEY" ]; then
            print_test "n8n API key configured" "PASS" "Key length: ${#N8N_API_KEY} characters"
        else
            print_test "n8n API key configured" "FAIL" "N8N_API_KEY not found in .env"
        fi
        
        # Check database IDs
        local db_count=0
        for db_var in BACKLOG_DB_ID PLANNER_EMAIL_DB_ID PLANNER_PERSON_DB_ID PLANNER_FIRM_DB_ID PEOPLE_DB_ID FIRMS_DB_ID EMAIL_DB_ID; do
            if [ -n "${!db_var}" ]; then
                db_count=$((db_count + 1))
            fi
        done
        print_test "Database IDs configured" "PASS" "$db_count/7 database IDs found"
        
    else
        print_test "Environment file" "FAIL" ".env file not found"
        return 1
    fi
}

# Summary function
print_summary() {
    print_section "${ROCKET} System Validation Summary"
    
    echo -e "${CYAN}Test Results:${NC}"
    echo -e "  ${GREEN}✅ Passed: $PASSED_TESTS${NC}"
    echo -e "  ${RED}❌ Failed: $FAILED_TESTS${NC}"
    echo -e "  ${BLUE}📊 Total:  $TOTAL_TESTS${NC}"
    
    local success_rate=$((PASSED_TESTS * 100 / TOTAL_TESTS))
    
    if [ $FAILED_TESTS -eq 0 ]; then
        echo -e "\n${GREEN}🎉 ALL SYSTEMS OPERATIONAL! 🎉${NC}"
        echo -e "${GREEN}Success Rate: $success_rate%${NC}"
        echo -e "${GREEN}System is ready for development.${NC}"
    elif [ $success_rate -ge 80 ]; then
        echo -e "\n${YELLOW}⚠️  MOSTLY OPERATIONAL ⚠️${NC}"
        echo -e "${YELLOW}Success Rate: $success_rate%${NC}"
        echo -e "${YELLOW}Some components need attention but core functionality available.${NC}"
    else
        echo -e "\n${RED}🚨 SYSTEM ISSUES DETECTED 🚨${NC}"
        echo -e "${RED}Success Rate: $success_rate%${NC}"
        echo -e "${RED}Multiple failures detected. Check system configuration.${NC}"
    fi
    
    echo -e "\n${BLUE}📚 For troubleshooting guidance:${NC}"
    echo -e "${BLUE}   davinci/n8n-builder/00-StartHere/system-checks.md${NC}"
}

# Main execution
main() {
    clear
    echo -e "${BLUE}${ROCKET} VC-MGR System Validation ${ROCKET}${NC}"
    echo -e "${CYAN}Interactive comprehensive system check${NC}"
    echo -e "${CYAN}$(date)${NC}\n"
    
    # Change to project root if we're not there
    if [ ! -f ".env" ] && [ -f "../../.env" ]; then
        cd ../..
    fi
    
    # Initialize counters
    export TOTAL_TESTS=0
    export PASSED_TESTS=0
    export FAILED_TESTS=0
    
    # Run all system checks using modular components
    load_environment
    
    # Run modular system checks by calling their functions
    source "$MODULES_DIR/system-check-docker.sh"
    test_docker_containers
    test_port_availability  
    test_service_endpoints
    
    source "$MODULES_DIR/system-check-notion.sh"
    test_notion_api
    
    source "$MODULES_DIR/system-check-n8n-workflow.sh"
    test_n8n_workflow
    
    source "$MODULES_DIR/system-check-gmail.sh"
    test_gmail_api
    
    source "$MODULES_DIR/system-check-sqlite.sh"
    test_sqlite_database
    
    source "$MODULES_DIR/system-check-n8n-mcp.sh"
    test_mcp_server
    
    source "$MODULES_DIR/system-check-ollama.sh"
    test_ollama_llm
    
    # Print summary
    print_summary
    
    # Exit with appropriate code
    if [ $FAILED_TESTS -eq 0 ]; then
        exit 0
    else
        exit 1
    fi
}

# Run main function
main "$@"