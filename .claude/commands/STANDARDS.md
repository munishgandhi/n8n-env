# n8n Environment Command Standards

**Purpose:** Define standards for slash commands in the n8n-env project

## Command File Structure

Every slash command consists of:

1. **Command File** (`.claude/commands/command-name.md`) - Claude Code slash command definition
2. **Script File** (`.claude/commands/command-name.sh`) - Executable implementation 

## Required .md File Format

```markdown
---
description: Brief single-line description (required)
argument-hint: [optional-args] (optional)
allowed-tools: Bash(./script-name.sh:*) (required)
---

# Command Name

Brief description.

Usage: `/command-name [args]`

```bash
cd "$(git rev-parse --show-toplevel)" && ./.claude/commands/script-name.sh "$ARGUMENTS"
```
```

## Key Requirements

- Use ```bash code blocks (not !bash directive)
- Standard execution pattern with git rev-parse
- Pass "$ARGUMENTS" to script
- Include allowed-tools permission

## Script Requirements

- Must be executable (`chmod +x`)
- Use `#!/bin/bash` shebang
- Include `set -e` for error handling
- Support `-h, --help` flag

This simplified standard ensures consistent command behavior in the n8n environment.