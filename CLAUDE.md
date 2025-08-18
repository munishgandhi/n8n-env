# Claude Code Instructions - n8n Environment

This file contains Claude-specific instructions for managing the n8n environment infrastructure.

## Available System Commands

Claude can discover and run these commands using the slash command interface:

### Core System Management
- **system-start** - Start development environment with containers, health checks, and service validation
- **system-stop** - Stop development environment with graceful shutdown options (--force, --keep-data)
- **system-checks** - Run comprehensive health validation of all services and connectivity
- **system-backup** - Create backup of critical data (workflows, database, environment config)
- **system-docker-update** - Update Docker containers with soft (default) or hard (--hard) rebuild modes

### Usage Examples
```bash
# Start environment
system-start

# Quick restart (preserves containers)
system-start --restart

# Health check all services
system-checks

# Graceful shutdown
system-stop

# Force stop all services
system-stop --force

# Update containers
system-docker-update

# Hard rebuild all containers
system-docker-update --hard

# Backup critical data
system-backup
```

## Environment Structure

### Critical Directories
- `.claude/commands/` - System management scripts (Claude auto-discovery)
- `docker/` - All Docker infrastructure and custom extensions
- `backup/` - Automated workflow backups (organized by date)
- `.env` - Environment configuration (API keys, database IDs)

### Docker Services
- **n8n** (5678) - Main workflow engine with custom YouTube node
- **n8n-mcp** (3001) - MCP server for API integration
- **redis** - Cache and session storage
- **sqlite-web-viewer** (8080) - Database browser
- **open-webui** (3000) - AI interface

## Development Workflow

### n8n Extension Development
1. Edit files in `docker/n8n-extensions/nodes/`
2. Build: `cd docker/n8n-extensions && npm run build`
3. Restart: `docker-compose -f docker/docker-compose.yml restart n8n`

### Infrastructure Changes
1. Edit `docker/docker-compose.yml`
2. Test changes: `system-checks`
3. Apply: `system-docker-update`

## Environment Variables

### Required
```bash
NOTION_API_KEY=ntn_xxx                    # Notion integration token
N8N_API_KEY=eyJxxx                        # n8n API key for external access
```

### Auto-Generated (via vc-mgr)
```bash
# Database IDs
BACKLOG_DB_ID=xxx                         # Notion database IDs
PLANNER_EMAIL_DB_ID=xxx
PLANNER_PERSON_DB_ID=xxx
# ... (additional database IDs)

# API Configuration  
N8N_API_URL=http://localhost:5678         # n8n instance URL
GMAIL_QUERY_FOLDER=in:--Watch/VC          # Gmail folder filter
BATCH_SIZE=25                             # Processing batch size
```

### Service Credentials
```bash
N8N_MCP_AUTH_TOKEN=xxx                    # MCP server authentication
NOTION_CREDENTIAL_ID=xxx                  # n8n Notion credential reference
GMAIL_CREDENTIAL_ID=xxx                   # n8n Gmail credential reference
```

## Backup Strategy

### Automated Backups
- Daily workflow backups in `backup/YYYY/MM/`
- Includes workflow definitions, database, and critical config
- Organized by date for easy retrieval

### Manual Backup
```bash
system-backup                             # Creates timestamped backup
system-backup my-project-milestone        # Custom named backup
```

## Troubleshooting Guide

### Service Issues
```bash
# Comprehensive diagnostics
system-checks

# View service status
docker-compose -f docker/docker-compose.yml ps

# Check specific service logs
docker-compose -f docker/docker-compose.yml logs n8n
docker-compose -f docker/docker-compose.yml logs n8n-mcp
```

### Common Fixes
```bash
# n8n not responding
system-stop && system-start

# Extensions not loading
cd docker/n8n-extensions && npm run build
docker-compose -f docker/docker-compose.yml restart n8n

# Database locked
system-stop --force && system-start

# Container issues
system-docker-update --hard
```

## Integration with vc-mgr

### Repository Separation
- **n8n-env** (this repo): Infrastructure, Docker containers, environment management
- **vc-mgr**: Application workflows, business logic, development tools

### Shared Resources
- Both repos have their own `.env` files
- n8n-env focuses on infrastructure environment variables
- vc-mgr focuses on application-specific variables
- Backup system preserves both environments

## Security Notes

### API Keys
- Never commit `.env` files to git
- Rotate API keys regularly
- Use credential IDs in n8n workflows instead of direct keys

### Container Security
- Services run in isolated Docker network
- Only necessary ports exposed
- Regular container updates via `system-docker-update`

## Performance Monitoring

### Health Checks
- Automated health validation via `system-checks`
- Container resource monitoring
- Service connectivity verification

### Optimization
- Redis caching for improved performance
- SQLite database optimization
- Container resource limits configured

## Development Tips

### Claude Integration
- All system commands are auto-discoverable via Claude
- Use slash commands for quick system management
- Scripts include detailed error handling and logging

### Extension Development
- TypeScript support with hot reloading
- ESLint configuration for code quality
- Build process optimized for n8n integration

### Debugging
- Comprehensive logging in all system scripts
- Docker logs available for all services
- Health check system identifies issues quickly