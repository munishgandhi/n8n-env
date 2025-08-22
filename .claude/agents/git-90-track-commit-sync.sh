#!/bin/bash

# git-90-track-commit-sync.sh - Add all files, commit, push, and verify clean
# Usage: ./git-90-track-commit-sync.sh [commit-message]
# 
# Performs complete git synchronization:
#   - Adds all untracked and modified files
#   - Creates a commit with all changes
#   - Pushes to remote repository
#   - Verifies repository is clean

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔄 Git Track, Commit & Sync${NC}"
echo "============================"
echo ""

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo -e "${RED}❌ Not in a git repository!${NC}"
    exit 1
fi

# Get current branch
BRANCH=$(git branch --show-current)
echo -e "${BLUE}📍 Current branch:${NC} $BRANCH"

# 1. Check initial status
echo ""
echo -e "${YELLOW}1️⃣ Initial repository status:${NC}"
INITIAL_STATUS=$(git status --porcelain)
if [ -z "$INITIAL_STATUS" ]; then
    echo -e "${GREEN}✅ Repository is already clean - nothing to commit${NC}"
    exit 0
else
    # Count changes
    UNTRACKED=$(echo "$INITIAL_STATUS" | grep -c "^??" || true)
    MODIFIED=$(echo "$INITIAL_STATUS" | grep -c "^ M" || true)
    ADDED=$(echo "$INITIAL_STATUS" | grep -c "^A " || true)
    DELETED=$(echo "$INITIAL_STATUS" | grep -c "^ D" || true)
    
    echo "  📊 Changes found:"
    [ $UNTRACKED -gt 0 ] && echo "     - Untracked files: $UNTRACKED"
    [ $MODIFIED -gt 0 ] && echo "     - Modified files: $MODIFIED"
    [ $ADDED -gt 0 ] && echo "     - Added files: $ADDED"
    [ $DELETED -gt 0 ] && echo "     - Deleted files: $DELETED"
fi

# 2. Add all changes
echo ""
echo -e "${YELLOW}2️⃣ Adding all changes...${NC}"
git add -A
echo -e "${GREEN}✅ All files added to staging${NC}"

# 3. Show what will be committed
echo ""
echo -e "${YELLOW}3️⃣ Files to be committed:${NC}"
git status --short

# 4. Create commit
echo ""
echo -e "${YELLOW}4️⃣ Creating commit...${NC}"

# Use provided message or generate one
if [ $# -eq 1 ]; then
    COMMIT_MSG="$1"
else
    # Generate commit message based on changes
    if [ $UNTRACKED -gt 0 ] && [ $MODIFIED -gt 0 ]; then
        COMMIT_MSG="chore: add new files and update existing ones"
    elif [ $UNTRACKED -gt 0 ]; then
        COMMIT_MSG="chore: add new files"
    elif [ $MODIFIED -gt 0 ]; then
        COMMIT_MSG="chore: update existing files"
    elif [ $DELETED -gt 0 ]; then
        COMMIT_MSG="chore: remove obsolete files"
    else
        COMMIT_MSG="chore: track, commit, and sync all changes"
    fi
    
    COMMIT_MSG="$COMMIT_MSG

- Added untracked files: $UNTRACKED
- Modified files: $MODIFIED
- Deleted files: $DELETED

🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>"
fi

# Create commit
git commit -m "$COMMIT_MSG"
COMMIT_HASH=$(git rev-parse HEAD)
echo -e "${GREEN}✅ Commit created: ${COMMIT_HASH:0:7}${NC}"

# 5. Push to remote
echo ""
echo -e "${YELLOW}5️⃣ Pushing to remote...${NC}"
if git push origin "$BRANCH"; then
    echo -e "${GREEN}✅ Successfully pushed to origin/$BRANCH${NC}"
else
    echo -e "${RED}❌ Push failed! Attempting with upstream...${NC}"
    if git push --set-upstream origin "$BRANCH"; then
        echo -e "${GREEN}✅ Successfully pushed with upstream to origin/$BRANCH${NC}"
    else
        echo -e "${RED}❌ Push failed! Check your network connection and authentication${NC}"
        git status
        exit 1
    fi
fi

# Verify push succeeded
echo -e "${BLUE}🔍 Verifying push...${NC}"
UNPUSHED=$(git log origin/"$BRANCH"..HEAD --oneline)
if [ -z "$UNPUSHED" ]; then
    echo -e "${GREEN}✅ All commits successfully pushed${NC}"
else
    echo -e "${RED}❌ Warning: Some commits not pushed:${NC}"
    echo "$UNPUSHED"
fi

# 6. Verify repository is clean
echo ""
echo -e "${YELLOW}6️⃣ Verifying repository status...${NC}"
FINAL_STATUS=$(git status --porcelain)
if [ -z "$FINAL_STATUS" ]; then
    echo -e "${GREEN}✅ Repository is clean!${NC}"
else
    echo -e "${RED}❌ Warning: Repository still has uncommitted changes!${NC}"
    git status --short
    exit 1
fi

# 7. Final summary
echo ""
echo "=== Repository Status ==="
echo "Branch: $BRANCH"
echo "Remote: $(git remote get-url origin)"
echo "Latest: ${COMMIT_HASH:0:7}"
echo "Clean: ✅ Yes"
echo "========================"
echo ""
echo -e "${GREEN}✨ All changes successfully tracked, committed, and synced!${NC}"