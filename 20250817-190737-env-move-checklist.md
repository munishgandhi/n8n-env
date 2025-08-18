# n8n Environment Migration Checklist
**Migration Date:** 2025-08-17  
**Migration Time:** 19:07:37

## Phase 1: Docker Infrastructure Files

### 1.1 Docker Compose and Extensions
- [x] `/home/mg/src/vc-mgr/docker-compose.yml` → `/home/mg/src/n8n-env/docker/docker-compose.yml` | Completion: 2025-08-17 21:40:47 ✅ VERIFIED
- [x] `/home/mg/src/vc-mgr/n8n-extensions/Dockerfile` → `/home/mg/src/n8n-env/docker/n8n-extensions/Dockerfile` | Completion: 2025-08-17 21:40:47 ✅ VERIFIED
- [x] `/home/mg/src/vc-mgr/n8n-extensions/README.md` → `/home/mg/src/n8n-env/docker/n8n-extensions/README.md` | Completion: 2025-08-17 21:40:47 ✅ VERIFIED
- [x] `/home/mg/src/vc-mgr/n8n-extensions/build-extensions.sh` → `/home/mg/src/n8n-env/docker/n8n-extensions/build-extensions.sh` | Completion: 2025-08-17 21:40:47 ✅ VERIFIED
- [x] `/home/mg/src/vc-mgr/n8n-extensions/package.json` → `/home/mg/src/n8n-env/docker/n8n-extensions/package.json` | Completion: 2025-08-17 21:40:47 ✅ VERIFIED
- [x] `/home/mg/src/vc-mgr/n8n-extensions/package-lock.json` → `/home/mg/src/n8n-env/docker/n8n-extensions/package-lock.json` | Completion: 2025-08-17 21:40:47 ✅ VERIFIED
- [x] `/home/mg/src/vc-mgr/n8n-extensions/tsconfig.json` → `/home/mg/src/n8n-env/docker/n8n-extensions/tsconfig.json` | Completion: 2025-08-17 21:40:47 ✅ VERIFIED
- [x] `/home/mg/src/vc-mgr/n8n-extensions/eslint.config.js` → `/home/mg/src/n8n-env/docker/n8n-extensions/eslint.config.js` | Completion: 2025-08-17 21:40:47 ✅ VERIFIED
- [x] `/home/mg/src/vc-mgr/n8n-extensions/docker-compose.yml` → `/home/mg/src/n8n-env/docker/n8n-extensions/docker-compose.yml` | Completion: 2025-08-17 21:40:47 ✅ VERIFIED

### 1.2 Extension Source Files
- [x] `/home/mg/src/vc-mgr/n8n-extensions/nodes/YouTubeTranscript/HylyYouTubeNode.node.ts` → `/home/mg/src/n8n-env/docker/n8n-extensions/nodes/YouTubeTranscript/HylyYouTubeNode.node.ts` | Completion: 2025-08-17 21:40:47 ✅ VERIFIED
- [x] `/home/mg/src/vc-mgr/n8n-extensions/nodes/YouTubeTranscript/youtube.svg` → `/home/mg/src/n8n-env/docker/n8n-extensions/nodes/YouTubeTranscript/youtube.svg` | Completion: 2025-08-17 21:40:47 ✅ VERIFIED
- [x] `/home/mg/src/vc-mgr/n8n-extensions/dist/HylyYouTubeNode.node.js` → `/home/mg/src/n8n-env/docker/n8n-extensions/dist/HylyYouTubeNode.node.js` | Completion: 2025-08-17 21:40:47 ✅ VERIFIED
- [x] `/home/mg/src/vc-mgr/n8n-extensions/dist/HylyYouTubeNode.node.d.ts` → `/home/mg/src/n8n-env/docker/n8n-extensions/dist/HylyYouTubeNode.node.d.ts` | Completion: 2025-08-17 21:40:47 ✅ VERIFIED
- [x] `/home/mg/src/vc-mgr/n8n-extensions/dist/YouTubeTranscript.node.js` → `/home/mg/src/n8n-env/docker/n8n-extensions/dist/YouTubeTranscript.node.js` | Completion: 2025-08-17 21:40:47 ✅ VERIFIED
- [x] `/home/mg/src/vc-mgr/n8n-extensions/dist/YouTubeTranscript.node.d.ts` → `/home/mg/src/n8n-env/docker/n8n-extensions/dist/YouTubeTranscript.node.d.ts` | Completion: 2025-08-17 21:40:47 ✅ VERIFIED

