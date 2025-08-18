---
description: Update Docker containers (soft by default, --hard for full recreation)
argument-hint: [--hard]
allowed-tools: Bash(./system-docker-update.sh:*)
---

# System Docker Update

Updates Docker containers in the VC-MGR stack with two modes: soft (default) or hard update.

## Soft Update (Default)
Preserves container IDs while updating images:
- Pulls latest images while containers run
- Restarts only containers with new images
- **Preserves ngrok tunnels and external references**
- Faster update process
- Use for routine updates

## Hard Update (--hard flag)
Complete recreation of all containers:
- Stops and removes all containers
- Pulls latest images
- Creates new containers with new IDs
- Fixes Docker Desktop display issues
- **Requires reconfiguring ngrok tunnels**
- Use for troubleshooting or major changes

Usage: 
- `/system-docker-update` - Soft update (preserves container IDs)
- `/system-docker-update --hard` - Hard update (full recreation)

Execute the command:
```bash
cd "$(git rev-parse --show-toplevel)" && ./.claude/commands/system-docker-update.sh "$ARGUMENTS"
```