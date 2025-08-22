#!/bin/bash

# Shared Functions for System Checks
# File: /home/mg/src/vc-mgr/.claude/scripts/modules/shared-functions.sh
# Purpose: Common functions used by all system check modules

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Emojis for visual feedback
CHECK="✅"
CROSS="❌"
WARNING="⚠️"
INFO="ℹ️"
ROCKET="🚀"
GEAR="⚙️"
DATABASE="🗄️"
NETWORK="🌐"
DOCKER="🐳"
TEST="🧪"

# Counter for tests (will be managed by parent script)
TOTAL_TESTS=${TOTAL_TESTS:-0}
PASSED_TESTS=${PASSED_TESTS:-0}
FAILED_TESTS=${FAILED_TESTS:-0}

# Function to print section headers
print_section() {
    echo -e "\n${BLUE}═══════════════════════════════════════${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}═══════════════════════════════════════${NC}"
}

# Function to print test status
print_test() {
    local test_name="$1"
    local status="$2"
    local details="$3"
    
    if [ "$status" = "PASS" ]; then
        TOTAL_TESTS=$((TOTAL_TESTS + 1))
        echo -e "${GREEN}${CHECK} ${test_name}${NC}"
        if [ -n "$details" ]; then
            echo -e "   ${CYAN}${details}${NC}"
        fi
        PASSED_TESTS=$((PASSED_TESTS + 1))
    elif [ "$status" = "FAIL" ]; then
        TOTAL_TESTS=$((TOTAL_TESTS + 1))
        echo -e "${RED}${CROSS} ${test_name}${NC}"
        if [ -n "$details" ]; then
            echo -e "   ${RED}${details}${NC}"
        fi
        FAILED_TESTS=$((FAILED_TESTS + 1))
    elif [ "$status" = "WARN" ]; then
        TOTAL_TESTS=$((TOTAL_TESTS + 1))
        echo -e "${YELLOW}${WARNING} ${test_name}${NC}"
        if [ -n "$details" ]; then
            echo -e "   ${YELLOW}${details}${NC}"
        fi
        PASSED_TESTS=$((PASSED_TESTS + 1))  # Count warnings as passed
    else
        # INFO status - don't count as test, just display
        echo -e "${PURPLE}${INFO} ${test_name}${NC}"
        if [ -n "$details" ]; then
            echo -e "   ${PURPLE}${details}${NC}"
        fi
    fi
}

# Function to run command with timeout and capture output
run_test_command() {
    local cmd="$1"
    local timeout_duration="${2:-10}"
    
    if timeout "$timeout_duration" bash -c "$cmd" >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# Function to get command output safely
get_command_output() {
    local cmd="$1"
    local timeout_duration="${2:-10}"
    
    timeout "$timeout_duration" bash -c "$cmd" 2>/dev/null || echo "Command failed or timed out"
}

# Export functions and variables for use by modules
export -f print_section print_test run_test_command get_command_output
export TOTAL_TESTS PASSED_TESTS FAILED_TESTS
export RED GREEN YELLOW BLUE PURPLE CYAN NC
export CHECK CROSS WARNING INFO ROCKET GEAR DATABASE NETWORK DOCKER TEST