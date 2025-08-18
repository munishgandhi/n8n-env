#!/bin/bash
# n8n Environment Development Session Startup Script
# Usage: ./.claude/commands/system-start.sh [--restart]
# Last Edit: 20250811-152800

set -e  # Exit on any error

RESTART_MODE=false
if [[ "$1" == "--restart" ]]; then
    RESTART_MODE=true
fi
PROJECT_ROOT="$(git rev-parse --show-toplevel)"
cd "$PROJECT_ROOT"  # Ensure we're in project root

echo "🚀 Starting n8n Environment Development Session..."
echo "Time: $(date)"
echo "Location: $(pwd)"
echo "Mode: $($RESTART_MODE && echo "RESTART" || echo "START")"
echo ""

# Change to project root directory
cd "$PROJECT_ROOT"
echo "📁 Project root: $(pwd)"

# RESTART MODE: Clean up existing services first
if [ "$RESTART_MODE" = true ]; then
    echo ""
    echo "🧹 === RESTART MODE: CLEANING UP EXISTING SERVICES ==="
    
    # Restart all services via docker-compose
    echo "🐳 Restarting all services..."
    docker-compose -f "$PROJECT_ROOT/docker/docker-compose.yml" restart
    
    echo "⏳ Waiting for services to stabilize..."
    sleep 8
fi

# 1. CONTAINER INFRASTRUCTURE CHECK
echo ""
echo "🐳 === CONTAINER INFRASTRUCTURE CHECK ==="

# Check if Docker is running, start Docker Desktop if needed
echo "🔍 Checking Docker status..."
if ! docker info > /dev/null 2>&1; then
    echo "⚠️ Docker is not running. Starting Docker Desktop..."
    
    # Start Docker Desktop on Windows via WSL
    if [ -f "/mnt/c/Program Files/Docker/Docker/Docker Desktop.exe" ]; then
        echo "🚀 Launching Docker Desktop..."
        /mnt/c/Program\ Files/Docker/Docker/Docker\ Desktop.exe &
        
        # Wait for Docker to be ready
        echo "⏳ Waiting for Docker Desktop to start..."
        for i in {1..30}; do
            if docker info > /dev/null 2>&1; then
                echo "✅ Docker Desktop is ready"
                break
            fi
            echo "   Waiting... ($i/30)"
            sleep 2
        done
        
        # Final check
        if ! docker info > /dev/null 2>&1; then
            echo "❌ Docker Desktop failed to start within 60 seconds"
            echo "Please manually start Docker Desktop and run this command again"
            exit 1
        fi
    else
        echo "❌ Docker Desktop not found at expected location"
        echo "Please ensure Docker Desktop is installed and run this command again"
        exit 1
    fi
else
    echo "✅ Docker is running"
fi

# Start core services if not running
if [ "$RESTART_MODE" = false ]; then
    echo "⚡ Starting Docker services..."
    docker-compose -f "$PROJECT_ROOT/docker/docker-compose.yml" up -d
    
    # Wait for services to be ready
    echo "⏳ Waiting for services to start..."
    sleep 5
fi

# SQLite web viewer and open-webui are now managed by docker-compose
echo "✅ All services started via docker-compose"

# Docker AI Agent Check
echo "🤖 Checking Docker AI Agent..."
if docker ai version > /dev/null 2>&1; then
    ai_version=$(docker ai version 2>/dev/null || echo "unknown")
    echo "✅ Docker AI Agent available (v$ai_version)"
else
    echo "⚠️ Docker AI Agent not available"
fi

# Check container status
echo "📋 Container status:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep -E "(n8n|redis|open-webui|sqlite-web|n8n-mcp)"

# 2. SERVICE HEALTH VERIFICATION
echo ""
echo "🩺 === SERVICE HEALTH VERIFICATION ==="

# Test n8n health
echo -n "🔍 n8n health check: "
if curl -sf http://localhost:5678/healthz > /dev/null 2>&1; then
    echo "✅ Healthy"
    N8N_STATUS="✅"
else
    echo "❌ Failed"
    N8N_STATUS="❌"
fi

# Test n8n UI accessibility
echo -n "🌐 n8n UI accessibility: "
if curl -sf "http://localhost:5678/" | grep -q "n8n.io" > /dev/null 2>&1; then
    echo "✅ Accessible"
    UI_STATUS="✅"
else
    echo "❌ Failed"
    UI_STATUS="❌"
