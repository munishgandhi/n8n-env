---
description: Start development environment
argument-hint: [--restart]
allowed-tools: Bash(./system-start.sh:*)
---

# System Start Command

Start development environment: containers, health checks, browser launch.

Starts and verifies:
- Docker containers (n8n, databases)
- API connectivity tests
- Health checks for all services
- Opens development URLs in browser

Usage: `/system-start [--restart]`

```bash
cd "$(git rev-parse --show-toplevel)"
./.claude/commands/system-start.sh "$ARGUMENTS"
```