---
description: Test minimal command execution
allowed-tools: Bash(./system-checks.sh:*)
---

```bash
cd "$(git rev-parse --show-toplevel)" && ./.claude/commands/system-checks.sh
```