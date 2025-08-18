---
description: Run comprehensive health validation
allowed-tools: Bash(./system-checks.sh:*)
---

# System Checks Command

Comprehensive health validation of all services and connectivity.

Validates:
- Docker container status
- n8n workflow engine
- Database connectivity
- API endpoints
- Service health

Usage: `/system-checks`

Execute the command:
!bash
cd "$(git rev-parse --show-toplevel)" && ./.claude/commands/system-checks.sh "$ARGUMENTS"