## Phase 2: Claude Commands (System Management)

### 2.1 Main System Commands
- [x] `/home/mg/src/vc-mgr/.claude/commands/system-start.sh` → `/home/mg/src/n8n-env/.claude/commands/system-start.sh` | Completion: 2025-08-17 21:40:47 ✅ VERIFIED
- [x] `/home/mg/src/vc-mgr/.claude/commands/system-start.md` → `/home/mg/src/n8n-env/.claude/commands/system-start.md` | Completion: 2025-08-17 21:40:47 ✅ VERIFIED
- [x] `/home/mg/src/vc-mgr/.claude/commands/system-stop.sh` → `/home/mg/src/n8n-env/.claude/commands/system-stop.sh` | Completion: 2025-08-17 21:40:47 ✅ VERIFIED
- [x] `/home/mg/src/vc-mgr/.claude/commands/system-stop.md` → `/home/mg/src/n8n-env/.claude/commands/system-stop.md` | Completion: 2025-08-17 21:40:47 ✅ VERIFIED
- [x] `/home/mg/src/vc-mgr/.claude/commands/system-checks.sh` → `/home/mg/src/n8n-env/.claude/commands/system-checks.sh` | Completion: 2025-08-17 21:40:47 ✅ VERIFIED
- [x] `/home/mg/src/vc-mgr/.claude/commands/system-checks.md` → `/home/mg/src/n8n-env/.claude/commands/system-checks.md` | Completion: 2025-08-17 21:40:47 ✅ VERIFIED
- [x] `/home/mg/src/vc-mgr/.claude/commands/system-backup.sh` → `/home/mg/src/n8n-env/.claude/commands/system-backup.sh` | Completion: 2025-08-17 21:40:47 ✅ VERIFIED
- [x] `/home/mg/src/vc-mgr/.claude/commands/system-backup.md` → `/home/mg/src/n8n-env/.claude/commands/system-backup.md` | Completion: 2025-08-17 21:40:47 ✅ VERIFIED
- [x] `/home/mg/src/vc-mgr/.claude/commands/system-docker-update.sh` → `/home/mg/src/n8n-env/.claude/commands/system-docker-update.sh` | Completion: 2025-08-17 21:40:47 ✅ VERIFIED
- [x] `/home/mg/src/vc-mgr/.claude/commands/system-docker-update.md` → `/home/mg/src/n8n-env/.claude/commands/system-docker-update.md` | Completion: 2025-08-17 21:40:47 ✅ VERIFIED

### 2.2 Module Scripts
- [x] `/home/mg/src/vc-mgr/.claude/commands/modules/shared-functions.sh` → `/home/mg/src/n8n-env/.claude/commands/modules/shared-functions.sh` | Completion: 2025-08-17 21:40:47 ✅ VERIFIED
- [x] `/home/mg/src/vc-mgr/.claude/commands/modules/system-check-docker.sh` → `/home/mg/src/n8n-env/.claude/commands/modules/system-check-docker.sh` | Completion: 2025-08-17 21:40:47 ✅ VERIFIED
- [x] `/home/mg/src/vc-mgr/.claude/commands/modules/system-check-gmail.sh` → **NOT MOVED** - Gmail test removed from n8n-env | Completion: 2025-08-18 ❌ NOT MOVED
- [x] `/home/mg/src/vc-mgr/.claude/commands/modules/system-check-n8n-mcp.sh` → `/home/mg/src/n8n-env/.claude/commands/modules/system-check-n8n-mcp.sh` | Completion: 2025-08-17 21:40:47 ✅ VERIFIED
- [x] `/home/mg/src/vc-mgr/.claude/commands/modules/system-check-n8n-workflow.sh` → `/home/mg/src/n8n-env/.claude/commands/modules/system-check-n8n-workflow.sh` | Completion: 2025-08-17 21:40:47 ✅ VERIFIED
- [x] `/home/mg/src/vc-mgr/.claude/commands/modules/system-check-notion.sh` → **NOT MOVED** - Notion check removed from n8n-env | Completion: 2025-08-18 ❌ NOT MOVED
- [x] `/home/mg/src/vc-mgr/.claude/commands/modules/system-check-ollama.sh` → **NOT MOVED** - Ollama test rewritten for native testing | Completion: 2025-08-18 ❌ NOT MOVED
- [x] `/home/mg/src/vc-mgr/.claude/commands/modules/system-check-sqlite.sh` → `/home/mg/src/n8n-env/.claude/commands/modules/system-check-sqlite.sh` | Completion: 2025-08-17 21:40:47 ✅ VERIFIED

