# n8n Environment Infrastructure

This repository contains the Docker infrastructure and environment management for n8n-based workflow automation systems.

## Directory Structure

```
n8n-env/
├── .claude/
│   └── commands/           # Claude-recognized system commands
│       ├── system-start.sh     # Start all services
│       ├── system-stop.sh      # Stop all services  
│       ├── system-checks.sh    # Health checks
│       ├── system-backup.sh    # Backup critical data
│       ├── system-docker-update.sh  # Update containers
│       └── modules/            # Shared check modules
├── backup/                 # Automated workflow backups
│   └── 2025/
├── docker/                 # Docker infrastructure
│   ├── docker-compose.yml     # Main service definitions
│   └── n8n-extensions/        # Custom n8n nodes
│       ├── Dockerfile
│       ├── nodes/
│       └── dist/
├── .env                    # Environment configuration
└── README.md
```

## Quick Start

### Prerequisites
- Docker Desktop installed and running
- Git installed
- Claude Code (for command discovery)

### Starting Services

```bash
# Start all services (first time or after updates)
./.claude/commands/system-start.sh

# Restart services (faster, preserves containers)
./.claude/commands/system-start.sh --restart
```

### Stopping Services

```bash
# Graceful shutdown (recommended)
./.claude/commands/system-stop.sh

# Force stop (faster)
./.claude/commands/system-stop.sh --force

# Stop but keep containers (preserves data)
./.claude/commands/system-stop.sh --keep-data
```

### Health Checks

```bash
# Run comprehensive system checks
./.claude/commands/system-checks.sh
```

## Services

The environment includes:

- **n8n** (localhost:5678) - Workflow automation engine with custom YouTube transcript node
- **n8n-mcp** (localhost:3001) - MCP server for n8n API integration
- **Redis** - Cache and session storage
- **SQLite Web Viewer** (localhost:8080) - Database browser
- **Open WebUI** (localhost:3000) - AI interface connected to Ollama

## Custom n8n Extensions

### YouTube Transcript Node
Custom node for extracting YouTube video transcripts using yt-dlp.

**Location:** `docker/n8n-extensions/nodes/YouTubeTranscript/`

**Features:**
- Extract audio from YouTube videos
- Generate transcripts with timestamps
- Integration with n8n workflow engine

**Building Extensions:**
```bash
cd docker/n8n-extensions
npm run build
```

## Environment Configuration

Copy `.env.example` to `.env` and configure:

```bash
# Required
NOTION_API_KEY=your_notion_token
N8N_API_KEY=your_n8n_api_key

# Optional (have defaults)
N8N_API_URL=http://localhost:5678
N8N_MCP_AUTH_TOKEN=your_mcp_token
```

## Backup & Restore

### Automated Backups
Workflows are automatically backed up daily to `backup/YYYY/MM/` directory.

### Manual Backup
```bash
# Backup critical data only
./.claude/commands/system-backup.sh

# Backup with custom name
./.claude/commands/system-backup.sh my-backup-name
```

**Backup Contents:**
- n8n workflow definitions
- SQLite database
- Environment configuration
- Container volumes

## Docker Management

### Update Containers
```bash
# Soft update (pull and restart)
./.claude/commands/system-docker-update.sh

# Hard update (rebuild and recreate)
./.claude/commands/system-docker-update.sh --hard
```

### Manual Docker Operations
```bash
# View services
docker-compose -f docker/docker-compose.yml ps

# View logs
docker-compose -f docker/docker-compose.yml logs n8n

# Rebuild specific service
docker-compose -f docker/docker-compose.yml build n8n
```

## Development

### n8n Extension Development
1. Edit source files in `docker/n8n-extensions/nodes/`
2. Build: `cd docker/n8n-extensions && npm run build`
3. Restart n8n: `docker-compose -f docker/docker-compose.yml restart n8n`

### Adding New Services
1. Edit `docker/docker-compose.yml`
2. Update system scripts if needed
3. Test with `system-checks.sh`

## Troubleshooting

### Common Issues

**n8n not accessible:**
```bash
# Check if running
docker-compose -f docker/docker-compose.yml ps

# Check logs
docker-compose -f docker/docker-compose.yml logs n8n
```

**Extension not loading:**
```bash
# Rebuild extensions
cd docker/n8n-extensions && npm run build

# Restart n8n
docker-compose -f docker/docker-compose.yml restart n8n
```

**Database locked:**
```bash
# Stop all services
./.claude/commands/system-stop.sh

# Start services
./.claude/commands/system-start.sh
```

### System Health
Run comprehensive diagnostics:
```bash
./.claude/commands/system-checks.sh
```

## Related Repositories

- **vc-mgr** - Application workflows and business logic
- **n8n-env** - Infrastructure and environment management (this repo)

## Support

For issues:
1. Run `system-checks.sh` for diagnostics
2. Check container logs
3. Review backup data if needed
4. Restart services with `system-start.sh --restart`