fi

# Start n8n-mcp AFTER n8n is confirmed healthy
if [ "$N8N_STATUS" = "✅" ]; then
    echo "🔌 Starting n8n-mcp (n8n is healthy)..."
    if ! docker ps --format "{{.Names}}" | grep -q "n8n-mcp"; then
        docker-compose -f "$PROJECT_ROOT/docker/docker-compose.yml" start n8n-mcp
    fi
    sleep 3  # Give MCP server time to connect
fi

# Test open-webui (optional)
echo -n "🤖 open-webui accessibility: "
if curl -sf http://localhost:3000/ > /dev/null 2>&1; then
    echo "✅ Accessible"
    WEBUI_STATUS="✅"
else
    echo "❌ Not accessible (optional service)"
    WEBUI_STATUS="⚠️"
fi

# Test SQLite web viewer
echo -n "🗄️ SQLite web viewer: "
if curl -sf http://localhost:8080/ > /dev/null 2>&1; then
    echo "✅ Accessible"
    SQLITE_STATUS="✅"
else
    echo "❌ Failed"
    SQLITE_STATUS="❌"
fi

# Verify n8n-mcp status
echo -n "🔌 n8n-mcp: "
if docker ps --format "{{.Names}}" | grep -q "n8n-mcp"; then
    if docker logs n8n-mcp --tail 5 2>&1 | grep -q "Server running on port 3001"; then
        echo "✅ Ready for MCP connections"
        MCP_STATUS="✅"
    else
        echo "⚠️ Container running but not connected"
        MCP_STATUS="⚠️"
    fi
else
    echo "❌ Container not running"
    MCP_STATUS="❌"
fi

# Test Docker AI Agent
echo -n "🤖 Docker AI Agent: "
if docker ai version > /dev/null 2>&1; then
    echo "✅ Available"
    DOCKER_AI_STATUS="✅"
else
    echo "❌ Not available"
    DOCKER_AI_STATUS="❌"
fi

# 3. ENVIRONMENT CONFIGURATION
echo ""
echo "⚙️ === ENVIRONMENT CONFIGURATION ==="

# Load environment variables from project root
if [ -f "$PROJECT_ROOT/.env" ]; then
    echo "🔧 Loading environment variables..."
    source "$PROJECT_ROOT/.env"
    echo "✅ Environment loaded"
    
    # Verify critical variables
    echo "🔑 Verifying API keys:"
    if [ -n "$NOTION_API_KEY" ]; then
        echo "  ✅ NOTION_API_KEY configured (${#NOTION_API_KEY} chars)"
    else
        echo "  ❌ NOTION_API_KEY missing"
    fi
    
    if [ -n "$N8N_API_KEY" ]; then
        echo "  ✅ N8N_API_KEY configured (${#N8N_API_KEY} chars)"
    else
        echo "  ❌ N8N_API_KEY missing"
    fi
    
    # Count database UUIDs
    DB_COUNT=$(grep -c "_DB_ID=" "$PROJECT_ROOT/.env" || echo "0")
    echo "  ✅ Database UUIDs configured: $DB_COUNT/7"
    
else
    echo "❌ .env file not found!"
    exit 1
fi

# 4. API CONNECTIVITY TESTS
echo ""
echo "🌐 === API CONNECTIVITY TESTS ==="

# Test Notion API
echo -n "🗃️ Notion API authentication: "
if notion_result=$(curl -sf -H "Authorization: Bearer $NOTION_API_KEY" \
                       -H "Content-Type: application/json" \
                       -H "Notion-Version: 2022-06-28" \
                       "https://api.notion.com/v1/users/me" 2>/dev/null); then
    notion_name=$(echo "$notion_result" | grep -o '"name":"[^"]*"' | cut -d'"' -f4)
    echo "✅ Connected as: $notion_name"
    NOTION_STATUS="✅"
else
    echo "❌ Failed"
    NOTION_STATUS="❌"
fi

# Test Backlog database connectivity
echo -n "📊 Backlog database access: "
if backlog_result=$(curl -sf -X POST "https://api.notion.com/v1/databases/$BACKLOG_DB_ID/query" \
                         -H "Authorization: Bearer $NOTION_API_KEY" \
                         -H "Content-Type: application/json" \
                         -H "Notion-Version: 2022-06-28" \
                         -d '{"page_size": 1}' 2>/dev/null); then
    echo "✅ Database accessible"
    BACKLOG_STATUS="✅"
