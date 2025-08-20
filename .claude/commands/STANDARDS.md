# VC-MGR Slash Command Standards

**Last Updated:** 2025-08-11  
**Purpose:** Define standards for .md files, .sh scripts, and slash command registration

This document establishes the comprehensive standards discovered through analysis of existing system management commands (`system-start`, `system-backup`, `check-dot-claude`, `generate-config`, etc.).

## Overview: Two-File System

Every slash command consists of two coordinated components:

1. **Command File** (`.claude/commands/command-name.md`) - Claude Code slash command definition
2. **Script File** (`.claude/commands/command-name.sh`) - Executable implementation in same directory
3. **Registration** - Automatic discovery by Claude Code from `.claude/commands/` directory

## 1. Slash Command (.md) File Standards

### File Location
```
.claude/commands/command-name.md
```

### Required Structure
```markdown
---
description: Brief single-line description (required)
argument-hint: [optional-args] (optional - only if command takes arguments)
allowed-tools: Bash(./script-name.sh:*) (required)
---

# Command Name

Brief description paragraph explaining purpose.

Feature/capability list:
- Feature 1
- Feature 2  
- Feature 3

Usage: `/command-name [args]`

!bash
cd "$(git rev-parse --show-toplevel)" && ./.claude/commands/script-name.sh "$ARGUMENTS"
```

### YAML Frontmatter Requirements

**Required Fields:**
- `description` - Single line, under 80 characters
- `allowed-tools` - Must include `Bash(./script-name.sh:*)`

**Optional Fields:**
- `argument-hint` - Only include if command accepts arguments (e.g., `[--restart]`, `[workflow-name]`)

**Allowed Tools Patterns:**
- Script execution: `./script-name.sh:*` (for .sh files) or `node:*` (for .js files)
- Additional tools as needed for validation

### Content Standards

**Description Section:**
- Start with action verb (Start, Create, Generate, Check, etc.)
- Brief paragraph explaining purpose
- Bulleted feature list using hyphens
- Clear usage example with `/command-name`

**Execution Block:**
- Must use `!bash` directive
- Standard pattern: `cd "$(git rev-parse --show-toplevel)" && ./.claude/commands/script-name.sh "$ARGUMENTS"`
- Use `"$ARGUMENTS"` to pass through all command arguments

## 2. Shell Script (.sh) File Standards

### File Location
```
.claude/commands/script-name.sh
```

### Required Header Format
```bash
#!/bin/bash
# VC-MGR [Purpose] Script
# Usage: ./davinci/scripts/system/script-name.sh [args]
# Last Edit: YYYYMMDD-HHMMSS

set -e  # Exit on any error

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
```

### Header Requirements

**Shebang Line:**
- Must be `#!/bin/bash` (first line, no exceptions)

**Comment Block:**
- Line 2: `# VC-MGR [Purpose] Script` (follow this exact format)
- Line 3: `# Usage: ./.claude/commands/script-name.sh [args]` (exact path)
- Line 4: `# Last Edit: YYYYMMDD-HHMMSS` (timestamp format: 20250811-152800)

**Error Handling:**
- Line 6: `set -e  # Exit on any error` (mandatory for all scripts)

**Project Root:**
- Line 8: `PROJECT_ROOT="$(git rev-parse --show-toplevel)"` (use git for reliability)
- Line 9: `cd "$PROJECT_ROOT"  # Ensure we're in project root` (mandatory)

### Initialization Standards

**Directory Navigation:**
```bash
cd "$PROJECT_ROOT"
```

**Logging Pattern:**
```bash
echo "🚀 [Purpose Description]..."
echo "Time: $(date)"
echo "Location: $(pwd)"
echo
```

### Help Function Standard
```bash
# Help function
show_help() {
    echo "Usage: $0 [options]"
    echo
    echo "Brief description of what the script does."
    echo
    echo "Features:"
    echo "  - Feature 1"
    echo "  - Feature 2"
    echo
    echo "Options:"
    echo "  -h, --help    Show this help message"
}

# Parse arguments
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    show_help
    exit 0
fi
```

### Code Organization Standards

**Variable Naming:**
- Use UPPERCASE for configuration/environment variables
- Use lowercase for local variables
- Use descriptive names (e.g., `CURRENT_DATE`, `workflow_dir`)

**Section Headers:**
```bash
# 1. SECTION NAME
echo ""
echo "🔧 === SECTION DESCRIPTION ==="
```

**Status Reporting:**
```bash
echo -n "🔍 Task description: "
if condition; then
    echo "✅ Success message"
    STATUS_VAR="✅"
else
    echo "❌ Failure message"
    STATUS_VAR="❌"
fi
```

**Exit Codes:**
- 0 for success
- 1 for general errors
- Specific codes for specific error types

## 3. Registration and Naming Standards

### Naming Convention

**Command Names:**
- Use kebab-case: `system-start`, `new-workflow`, `check-dot-claude`
- Start with purpose/category when logical
- Keep under 20 characters
- Use descriptive action verbs

