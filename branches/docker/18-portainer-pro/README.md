# TP18 - Portainer Enterprise Setup

## Overview

**TP18** is a production-ready Portainer Enterprise Edition setup with advanced features for enterprise Docker management.

### Features

✅ **Enterprise Features**
- Portainer Business Edition (EE)
- PostgreSQL database backend
- Teams and RBAC
- Advanced authentication
- GitOps integration
- Edge agents for remote management

✅ **High Availability**
- PostgreSQL database
- Health checks on all services
- Automatic service restart
- Data persistence

✅ **Monitoring & Observability**
- Prometheus metrics
- Grafana dashboards
- Real-time monitoring
- Performance tracking

✅ **Networking & Security**
- Traefik v3 reverse proxy
- Automatic SSL/TLS
- Network isolation
- Secure communication

✅ **Multi-Environment**
- Manage multiple Docker hosts
- Remote host connections
- Portainer agents
- Centralized dashboard

---

## Quick Start

### 1. Configure

```bash
cd 18-portainer-pro
cp .env.example .env
nano .env
```

### 2. Deploy

```bash
chmod +x scripts/*.sh
./scripts/deploy.sh
```

### 3. Access

- **URL**: https://portainer.example.com
- **Admin**: admin
- **Password**: [From PORTAINER_ADMIN_PASSWORD]

---

## Key Features

### Container Management
- Create, start, stop, delete containers
- Real-time resource monitoring
- Log viewing and streaming
- Exec into containers
- Volume management
- Network configuration

### Image Management
- Pull/push images
- Image registry integration
- Image cleanup
- Layer inspection

### Stack Management
- Deploy Docker Compose files
- GitOps deployment
- Stack updates
- Version control

### Environment Management
- Add remote Docker hosts
- Kubernetes cluster integration
- Edge agent management
- Multi-environment dashboard

### Teams & RBAC
- User management
- Team creation
- Role-based access control
- Fine-grained permissions

### Monitoring
- Prometheus metrics
- Grafana dashboards
- Container statistics
- Resource utilization

---

## Database

PostgreSQL is used for data persistence:

```env
POSTGRES_DATABASE=portainer
POSTGRES_USER=portainer
POSTGRES_PASSWORD=***
```

Backup before updates!

---

## Monitoring Dashboards

Access via:
- **Grafana**: https://grafana.portainer.example.com
- **Prometheus**: https://prometheus.portainer.example.com

---

## Remote Host Management

### Add Remote Environment

1. Go to Environments > Add environment
2. Select Docker or Kubernetes
3. Enter host details
4. Click Create
5. Manage from centralized dashboard

### Using Portainer Agent

Deploy agent on remote host:

```bash
docker run -d \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /var/lib/docker/volumes:/var/lib/docker/volumes \
  -p 9001:9001 \
  portainer/agent:latest
```

---

## Backup & Restore

### Backup

```bash
./scripts/backup.sh

# Custom name
./scripts/backup.sh my-backup-20241207
```

### Restore

```bash
# Stop services
docker-compose down

# Copy backup data
cp -r backups/my-backup-*/portainer-data /path/to/restore

# Restore PostgreSQL
gunzip -c backups/my-backup-*/postgres-dump.sql.gz | \
  docker-compose exec -T postgres psql -U portainer portainer

# Restart
docker-compose up -d
```

---

## Security Best Practices

- Change default admin password immediately
- Enable authentication
- Use HTTPS only
- Configure LDAP/OIDC
- Restrict network access
- Regularly backup data
- Update images regularly
- Use RBAC for teams

---

## Troubleshooting

```bash
# View logs
docker-compose logs -f portainer

# Check health
docker-compose ps

# Check database
docker-compose exec postgres psql -U portainer -d portainer

# Restart
docker-compose restart portainer
```

---

## Common Tasks

### Deploy a Stack

1. Stacks > Add stack
2. Upload docker-compose.yml
3. Configure variables
4. Deploy

### Create User

1. Settings > Users
2. Add user
3. Set role (Admin, Editor, Viewer)
4. Configure team access

### Manage Volumes

1. Volumes
2. Create, inspect, delete volumes
3. View usage

### Setup GitOps

1. Settings > GitOps
2. Configure Git provider
3. Link repositories
4. Auto-deploy on push

---

**Status**: ✅ Production-Ready
**Version**: TP18 v1.0
**Last Updated**: 2025-12-07
