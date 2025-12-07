# TP17 - Portainer Basic Setup

## Overview

**TP17** is a basic, simple Portainer Community Edition setup for Docker container management via web interface.

### What is Portainer?

[Portainer](https://www.portainer.io/) is a lightweight, open-source management UI that allows you to easily manage your Docker environments (hosts or Swarm clusters).

### Features

✅ **Container Management**
- View running containers
- Start/stop/restart containers
- Create new containers from images
- Delete containers
- View container logs

✅ **Image Management**
- Pull images from registries
- Push images
- Delete images
- View image details

✅ **Volume Management**
- Create/delete volumes
- View volume details
- Manage volume mounts

✅ **Network Management**
- Create/delete networks
- View network details
- Connect containers to networks

✅ **Stack Management** (Docker Compose)
- Deploy stacks from compose files
- Manage running stacks
- View stack logs

---

## Quick Start

### 1. Configure

```bash
cd 17-portainer-docker
cp .env.example .env
```

### 2. Deploy

```bash
docker-compose up -d
```

### 3. Access

- **URL**: http://localhost:9000
- **Port HTTP**: 8000
- **Port HTTPS**: 9443

### 4. Initial Setup

1. Set admin password on first login
2. Connect to local Docker environment
3. Start managing containers

---

## Accessing Portainer

```bash
# Access via HTTP
http://localhost:9000

# Or via HTTPS
https://localhost:9443

# Default credentials (first login):
Username: admin
Password: [From PORTAINER_ADMIN_PASSWORD in .env]
```

---

## Service Management

```bash
# View status
docker-compose ps

# View logs
docker-compose logs -f portainer

# Stop
docker-compose down

# Restart
docker-compose restart portainer
```

---

## Features & Usage

### Containers
- List all containers
- View real-time stats
- Access container logs
- Execute commands in containers
- Inspect container details

### Images
- Browse available images
- Pull images from Docker Hub
- Delete unused images
- View image details and layers

### Volumes
- Create persistent volumes
- List volumes
- Delete volumes
- Browse volume contents

### Networks
- Create custom networks
- List networks
- Delete networks
- Connect containers

### Stacks
- Deploy Docker Compose files
- Manage multi-container apps
- View stack status
- Edit stack configurations

---

## User Management

### Create Users

Via Portainer UI:
1. Admin > Users
2. Click "Add user"
3. Set credentials and role:
   - **Admin**: Full permissions
   - **Editor**: Container management only
   - **Viewer**: Read-only access

---

## Backup & Restore

### Backup Portainer Data

```bash
# Copy volume data
docker cp portainer:/data ./portainer-backup-$(date +%Y%m%d)

# Or use volume backup
docker run --rm -v portainer-data:/data -v $(pwd):/backup \
  alpine tar czf /backup/portainer-backup-$(date +%Y%m%d).tar.gz -C /data .
```

### Restore

```bash
docker-compose down
docker volume rm portainer-data
docker volume create portainer-data

docker run --rm -v portainer-data:/data -v $(pwd):/backup \
  alpine tar xzf /backup/portainer-backup-YYYYMMDD.tar.gz -C /data

docker-compose up -d
```

---

## Troubleshooting

### Port Already in Use

```bash
# Check what's using port 9000
lsof -i :9000

# Kill process
kill -9 <PID>

# Or change port in docker-compose.yml
```

### Cannot Connect to Docker

```bash
# Check Docker socket permission
ls -l /var/run/docker.sock

# Add current user to docker group
sudo usermod -aG docker $USER
```

### Logs

```bash
# View portainer logs
docker-compose logs portainer

# Follow logs
docker-compose logs -f portainer
```

---

## Common Tasks

### Deploy a Container

1. Open Portainer (http://localhost:9000)
2. Select "Containers" > "Create container"
3. Choose image and configure
4. Click "Deploy"

### Manage Multiple Hosts

1. Add environments in "Environments"
2. Connect to remote Docker hosts
3. Manage all from one dashboard

### Deploy Stack

1. "Stacks" > "Add stack"
2. Paste docker-compose.yml content
3. Configure and deploy

---

## Security Notes

- Change default admin password immediately
- Restrict network access to trusted IPs
- Use HTTPS in production
- Enable authentication
- Regularly backup data

---

**Status**: ✅ Complete and Ready
**Version**: TP17 v1.0
**Last Updated**: 2025-12-07
