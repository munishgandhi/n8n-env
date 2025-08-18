---
description: Create timestamped system backup
allowed-tools: Bash(./system-backup.sh:*)
---

# System Backup Command

Complete system backup: extract workflows, update docs, backup critical data.

Creates timestamped backup of:
- n8n workflows (exported JSON)
- Updated workflow-map.md  
- Environment files and critical data
- Git-aware backup (only non-versioned data)

Usage: `/system-backup`

Execute the command:
!bash
cd "$(git rev-parse --show-toplevel)" && ./.claude/commands/system-backup.sh "$ARGUMENTS"