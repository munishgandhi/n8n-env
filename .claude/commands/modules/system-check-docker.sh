#!/bin/bash

# Docker System Check Module
# File: /home/mg/src/vc-mgr/.claude/scripts/modules/system-check-docker.sh
# Purpose: Test Docker containers and port availability

# Source shared functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/shared-functions.sh"

test_docker_containers() {
    print_section "${DOCKER} Docker Container Status"
    
    # Check if Docker is running
    if ! docker info >/dev/null 2>&1; then
        print_test "Docker service" "FAIL" "Docker is not running"
        return 1
    fi
    print_test "Docker service" "PASS" "Docker daemon is running"
    
    # Check specific containers
    local containers=("n8n" "n8n-mcp" "sqlite-web-viewer" "n8n_redis" "open-webui")
    local running_containers=0
    
    for container in "${containers[@]}"; do
        if docker ps --format "table {{.Names}}" | grep -q "^${container}$"; then
            local status=$(docker ps --format "table {{.Names}}\t{{.Status}}" | grep "^${container}" | cut -f2)
            print_test "Container: $container" "PASS" "Status: $status"
            running_containers=$((running_containers + 1))
        else
            print_test "Container: $container" "FAIL" "Container not running"
        fi
    done
    
    print_test "Container overview" "INFO" "$running_containers/${#containers[@]} containers running"
}

test_port_availability() {
    print_section "${NETWORK} Port Availability Tests"
    
    local ports=("5678:n8n" "3001:n8n-mcp" "8080:sqlite-viewer" "3000:open-webui")
    local internal_ports=("6379:redis")
    
    for port_service in "${ports[@]}"; do
        local port=$(echo "$port_service" | cut -d: -f1)
        local service=$(echo "$port_service" | cut -d: -f2)
        
        # Try multiple methods to detect port listening
        local port_check=false
        
        # Method 1: netstat
        if netstat -tlnp 2>/dev/null | grep -q ":${port} "; then
            port_check=true
        # Method 2: ss command
        elif ss -tlnp 2>/dev/null | grep -q ":${port} "; then
            port_check=true
        # Method 3: lsof
        elif lsof -i :${port} 2>/dev/null | grep -q "LISTEN"; then
            port_check=true
        # Method 4: try to connect
        elif timeout 2 bash -c "echo >/dev/tcp/localhost/${port}" 2>/dev/null; then
            port_check=true
        fi
        
        if [ "$port_check" = true ]; then
            print_test "Port $port ($service)" "PASS" "Port is listening"
        else
            print_test "Port $port ($service)" "FAIL" "Not listening"
        fi
    done
    
    # Test internal Docker ports differently
    for port_service in "${internal_ports[@]}"; do
        local port=$(echo "$port_service" | cut -d: -f1)
        local service=$(echo "$port_service" | cut -d: -f2)
        
        # Check if Redis container is running (internal port)
        if docker ps --format "table {{.Names}}" | grep -q "redis"; then
            print_test "Internal $port ($service)" "PASS" "Container running (internal port)"
        else
            print_test "Internal $port ($service)" "FAIL" "Redis container not running"
        fi
    done
}

test_service_endpoints() {
    print_section "${NETWORK} Service Endpoint Health"
    
    # n8n health and API tests are handled by system-check-n8n.sh module
    
    # SQLite viewer
    if run_test_command "curl -f http://localhost:8080" 5; then
        print_test "SQLite web viewer" "PASS" "http://localhost:8080"
    else
        print_test "SQLite web viewer" "FAIL" "Viewer not accessible"
    fi
    
    # open-webui (may be slow to start)
    if run_test_command "curl -f http://localhost:3000" 10; then
        print_test "open-webui interface" "PASS" "http://localhost:3000"
    else
        print_test "open-webui interface" "WARN" "Not accessible (may be starting)"
    fi
    
    # MCP server health endpoint (proper test)
    if run_test_command "curl -f http://localhost:3001/health" 5; then
        print_test "n8n-MCP server health" "PASS" "http://localhost:3001/health"
    else
        print_test "n8n-MCP server health" "FAIL" "MCP server health endpoint not responding"
    fi
}

# Main function for this module
main() {
    test_docker_containers
    test_port_availability
    test_service_endpoints
}

# Run if called directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi