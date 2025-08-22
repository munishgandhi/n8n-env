#!/bin/bash
# VC-MGR Check Dot Claude Script
# Usage: ./.claude/commands/check-dot-claude.sh
# Last Edit: 20250811-152800

set -e  # Exit on any error

PROJECT_ROOT="$(git rev-parse --show-toplevel)"
cd "$PROJECT_ROOT"  # Ensure we're in project root

echo "🔍 Auditing all *.md and *.sh files in .claude/ directory..."
echo ""

# Function to run a single audit round
run_audit_round() {
    local round_number=$1
    echo "📋 AUDIT ROUND $round_number"
    echo "=============================="
    
    local changes_made=0
    
    # Check 1: Script headers match actual filenames in usage lines
    echo "1. Checking script headers match actual filenames..."
    for script in .claude/scripts/*.sh; do
        if [[ -f "$script" ]]; then
            script_name=$(basename "$script")
            usage_line=$(grep "^# Usage:" "$script" 2>/dev/null || echo "")
            if [[ -n "$usage_line" ]] && [[ ! "$usage_line" == *"$script_name"* ]]; then
                echo "  ❌ $script_name: Usage line doesn't match filename"
                changes_made=1
            fi
        fi
    done
    
    # Check 2: Documentation references use current script names
    echo "2. Checking documentation references..."
    for doc in .claude/*.md; do
        if [[ -f "$doc" ]]; then
            # Check for old script references
            old_refs=$(grep -n "create-workflow-map\|dev-session-\|backup-n8n\|dev-workflow-sqlite-extract\|[^-]learn\.sh" "$doc" 2>/dev/null || true)
            if [[ -n "$old_refs" ]]; then
                echo "  ❌ $(basename "$doc"): Contains deprecated script references"
                echo "$old_refs" | sed 's/^/    /'
                changes_made=1
            fi
        fi
    done
    
    # Check 3: All scripts work from any directory (PROJECT_ROOT pattern)
    echo "3. Checking PROJECT_ROOT patterns..."
    for script in .claude/scripts/*.sh; do
        if [[ -f "$script" ]]; then
            if ! grep -q 'PROJECT_ROOT.*dirname.*\.\./\.\.' "$script"; then
                echo "  ❌ $(basename "$script"): Missing or incorrect PROJECT_ROOT pattern"
                changes_made=1
            fi
        fi
    done
    
    # Check 4: Consistent formatting and naming conventions
    echo "4. Checking formatting conventions..."
    for file in .claude/*.md .claude/scripts/*.sh; do
        if [[ -f "$file" ]]; then
            # Check for Last Edit timestamp in scripts
            if [[ "$file" == *.sh ]] && ! grep -q "# Last Edit: [0-9]\{8\}-[0-9]\{6\}" "$file"; then
                echo "  ❌ $(basename "$file"): Missing Last Edit timestamp"
                changes_made=1
            fi
        fi
    done
    
    # Check 5: No broken cross-references between files
    echo "5. Checking cross-references..."
    for doc in .claude/*.md; do
        if [[ -f "$doc" ]]; then
            # Check for references to non-existent files
            refs=$(grep -o '\[[^]]*\]([a-zA-Z0-9_-]*\.md)' "$doc" 2>/dev/null || true)
            while IFS= read -r ref; do
                if [[ -n "$ref" ]]; then
                    file_ref=$(echo "$ref" | sed 's/.*(\(.*\))/\1/')
                    if [[ ! -f ".claude/$file_ref" ]]; then
                        echo "  ❌ $(basename "$doc"): Broken reference to $file_ref"
                        changes_made=1
                    fi
                fi
            done <<< "$refs"
        fi
    done
    
    # Check 6: Permissions configuration for maximum autonomy
    echo "6. Checking permissions for maximum autonomy..."
    if [[ -f ".claude/settings.local.json" ]]; then
        # Check for broken wildcard permissions (Claude Code doesn't support true wildcards)
        broken_wildcards=$(grep -c '"[A-Za-z]*(\*)"' .claude/settings.local.json 2>/dev/null || echo "0")
        broken_wildcards=${broken_wildcards//[[:space:]]/}
        if [[ $broken_wildcards -gt 0 ]]; then
            echo "  ❌ settings.local.json: Contains broken wildcard permissions ($broken_wildcards found) - use tool names without wildcards"
            changes_made=1
        fi
        
        # Check for required autonomous permissions (tool names only)
        required_tools=("Bash" "Read" "Write" "Edit" "MultiEdit" "Glob" "Grep" "LS" "Task" "TodoRead" "TodoWrite" "NotebookRead" "NotebookEdit" "WebFetch")
        for tool in "${required_tools[@]}"; do
            if ! grep -q "\"$tool\"" .claude/settings.local.json; then
                echo "  ❌ settings.local.json: Missing autonomous permission $tool"
                changes_made=1
            fi
        done
        
        # Check for old commands section (should be removed)
        if grep -q '"commands"' .claude/settings.local.json; then
            echo "  ❌ settings.local.json: Contains deprecated 'commands' section (use .md files instead)"
            changes_made=1
        fi
    else
        echo "  ❌ Missing .claude/settings.local.json file"
        changes_made=1
    fi
    
    echo ""
    if [[ $changes_made -eq 0 ]]; then
        echo "✅ Round $round_number: No issues found!"
        return 0
    else
        echo "⚠️  Round $round_number: Issues detected (see above)"
        return 1
    fi
}

# Main audit loop
round=1
max_rounds=10

while [[ $round -le $max_rounds ]]; do
    if run_audit_round $round; then
        echo ""
        echo "🎉 AUDIT COMPLETE: All consistency checks passed!"
        echo "   No changes needed after round $round"
        exit 0
    fi
    
    echo ""
    echo "🔧 Issues found in round $round. Manual fixes may be needed."
    echo "   Rerun this script after making corrections."
    echo ""
    
    ((round++))
done

echo "⚠️  AUDIT INCOMPLETE: Reached maximum rounds ($max_rounds)"
echo "   Manual intervention may be required"
exit 1