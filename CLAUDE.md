# Claude Code Instructions - n8n Environment

This file contains Claude-specific instructions for managing the n8n environment infrastructure.

## Available Tools & Commands

### Slash Commands (`.claude/commands/`)
- `/system-start` - Start all Docker services with health validation
- `/system-stop` - Stop services with graceful/force options  
- `/system-checks` - Run comprehensive health validation
- `/system-backup` - Backup workflows, database, and config
- `/system-docker-update` - Update containers with extension rebuild

### Agents (`.claude/agents/`)
- `git-90-track-commit-sync` - Intelligent git commit and sync

### Extensions (`docker/n8n-extensions/`)
- `HylyYouTubeNode` - YouTube transcript extraction via yt-dlp

### Docker Services (`docker/`)
- `n8n` (5678) - Workflow automation platform
- `n8n-mcp` (3001) - Model Context Protocol server
- `redis` - Caching and session storage  
- `sqlite-web-viewer` (8080) - Database browser
- `open-webui` (3000) - AI interface

For detailed information about each component, read the documentation in the respective directories:
- `/home/mg/src/n8n-env/.claude/agents/CLAUDE.md`
- `/home/mg/src/n8n-env/.claude/commands/CLAUDE.txt` 
- `/home/mg/src/n8n-env/docker/CLAUDE.md`

## Quick Start
```bash
/system-start    # Start all services
/system-checks   # Validate system health
/system-backup   # Backup critical data
```