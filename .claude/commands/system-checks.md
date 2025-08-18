---
description: Run comprehensive health validation
allowed-tools: Bash(./system-checks.sh:*)
---

# System Checks Command

Comprehensive health validation of all services and connectivity with data consistency verification.

## Systems Validated:
- **Docker containers** - status, port availability, service endpoints
- **n8n API** - health, authentication, workflow/active counts with SQLite cross-validation
- **SQLite database** - workflow, execution, credential counts and integrity
- **n8n-MCP server** - connectivity, JSON-RPC protocol, authentication
- **Ollama LLM** - connectivity and text generation via PowerShell (Windows host)

## Data Consistency Checks:
- **Workflow count:** API vs SQLite validation
- **Active workflows:** API vs SQLite validation  
- **Execution count:** SQLite only (API not available)
- **Credentials:** SQLite only (API access restricted)

Usage: `/system-checks`

Execute the command:
!bash
cd "$(git rev-parse --show-toplevel)" && ./.claude/commands/system-checks.sh "$ARGUMENTS"