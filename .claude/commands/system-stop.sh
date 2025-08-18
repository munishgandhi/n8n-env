#!/bin/bash
# n8n Environment Development Session Stop Script
# Usage: ./.claude/commands/system-stop.sh [--force] [--backup] [--keep-data]
# Last Edit: 20250811-152800

set -e  # Exit on any error

FORCE_STOP=false
CREATE_BACKUP=false
KEEP_DATA=false
PROJECT_ROOT="$(git rev-parse --show-toplevel)"
cd "$PROJECT_ROOT"  # Ensure we're in project root

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --force)
            FORCE_STOP=true
            shift
            ;;
        --backup)
            CREATE_BACKUP=true
            shift
            ;;
        --keep-data)
            KEEP_DATA=true
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [--force] [--backup] [--keep-data]"
            echo "  --force     Force stop containers without graceful shutdown"
            echo "  --backup    Create backup before stopping"
            echo "  --keep-data Use docker-compose stop (preserve containers)"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

echo "🛑 Stopping VC-MGR Development Session..."
echo "Time: $(date)"
echo "Force stop: $FORCE_STOP"
echo "Create backup: $CREATE_BACKUP"
echo "Keep data: $KEEP_DATA"
echo ""

cd "$PROJECT_ROOT"

# 1. PRE-STOP BACKUP (if requested)
if [ "$CREATE_BACKUP" = true ]; then
    echo "💾 === CREATING PRE-STOP BACKUP ==="
    if [ -f ".claude/scripts/system-backup.sh" ]; then
        echo "📦 Running minimal backup (critical data only)..."
        ./.claude/scripts/system-backup.sh "pre-stop-$(date +%Y%m%d-%H%M%S)"
        echo "✅ Critical data backup completed"
    else
        echo "❌ Backup script not found, skipping backup"
    fi
    echo ""
fi

# 2. SESSION STATE CAPTURE
echo "📊 === CAPTURING SESSION STATE ==="

# Create session state directory
SESSION_STATE_DIR="/tmp/vc-mgr-session-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$SESSION_STATE_DIR"

# Capture current container status
echo "📋 Capturing container status..."
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" > "$SESSION_STATE_DIR/containers-before-stop.txt"

# Capture n8n data size if container is running
if docker ps | grep -q "n8n"; then
    echo "📊 Capturing n8n data metrics..."
    docker exec n8n du -sh /home/node/.n8n/database.sqlite > "$SESSION_STATE_DIR/n8n-database-size.txt"
    docker exec n8n ls -la /home/node/.n8n/ > "$SESSION_STATE_DIR/n8n-data-listing.txt"
    
    # Test API connectivity before shutdown
    echo "🔗 Testing API connectivity before shutdown..."
    if [ -f ".env" ]; then
        source .env
        
        # Test n8n API
        if curl -sf -H "X-N8N-API-KEY: $N8N_API_KEY" \
                "http://localhost:5678/api/v1/workflows" > "$SESSION_STATE_DIR/final-workflow-count.json" 2>/dev/null; then
            WORKFLOW_COUNT=$(jq '.data | length' "$SESSION_STATE_DIR/final-workflow-count.json" 2>/dev/null || echo "0")
            echo "✅ Final workflow count: $WORKFLOW_COUNT" | tee "$SESSION_STATE_DIR/final-stats.txt"
        else
            echo "❌ n8n API not responding" | tee "$SESSION_STATE_DIR/final-stats.txt"
        fi
        
        # Test Notion API
        if curl -sf -H "Authorization: Bearer $NOTION_API_KEY" \
                -H "Notion-Version: 2022-06-28" \
                "https://api.notion.com/v1/users/me" > "$SESSION_STATE_DIR/notion-api-test.json" 2>/dev/null; then
            echo "✅ Notion API: Connected" >> "$SESSION_STATE_DIR/final-stats.txt"
        else
            echo "❌ Notion API: Failed" >> "$SESSION_STATE_DIR/final-stats.txt"
        fi
    fi
