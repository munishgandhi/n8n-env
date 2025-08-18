#!/bin/bash
# n8n Environment Docker Update Script
# Usage: ./.claude/commands/system-docker-update.sh [--hard]
# Last Edit: 20250811-172100

set -e  # Exit on any error

PROJECT_ROOT="$(git rev-parse --show-toplevel)"
cd "$PROJECT_ROOT"  # Ensure we're in project root

# Default to soft update
UPDATE_MODE="soft"

# Help function
show_help() {
    echo "Usage: $0 [options]"
    echo
    echo "Updates Docker containers in the VC-MGR stack."
    echo
    echo "Modes:"
    echo "  Default (soft): Pull images and restart only changed containers"
    echo "    - Preserves container IDs (ngrok references stay intact)"
    echo "    - Faster update process"
    echo "    - Use for routine updates"
    echo
    echo "  Hard mode: Complete down/pull/up cycle"
    echo "    - Recreates all containers (new IDs)"
    echo "    - Cleans up networks and orphaned containers"
    echo "    - Fixes Docker Desktop display issues"
    echo "    - Use for troubleshooting or major changes"
    echo
    echo "Options:"
    echo "  --hard        Perform hard update (complete recreation)"
    echo "  -h, --help    Show this help message"
    echo
    echo "Examples:"
    echo "  $0            # Soft update (default)"
    echo "  $0 --hard     # Hard update with full recreation"
}

# Parse arguments
for arg in "$@"; do
    if [ -z "$arg" ]; then
        continue  # Skip empty arguments
    fi
    case $arg in
        --hard)
            UPDATE_MODE="hard"
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            echo "Unknown option: $arg"
            show_help
            exit 1
            ;;
    esac
done

# Navigate to project root
cd "$PROJECT_ROOT"

# Initialize logging
echo "🚀 VC-MGR Docker Update (${UPDATE_MODE^^} mode)..."
echo "Time: $(date)"
echo "Location: $(pwd)"
echo

# Show current status
echo ""
echo "🔧 === CURRENT CONTAINER STATUS ==="
docker-compose -f "$PROJECT_ROOT/docker/docker-compose.yml" ps

if [ "$UPDATE_MODE" = "hard" ]; then
    # HARD UPDATE: Complete recreation
    echo ""
    echo "🔧 === HARD UPDATE: STOPPING ALL CONTAINERS ==="
    echo -n "🔍 Stopping all services: "
    if docker-compose -f "$PROJECT_ROOT/docker/docker-compose.yml" down; then
        echo "✅ All containers stopped successfully"
        STOP_STATUS="✅"
    else
        echo "❌ Failed to stop containers"
        exit 1
    fi
    
    echo ""
    echo "🔧 === PULLING LATEST IMAGES ==="
    echo -n "🔍 Pulling latest images: "
    if docker-compose -f "$PROJECT_ROOT/docker/docker-compose.yml" pull; then
        echo "✅ All images pulled successfully"
        PULL_STATUS="✅"
    else
        echo "❌ Failed to pull images"
        exit 1
    fi
    
    echo ""
    echo "🔧 === STARTING ALL CONTAINERS (NEW) ==="
    echo -n "🔍 Starting all services: "
    if docker-compose -f "$PROJECT_ROOT/docker/docker-compose.yml" up -d; then
        echo "✅ All containers started successfully"
        START_STATUS="✅"
    else
        echo "❌ Failed to start containers"
        exit 1
    fi
    
    # Summary for hard update
    echo ""
    echo "🔧 === HARD UPDATE SUMMARY ==="
    echo "Stop containers: $STOP_STATUS"
    echo "Pull images: $PULL_STATUS"
    echo "Start containers: $START_STATUS"
    echo ""
    echo "⚠️  Note: Container IDs have changed. You may need to:"
    echo "   - Reconfigure ngrok tunnels in Docker Desktop"
    echo "   - Update any external references to container IDs"
    
else
    # SOFT UPDATE: Pull and restart only if needed
    echo ""
    echo "🔧 === SOFT UPDATE: PULLING LATEST IMAGES ==="
    echo "📦 Pulling latest images (containers keep running)..."
    if docker-compose -f "$PROJECT_ROOT/docker/docker-compose.yml" pull; then
        echo "✅ All images pulled successfully"
        PULL_STATUS="✅"
    else
        echo "❌ Failed to pull images"
        exit 1
    fi
    
    echo ""
    echo "🔧 === APPLYING UPDATES ==="
    echo "🔄 Recreating only containers with new images..."
    echo ""
    
    # This command only recreates containers whose images have changed
    if docker-compose -f "$PROJECT_ROOT/docker/docker-compose.yml" up -d; then
        echo ""
        echo "✅ Containers updated successfully"
        UPDATE_STATUS="✅"
    else
        echo "❌ Failed to update containers"
        exit 1
    fi
    
    # Summary for soft update
    echo ""
    echo "🔧 === SOFT UPDATE SUMMARY ==="
    echo "Pull images: $PULL_STATUS"
    echo "Update containers: $UPDATE_STATUS"
    echo ""
    echo "✅ Soft update completed!"
    echo "   - Container IDs preserved (ngrok tunnels intact)"
    echo "   - Only changed services were restarted"
fi

# Show final status
echo ""
echo "🔧 === UPDATED CONTAINER STATUS ==="
docker-compose -f "$PROJECT_ROOT/docker/docker-compose.yml" ps

echo ""
echo "✅ Docker update completed successfully!"

# Mode-specific final message
if [ "$UPDATE_MODE" = "hard" ]; then
    echo "Hard update performed - all containers recreated with new IDs."
else
    echo "Soft update performed - container IDs preserved where possible."
fi