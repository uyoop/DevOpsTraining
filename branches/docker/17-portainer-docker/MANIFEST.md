# TP17 - Portainer Basic - Project Manifest

## Overview

**TP17** is a lightweight Portainer Community Edition setup for managing Docker containers via a web interface.

## Services

| Service | Image | Port | Volume |
|---------|-------|------|--------|
| portainer | portainer/portainer-ce:latest | 8000, 9000, 9443 | portainer-data |

## Configuration

### Environment Variables

```env
PORTAINER_ADMIN_PASSWORD=***        # Admin password
PORTAINER_VERSION=latest             # Version
PORTAINER_HOST=localhost             # Hostname
PORTAINER_PORT=9000                  # HTTP port
PORTAINER_HTTPS_PORT=9443            # HTTPS port
```

## File Structure

```
17-portainer-docker/
├── docker-compose.yml
├── .env.example
├── .gitignore
├── README.md
├── COMMANDS.md
└── MANIFEST.md
```

## Features

✅ Container management (list, create, stop, delete)
✅ Image management (pull, push, delete)
✅ Volume management (create, delete, browse)
✅ Network management (create, connect, delete)
✅ Stack deployment (Docker Compose)
✅ User management (Admin, Editor, Viewer roles)
✅ Real-time monitoring and logs
✅ Docker Swarm support
✅ Kubernetes integration (advanced)

## Access Points

- **HTTP**: http://localhost:9000
- **HTTPS**: https://localhost:9443
- **Edge Agent**: Port 8000

## Volumes

- `portainer-data`: Persistent configuration and database

## Default Credentials

- **Username**: admin
- **Password**: [From PORTAINER_ADMIN_PASSWORD]

## System Requirements

- Docker 20.10+
- 512 MB RAM minimum
- 100 MB storage

---

**TP17 - Status**: ✅ Complete
**Created**: 2025-12-07