else
    echo "❌ Failed"
    BACKLOG_STATUS="❌"
fi

# Test n8n API if n8n is healthy
if [ "$N8N_STATUS" = "✅" ]; then
    echo -n "🔧 n8n API access: "
    if workflow_result=$(curl -sf -X GET -H "X-N8N-API-KEY: $N8N_API_KEY" \
                              "http://localhost:5678/api/v1/workflows" 2>/dev/null); then
        workflow_count=$(echo "$workflow_result" | jq '.data | length' 2>/dev/null || echo "0")
        echo "✅ API working, $workflow_count workflows found"
        WORKFLOW_STATUS="✅"
    else
        echo "❌ Failed"
        WORKFLOW_STATUS="❌"
    fi
else
    echo "⚠️ n8n API test skipped (service unhealthy)"
    WORKFLOW_STATUS="⚠️"
fi

# 5. DATA PERSISTENCE CHECK
echo ""
echo "💾 === DATA PERSISTENCE CHECK ==="

# Check n8n data volume (correct volume name)
echo -n "📦 n8n data volume: "
if docker volume inspect vc-mgr_n8n_data > /dev/null 2>&1; then
    echo "✅ Volume exists (vc-mgr_n8n_data)"
    VOLUME_STATUS="✅"
else
    echo "❌ Volume missing"
    VOLUME_STATUS="❌"
fi

# Check n8n database size
echo -n "🗄️ n8n database: "
if [ "$N8N_STATUS" = "✅" ]; then
    db_size=$(docker exec n8n du -sh /home/node/.n8n/database.sqlite 2>/dev/null | cut -f1)
    echo "✅ Size: $db_size"
    DATABASE_STATUS="✅"
else
    echo "⚠️ Cannot check (n8n unhealthy)"
    DATABASE_STATUS="⚠️"
fi

# 6. WORKFLOW DIRECTORY STRUCTURE
echo ""
echo "📁 === WORKFLOW DIRECTORY STRUCTURE ==="

if [ -d "project/n8n-workflows" ]; then
    echo "✅ Workflow management directories:"
    for dir in download edit upload archive; do
        if [ -d "project/n8n-workflows/$dir" ]; then
            count=$(find "project/n8n-workflows/$dir" -name "*.json" | wc -l)
            echo "  ✅ $dir/: $count files"
        else
            echo "  ❌ $dir/: missing"
        fi
    done
    WORKFLOW_DIR_STATUS="✅"
else
    echo "❌ Workflow directory structure missing"
    WORKFLOW_DIR_STATUS="❌"
fi

# 7. DEVELOPMENT SESSION SUMMARY
echo ""
echo "📊 === DEVELOPMENT SESSION SUMMARY ==="

echo "🟢 Services:"
echo "  n8n Health: $N8N_STATUS"
echo "  n8n UI: $UI_STATUS" 
echo "  SQLite Viewer: $SQLITE_STATUS"
echo "  open-webui: $WEBUI_STATUS"
echo "  n8n-mcp: $MCP_STATUS"
echo "  Docker AI Agent: $DOCKER_AI_STATUS"

echo "🟡 APIs:"
echo "  Notion API: $NOTION_STATUS"
echo "  Backlog DB: $BACKLOG_STATUS"
echo "  n8n API: $WORKFLOW_STATUS"

echo "🔵 Data:"
echo "  Volume: $VOLUME_STATUS"
echo "  Database: $DATABASE_STATUS"
echo "  Workflows: $WORKFLOW_DIR_STATUS"

# Overall status determination
if [[ "$N8N_STATUS" = "✅" && "$NOTION_STATUS" = "✅" && "$VOLUME_STATUS" = "✅" ]]; then
    OVERALL_STATUS="🟢 READY FOR DEVELOPMENT"
    EXIT_CODE=0
elif [[ "$N8N_STATUS" = "✅" && "$NOTION_STATUS" = "✅" ]]; then
    OVERALL_STATUS="🟡 READY WITH WARNINGS"
    EXIT_CODE=0
else
    OVERALL_STATUS="🔴 ISSUES REQUIRE ATTENTION"
    EXIT_CODE=1
fi

echo ""
echo "🎯 Overall Status: $OVERALL_STATUS"