## Phase 3: Environment Configuration

### 3.1 Environment Files (COPY ONLY - DO NOT DELETE FROM vc-mgr)
- [x] `/home/mg/src/vc-mgr/.env` → `/home/mg/src/n8n-env/.env` | Completion: 2025-08-17 21:40:47 ✅ VERIFIED

## Phase 4: Path Updates Required
- [x] Update docker-compose references in system scripts | Completion: 2025-08-17 21:40:47 ✅ VERIFIED
- [x] Update backup paths in system-backup.sh | Completion: 2025-08-17 21:40:47 ✅ VERIFIED
- [x] Verify all script paths are correct | Completion: 2025-08-17 21:40:47 ✅ VERIFIED

## Phase 5: Documentation
- [x] Create `/home/mg/src/n8n-env/README.md` | Completion: 2025-08-17 21:40:47 ✅ VERIFIED
- [x] Create `/home/mg/src/n8n-env/CLAUDE.md` | Completion: 2025-08-17 21:40:47 ✅ VERIFIED
- [x] Create `/home/mg/src/n8n-env/.gitignore` | Completion: 2025-08-17 21:40:47 ✅ VERIFIED

## Phase 6: Post-Migration Tasks (To be done AFTER switching to n8n-env in VS Code)

### 6.1 Initialize Git Repository
- [x] Initialize git repository in n8n-env | Completion: 2025-08-17 20:37:00 ✅ VERIFIED (already existed)
- [x] Add all files to git | Completion: 2025-08-18 ✅ VERIFIED
- [x] Create initial commit | Completion: 2025-08-18 ✅ VERIFIED
- [x] Add remote origin | Completion: 2025-08-18 ✅ VERIFIED (already existed)
- [x] Push to GitHub | Completion: 2025-08-18 ✅ VERIFIED

### 6.2 Verification Steps
- [ ] Test Docker containers from new location: `docker-compose -f docker/docker-compose.yml up -d` | Completion: ___________
- [ ] Test Claude commands work: `./.claude/commands/system-checks.sh` | Completion: ___________
- [ ] Verify backups continue to work | Completion: ___________
- [ ] Test n8n extensions build and load correctly | Completion: ___________

### 6.3 Cleanup from vc-mgr (After Verification)
- [ ] Remove `docker-compose.yml` from vc-mgr | Completion: ___________
- [ ] Remove `n8n-extensions/` directory from vc-mgr | Completion: ___________
- [ ] Remove system-*.sh files from vc-mgr/.claude/commands/ | Completion: ___________
- [ ] Remove system-check-*.sh files from vc-mgr/.claude/commands/modules/ | Completion: ___________
- [x] **KEEP .env file in vc-mgr** (needed for application logic) | ✓ Noted

## Migration Status
- **Started:** 2025-08-17 19:07:37
- **File Migration Completed:** 2025-08-17 21:40:47 ✅ VERIFIED
- **Testing & Verification:** ___________ (To be done after switching to VS Code in n8n-env)
- **Final Cleanup:** ___________ (After testing confirms everything works)
- **Notes:** 
  - Docker containers should remain undisturbed during migration
  - All operations use `cp` (copy) not `mv` (move) to preserve originals
  - .env file remains in BOTH locations