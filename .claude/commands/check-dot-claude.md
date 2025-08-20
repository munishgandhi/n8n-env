---
description: Audit .claude/ directory for consistency
allowed-tools: Bash(./check-dot-claude.sh:*)
---

# Check Dot Claude Command

Audit .claude/ directory for consistency until no changes needed.

Performs comprehensive audit:
- Script consistency verification
- Guide documentation alignment  
- Command registration validation
- Permissions autonomy validation
- Iterative fixing until clean state

Usage: `/check-dot-claude`

Execute the command:
!bash
cd "$(git rev-parse --show-toplevel)" && ./.claude/commands/check-dot-claude.sh "$ARGUMENTS"