# 8. QUICK ACCESS INFORMATION
echo ""
echo "🔗 === QUICK ACCESS INFORMATION ==="
echo "🔧 n8n Workflow Editor: http://localhost:5678"
echo "🗄️ SQLite Database Viewer: http://localhost:8080"
echo "🤖 open-webui LLM Interface: http://localhost:3000"
echo "🔌 n8n-mcp: Ready for MCP connections (HTTP mode on port 3001)"
echo "🤖 Docker AI Agent: Use 'docker ai' for AI assistance"
echo "📚 Project Documentation: ./project/dev-session-guide.md"
echo "📁 Workflow Management: ./project/n8n-workflows/"
echo ""

# 9. SUGGESTED NEXT STEPS
if [ $EXIT_CODE -eq 0 ]; then
    echo "✨ === SUGGESTED NEXT STEPS ==="
    echo "1. Open n8n UI: http://localhost:5678"
    echo "2. Test MCP server options:"
    echo "   - VS Code: Command Palette → 'MCP Inspector' → Connect to n8n-mcp-server"
    echo "   - Docker AI: 'docker ai \"Help me with n8n workflows\"'"
    echo "3. Review current workflows and test status"
    echo "4. Continue with pending TDD tasks:"
    echo "   - Test-03: Complete Entry Exists scenario"
    echo "   - Test-04: Multiple Dates Gap Finding"
    echo "   - Test-05: Date Validation (never today)"
    echo "   - Test-06: Error Handling patterns"
    echo "5. Implement backlog-creator.json workflow"
    echo ""
else
    echo "🔧 === TROUBLESHOOTING REQUIRED ==="
    echo "Issues detected. Review the summary above and:"
    echo "1. Check container logs: docker logs n8n"
    echo "2. Verify .env configuration"
    echo "3. Test connectivity manually"
    echo "4. Consult: ./project/dev-session-guide.md"
    echo ""
fi

echo "⏱️ Session startup completed in $(date)"

# 10. AUTO-OPEN DEVELOPMENT URLS IN BROWSER
# Always open browsers regardless of system status
# This ensures developers can access UIs even if some services are still starting
echo ""
echo "🌐 === OPENING DEVELOPMENT URLS ==="

# Check if we're in a GUI environment with browser available
if [ -f "/mnt/c/Windows/System32/cmd.exe" ]; then
        # WSL environment with Windows access
        echo "🔧 Opening n8n Workflow Editor..."
        /mnt/c/Windows/System32/cmd.exe /c start "http://localhost:5678" > /dev/null 2>&1 &
        sleep 1
        
        echo "🗄️ Opening SQLite Database Viewer..."
        /mnt/c/Windows/System32/cmd.exe /c start "http://localhost:8080" > /dev/null 2>&1 &
        sleep 1
        
        echo "🤖 Opening open-webui LLM Interface..."
        /mnt/c/Windows/System32/cmd.exe /c start "http://localhost:3000" > /dev/null 2>&1 &
        
        echo "✅ All development URLs opened in Windows browser"
    elif command -v xdg-open > /dev/null 2>&1; then
        echo "🔧 Opening n8n Workflow Editor..."
        xdg-open "http://localhost:5678" > /dev/null 2>&1 &
        sleep 1
        
        echo "🗄️ Opening SQLite Database Viewer..."
        xdg-open "http://localhost:8080" > /dev/null 2>&1 &
        sleep 1
        
        echo "🤖 Opening open-webui LLM Interface..."
        xdg-open "http://localhost:3000" > /dev/null 2>&1 &
        
        echo "✅ All development URLs opened in browser"
    elif command -v wslview > /dev/null 2>&1; then
        # WSL environment
        echo "🔧 Opening n8n Workflow Editor..."
        wslview "http://localhost:5678" > /dev/null 2>&1 &
        sleep 1
        
        echo "🗄️ Opening SQLite Database Viewer..."
        wslview "http://localhost:8080" > /dev/null 2>&1 &
        sleep 1
        
        echo "🤖 Opening open-webui LLM Interface..."
        wslview "http://localhost:3000" > /dev/null 2>&1 &
        
        echo "✅ All development URLs opened in browser"
    else
        echo "ℹ️ Browser auto-open not available. Manually visit:"
        echo "   🔧 http://localhost:5678"
        echo "   🗄️ http://localhost:8080"
        echo "   🤖 http://localhost:3000"
    fi

echo ""
echo "Happy coding! 🎉"

exit $EXIT_CODE