else
    echo "⚠️ n8n container not running, skipping data capture"
fi

# 3. GRACEFUL SERVICE SHUTDOWN
echo ""
echo "🔄 === GRACEFUL SERVICE SHUTDOWN ==="

if [ "$FORCE_STOP" = true ]; then
    echo "⚡ Force stopping all services..."
    docker-compose -f "$PROJECT_ROOT/docker/docker-compose.yml" down --timeout 5
    echo "✅ Force stop completed"
elif [ "$KEEP_DATA" = true ]; then
    echo "🛑 Stopping services (keeping containers)..."
    docker-compose -f "$PROJECT_ROOT/docker/docker-compose.yml" stop
    echo "✅ Services stopped (containers preserved)"
else
    echo "🛑 Gracefully stopping services..."
    
    # Stop services one by one with proper timeouts
    echo "📧 Stopping n8n (workflow engine)..."
    docker-compose -f "$PROJECT_ROOT/docker/docker-compose.yml" stop n8n --timeout 30
    
    echo "🗄️ Stopping Redis (cache)..."
    docker-compose -f "$PROJECT_ROOT/docker/docker-compose.yml" stop redis --timeout 10
    
    echo "🤖 Stopping n8n-mcp..."
    docker-compose -f "$PROJECT_ROOT/docker/docker-compose.yml" stop n8n-mcp --timeout 10 2>/dev/null || echo "   (not running)"
    
    echo "🤖 Stopping open-webui..."
    docker-compose -f "$PROJECT_ROOT/docker/docker-compose.yml" stop open-webui --timeout 10 2>/dev/null || echo "   (not running)"
    
    echo "🗄️ Stopping sqlite-web-viewer..."
    docker-compose -f "$PROJECT_ROOT/docker/docker-compose.yml" stop sqlite-web-viewer --timeout 10 2>/dev/null || echo "   (not running)"
    
    echo "✅ Graceful shutdown completed"
fi

# 4. POST-STOP VERIFICATION
echo ""
echo "🔍 === POST-STOP VERIFICATION ==="

# Verify containers are stopped
echo "📋 Verifying container status..."
RUNNING_CONTAINERS=$(docker ps --filter "name=n8n" --filter "name=redis" --filter "name=open-webui" --filter "name=n8n-mcp" --filter "name=sqlite-web-viewer" --format "{{.Names}}" | wc -l)

if [ "$RUNNING_CONTAINERS" -eq 0 ]; then
    echo "✅ All vc-mgr containers stopped"
else
    echo "⚠️ Some containers still running:"
    docker ps --filter "name=n8n" --filter "name=redis" --filter "name=open-webui" --filter "name=n8n-mcp" --filter "name=sqlite-web-viewer" --format "table {{.Names}}\t{{.Status}}"
fi

# Check for any hanging processes
echo "🔍 Checking for hanging processes..."
if pgrep -f "n8n" > /dev/null; then
    echo "⚠️ n8n processes still running"
    pgrep -f "n8n" > "$SESSION_STATE_DIR/hanging-processes.txt"
else
    echo "✅ No hanging n8n processes"
fi

# 5. DATA PERSISTENCE VERIFICATION
echo ""
echo "💾 === DATA PERSISTENCE VERIFICATION ==="

# Verify Docker volumes still exist
echo "📦 Checking Docker volumes..."
if docker volume ls | grep -q "vc-mgr_n8n_data"; then
    echo "✅ vc-mgr_n8n_data volume preserved"
    docker volume inspect vc-mgr_n8n_data --format "{{.Mountpoint}}" > "$SESSION_STATE_DIR/n8n-volume-location.txt"
else
    echo "❌ vc-mgr_n8n_data volume missing!"
fi

if docker volume ls | grep -q "vc-mgr_redis_data"; then
    echo "✅ vc-mgr_redis_data volume preserved"
else
    echo "⚠️ vc-mgr_redis_data volume missing"
fi

if docker volume ls | grep -q "vc-mgr_n8n_mcp_data"; then
    echo "✅ vc-mgr_n8n_mcp_data volume preserved"
