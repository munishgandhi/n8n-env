# Claude Commands - n8n Environment

This directory contains system management commands accessible via Claude slash commands.

## Core Commands

### system-start (.md/.sh)
**Purpose:** Start the complete n8n development environment.
- Launches Docker containers with health checks
- Validates service connectivity
- Opens development URLs in browser
- **Usage:** `/system-start [--restart]`

### system-stop (.md/.sh)
**Purpose:** Stop all services with graceful shutdown options.
- Graceful container shutdown by default
- Force stop option for troubleshooting
- Data preservation options
- **Usage:** `/system-stop [--force] [--keep-data]`

### system-checks (.md/.sh)
**Purpose:** Comprehensive health validation of all services.
- Docker container status verification
- n8n API and database consistency validation
- Service endpoint testing (SQLite viewer, open-webui, MCP)
- Cross-platform Ollama LLM connectivity (Windows via PowerShell)
- **Usage:** `/system-checks`

### system-backup (.md/.sh)
**Purpose:** Create backups of critical data and configurations.
- n8n workflow exports and database backup
- Environment configuration preservation
- Timestamped backup organization
- **Usage:** `/system-backup [custom-name]`

### system-docker-update (.md/.sh)
**Purpose:** Update Docker containers with extension preservation.
- Soft update (preserves container IDs) or hard update (full recreation)
- Automatic n8n extension rebuild (YouTube node, etc.)
- Image pulling and selective container restart
- **Usage:** `/system-docker-update [--hard]`

## Modular Architecture

### modules/
**Purpose:** Reusable testing modules for system validation.

**shared-functions.sh** - Common utilities for colored output, test tracking, and command execution

**system-check-docker.sh** - Container status, port availability, and service endpoint validation

**system-check-n8n.sh** - n8n API connectivity, workflow counts, and API/SQLite consistency validation

**system-check-sqlite.sh** - Database integrity, workflow/execution/credential counts, and file size verification

**system-check-n8n-mcp.sh** - MCP server connectivity, JSON-RPC protocol testing, and authentication validation

**system-check-ollama.sh** - Cross-platform LLM connectivity via PowerShell from WSL to Windows Ollama

## Command Registration

Commands are automatically registered as Claude slash commands through their `.md` files:

```yaml
---
description: Command description
argument-hint: [optional arguments] 
allowed-tools: Bash(./script.sh:*)
---
```

The `.md` files serve as both documentation and command registration, enabling Claude to discover and execute them via the slash command interface.

## Error Handling

All scripts include:
- Comprehensive error checking and exit codes
- Detailed logging and status reporting
- Graceful failure handling with informative messages
- Environment validation before execution