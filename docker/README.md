# Docker Infrastructure - n8n Environment

This directory contains the complete Docker infrastructure for the n8n development environment.

## Core Infrastructure

### docker-compose.yml
**Purpose:** Main orchestration file defining all services and their relationships.

**Services:**
- **n8n** (port 5678) - Main workflow automation platform with custom extensions
- **n8n-mcp** (port 3001) - Model Context Protocol server for API integration  
- **redis** (internal) - Caching and session storage
- **sqlite-web-viewer** (port 8080) - Web-based database browser
- **open-webui** (port 3000) - AI interface with Ollama integration

**Volume Management:**
- Uses external Docker volumes with `vc-mgr_` prefix for data persistence
- Preserves data across container recreations
- Shared volumes for cross-service data access

## Custom Extensions

### n8n-extensions/
**Purpose:** Custom n8n node development and build system.

**Structure:**
- `nodes/YouTubeTranscript/` - Custom YouTube transcript extraction node
- `dist/` - Compiled TypeScript output for n8n integration
- `package.json` - Node dependencies and build scripts
- `tsconfig.json` - TypeScript compilation configuration
- `eslint.config.js` - Code quality and formatting rules

**Development Workflow:**
```bash
cd docker/n8n-extensions
npm install          # Install dependencies  
npm run build        # Compile TypeScript to JavaScript
npm run dev          # Watch mode for development
```

**Custom Nodes:**
- **HylyYouTubeNode** - Extracts transcripts using yt-dlp integration
- Built as n8n community node package
- Automatically loaded by n8n container on startup

## Container Integration

**Extension Loading:**
- Extensions are built into `dist/` directory
- Volume mounted into n8n container at `/home/node/.n8n/custom/`
- Automatically detected by n8n on container restart

**Data Persistence:**
- n8n workflows and configuration stored in `vc-mgr_n8n_data` volume
- Redis data persisted in `vc-mgr_redis_data` volume
- MCP server data in `vc-mgr_n8n_mcp_data` volume
- Open-webui settings in `vc-mgr_open_webui_data` volume

## Network Configuration

**Internal Networking:**
- All services connected via `default` Docker network
- Internal service-to-service communication
- Only necessary ports exposed to host

**Port Mapping:**
- 5678 → n8n web interface
- 3001 → n8n-MCP API server
- 8080 → SQLite web viewer
- 3000 → Open-webui interface
- 6379 → Redis (internal only)

## Security Considerations

**Container Isolation:**
- Services run in isolated Docker network
- Limited port exposure to host system
- Environment variables for sensitive configuration

**Data Protection:**
- Volumes use Docker's built-in security
- No direct file system access from containers
- Environment-based configuration management

## Maintenance

**Updates:**
- Use `/system-docker-update` for safe container updates
- Extensions automatically rebuilt during updates
- Data preservation across updates via persistent volumes

**Troubleshooting:**
- Container logs available via `docker-compose logs [service]`
- Health checks built into critical services
- Service dependency management via Docker Compose