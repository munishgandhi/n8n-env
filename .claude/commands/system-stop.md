---
description: Stop development environment
allowed-tools: Bash(./system-stop.sh:*)
---

# System Stop Command

Stop development environment: graceful container shutdown, session archival.

Performs:
- Graceful Docker container shutdown
- Session log archival
- Final status capture
- Data preservation verification

Usage: `/system-stop`

```bash
cd "$(git rev-parse --show-toplevel)"
./.claude/commands/system-stop.sh "$ARGUMENTS"
```