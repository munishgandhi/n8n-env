---
description: Run comprehensive health validation
allowed-tools: Bash(./system-checks.sh:*)
---

# System Checks Command

Run comprehensive health validation showing clean system status.

Usage: `/system-checks`

## Instructions

1. Execute the system checks script:
```bash
cd "$(git rev-parse --show-toplevel)"
./.claude/commands/system-checks.sh "$ARGUMENTS"
```

2. **IMPORTANT**: Display the FULL output from the script explicitly to the user. Do not summarize or paraphrase - show the exact output you receive.