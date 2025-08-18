# Claude Agents - n8n Environment

This directory contains specialized Claude agents for automated development tasks.

## Available Agents

### git-90-track-commit-sync
**Purpose:** Intelligent git repository management with automated commit message generation.

**What it does:**
- Analyzes all uncommitted changes in the repository
- Generates meaningful commit messages following conventional commit standards
- Creates commits with proper formatting and co-authorship attribution
- Synchronizes changes to remote repository
- Provides detailed reports of what was changed and why

**Usage:** 
- Invoked automatically by Claude when asked to commit changes
- Can be called directly via the Task tool with subagent_type: "git-90-track-commit-sync"

**Files:**
- `git-90-track-commit-sync.md` - Agent definition and capabilities
- `git-90-track-commit-sync.sh` - Core git analysis and commit logic

**Features:**
- Conventional commit message format (feat, fix, refactor, etc.)
- Impact analysis (lines changed, files affected)
- Intelligent categorization of changes
- Co-authored by Claude attribution
- Remote synchronization with error handling

**Example Output:**
```
feat(system-checks): enhance n8n validation with API/SQLite consistency checks

- Add comprehensive API/SQLite cross-validation for data integrity
- Remove duplicate tests and external dependencies (Notion, Gmail)
- Rename modules for better organization and clarity
- Update branding from "VC-MGR" to "n8n Environment"

🤖 Generated with Claude Code
Co-Authored-By: Claude <noreply@anthropic.com>
```