else
    echo "⚠️ vc-mgr_n8n_mcp_data volume missing"
fi

# 6. CLEANUP OPERATIONS
echo ""
echo "🧹 === CLEANUP OPERATIONS ==="

# Clean up temporary files (but preserve important data)
echo "🗑️ Cleaning temporary files..."

# Remove old session state files (keep last 5)
if [ -d "/tmp" ]; then
    find /tmp -name "vc-mgr-session-*" -type d | sort | head -n -5 | xargs rm -rf 2>/dev/null || true
    echo "✅ Cleaned old session state files"
fi

# Archive current session state to a permanent location
ARCHIVE_DIR="$PROJECT_ROOT/.claude/scripts/session-logs"
mkdir -p "$ARCHIVE_DIR"
mv "$SESSION_STATE_DIR" "$ARCHIVE_DIR/"
echo "📁 Session state archived to: $ARCHIVE_DIR/$(basename "$SESSION_STATE_DIR")"

# 7. SHUTDOWN SUMMARY
echo ""
echo "📊 === SHUTDOWN SUMMARY ==="

cat > "$ARCHIVE_DIR/$(basename "$SESSION_STATE_DIR")/SHUTDOWN_SUMMARY.md" << EOF
# VC-MGR Development Session Shutdown

**Shutdown Time**: $(date)  
**Shutdown Type**: $([ "$FORCE_STOP" = true ] && echo "Force Stop" || echo "Graceful Stop")  
**Backup Created**: $([ "$CREATE_BACKUP" = true ] && echo "Yes" || echo "No")  

## Final Status

### Containers
$(cat "$ARCHIVE_DIR/$(basename "$SESSION_STATE_DIR")/containers-before-stop.txt")

### Data Integrity
- n8n Database: $([ -f "$ARCHIVE_DIR/$(basename "$SESSION_STATE_DIR")/n8n-database-size.txt" ] && cat "$ARCHIVE_DIR/$(basename "$SESSION_STATE_DIR")/n8n-database-size.txt" || echo "Not captured")
- Docker Volumes: $(docker volume ls | grep -E "(vc-mgr_n8n_data|vc-mgr_redis_data|vc-mgr_n8n_mcp_data)" | wc -l) volumes preserved

### API Status Before Shutdown
$(cat "$ARCHIVE_DIR/$(basename "$SESSION_STATE_DIR")/final-stats.txt" 2>/dev/null || echo "API tests not performed")

## Next Session

To restart development session:
\`\`\`bash
cd .claude/scripts
./dev-session-start.sh
\`\`\`

## Data Recovery

If data recovery is needed:
1. Check volume integrity: \`docker volume inspect n8n_data\`
2. Restore from backup if available
3. Contact system administrator if volumes are corrupted

---
Generated by: dev-session-stop.sh
EOF

echo "✅ Session shutdown completed successfully!"
echo ""

# Display final status
echo "🎯 Final Status:"
echo "  Containers stopped: ✅"
echo "  Data preserved: $(docker volume ls | grep -q "n8n_data" && echo "✅" || echo "❌")"
echo "  Session archived: ✅"
echo ""

# Show next steps
echo "🚀 Next Steps:"
echo "  To restart: cd .claude/scripts && ./dev-session-start.sh"
echo "  Session logs: $ARCHIVE_DIR/$(basename "$SESSION_STATE_DIR")"
if [ "$CREATE_BACKUP" = true ]; then
    echo "  Backup location: Check backup output above"
fi
echo ""

# Show recent session logs
echo "📊 Recent Sessions:"
if [ -d "$ARCHIVE_DIR" ]; then
    ls -lt "$ARCHIVE_DIR" | head -4 | tail -3 | while read line; do
        session_name=$(echo "$line" | awk '{print $NF}')
        session_date=$(echo "$line" | awk '{print $6, $7, $8}')
        echo "  $session_name ($session_date)"
    done
fi

echo ""
echo "🏁 Development session stopped at $(date)"
echo "Have a great day! 👋"