**File Naming:**
- Command file: `command-name.md` (matches slash command)
- Script file: `command-name.sh` (matches command file)
- Slash command: `/command-name` (no prefixes like `/project:`)

### Directory Structure
```
.claude/commands/           # Slash command definitions
├── system-start.md
├── system-backup.md
├── new-workflow.md
└── STANDARDS.md           # This file

davinci/scripts/system/     # Script implementations  
├── system-start.sh
├── system-backup.sh
├── new-workflow.sh
└── modules/               # Shared functions
```

### Registration Process

1. **Automatic Discovery** - Claude Code automatically discovers `.md` files in `.claude/commands/`
2. **No Configuration Required** - No need to register commands in settings files
3. **Immediate Availability** - Commands available as soon as `.md` file is created

## 4. Quality Checklist

### Before Creating New Command

- [ ] **Unique Name** - Command name not already in use
- [ ] **Clear Purpose** - Single, well-defined responsibility
- [ ] **Follows Patterns** - Matches existing command structure

### .md File Checklist

- [ ] **YAML Valid** - Required fields present and correctly formatted
- [ ] **Description Clear** - Single line, action-oriented description
- [ ] **Tools Specified** - All required tools listed in allowed-tools
- [ ] **Usage Documented** - Clear `/command-name` usage example
- [ ] **Execution Pattern** - Standard `cd git-root && ./script.sh` pattern

### .sh File Checklist

- [ ] **Header Complete** - All required header elements present
- [ ] **Executable** - File has execute permissions (`chmod +x`)
- [ ] **Error Handling** - `set -e` and proper exit codes
- [ ] **PROJECT_ROOT** - Standard project root detection
- [ ] **Help Function** - `-h, --help` support implemented
- [ ] **Logging** - Time, location, and progress logging
- [ ] **Status Reporting** - Clear success/failure indicators

### Integration Checklist

- [ ] **Files Match** - .md and .sh file names correspond
- [ ] **Path Correct** - .md file references correct .sh script
- [ ] **Arguments Pass** - `"$ARGUMENTS"` properly forwarded
- [ ] **Testing** - Command works via slash command invocation
- [ ] **Standards Compliance** - Follows all documented patterns

## 5. Reference Implementations

### Recommended Examples

**Simple Command:**
- `system-start.md/.sh` - Full-featured system management
- Demonstrates: complex validation, status reporting, comprehensive logging

**Interactive Command:**
- `new-workflow.md/.sh` - User input collection and validation
- Demonstrates: parameter validation, directory creation, git operations

**Utility Command:**
- `system-backup.md/.sh` - File operations and data handling
- Demonstrates: argument processing, conditional logic, error recovery

### Pattern Evolution

These standards were discovered by analyzing existing implementations:

1. **Header Format** - Extracted from `system-start.sh`, `system-backup.sh`
2. **YAML Structure** - Analyzed across all `.claude/commands/*.md` files
3. **Execution Pattern** - Common pattern in all command files
4. **Error Handling** - Consistent `set -e` usage across scripts
5. **Logging Pattern** - Time/location logging in system scripts

## 6. Troubleshooting

### Common Issues

**Command Not Found:**
- Check `.md` file exists in `.claude/commands/`
- Verify YAML frontmatter syntax
- Ensure `allowed-tools` includes script execution

**Script Execution Fails:**
- Verify script file is executable (`chmod +x`)
- Check script path in .md file matches actual location
- Ensure `PROJECT_ROOT` calculation is correct

**Permission Errors:**
- Add required tools to `allowed-tools` in YAML frontmatter
- Check Claude Code settings for tool permissions

**Path Issues:**
- Always use `cd "$(git rev-parse --show-toplevel)/davinci/scripts/system"`
- Use `PROJECT_ROOT` pattern for cross-platform compatibility

### Validation Commands

**Test Script Directly:**
```bash
cd davinci/scripts/system && ./script-name.sh -h
```

**Test Slash Command:**
```
/command-name
```

**Check File Permissions:**
```bash
ls -la davinci/scripts/system/script-name.sh
```

## 7. Maintenance

### Updating Standards

When modifying these standards:

1. **Update This Document** - Modify STANDARDS.md with changes
2. **Update Reference Implementations** - Ensure examples still comply
3. **Version Existing Commands** - Gradually migrate non-compliant commands
4. **Test Integration** - Verify all commands still work after changes

### Adding New Patterns

When discovering new patterns:

1. **Document Here First** - Add to appropriate section
2. **Update Examples** - Create or modify reference implementations  
3. **Test Thoroughly** - Ensure pattern works across different scenarios
4. **Communicate Changes** - Update team on new standards

---

**Note:** These standards ensure consistency, maintainability, and reliability across all VC-MGR slash commands. All new commands must comply with these standards, and existing commands should be gradually migrated to full compliance.