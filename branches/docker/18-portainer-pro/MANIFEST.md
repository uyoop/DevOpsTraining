# TP18 - Portainer Enterprise - Project Manifest

## Overview

**TP18** is a production-ready Portainer Enterprise Edition setup with advanced features.

## Services

| Service | Image | Port | Volume | Purpose |
|---------|-------|------|--------|---------|
| portainer | portainer/portainer-ee:latest | 9000, 9443, 8000 | portainer-data | Container management |
| postgres | postgres:15-alpine | 5432 | postgres-data | Database backend |
| prometheus | prom/prometheus:latest | 9090 | prometheus-data | Metrics collection |
| grafana | grafana/grafana:latest | 3000 | grafana-data | Visualization |
| traefik | traefik:v3.1 | 80, 443 | acme.json | Reverse proxy |
| portainer-agent | portainer/agent:latest | 9001 | portainer-agent-data | Remote management |

## Configuration

### Environment Variables

```env
PORTAINER_HOSTNAME=portainer.example.com
PORTAINER_ADMIN_PASSWORD=***
POSTGRES_PASSWORD=***
GRAFANA_ADMIN_PASSWORD=***
CERT_EMAIL=admin@example.com
ACME_SERVER=https://acme-v02.api.letsencrypt.org/directory
```

## File Structure

```
18-portainer-pro/
├── docker-compose.yml
├── .env.example
├── .gitignore
├── README.md
├── COMMANDS.md
├── MANIFEST.md
├── config/portainer/
├── prometheus/
│   └── prometheus.yml
├── grafana/provisioning/
│   ├── datasources/
│   └── dashboards/
├── traefik/
│   └── config.yml
└── scripts/
    ├── deploy.sh
    └── backup.sh
```

## Features

✅ Portainer Business Edition (EE)
✅ PostgreSQL persistence
✅ Teams & RBAC
✅ Multi-environment management
✅ Portainer agents
✅ GitOps integration
✅ Prometheus metrics
✅ Grafana dashboards
✅ Traefik SSL/TLS
✅ Automated backups

## Networks

- `portainer-network`: Public services (Portainer, Prometheus, Grafana, Traefik)
- `portainer-internal`: Database (PostgreSQL)

## Volumes

- `portainer-data`: Portainer configuration and settings
- `portainer-agent-data`: Agent state
- `postgres-data`: PostgreSQL database
- `prometheus-data`: Time series metrics
- `grafana-data`: Dashboards and settings

## Access Points

- **Portainer**: https://portainer.example.com (ports 9000, 9443, 8000)
- **Grafana**: https://grafana.portainer.example.com (port 3000)
- **Prometheus**: https://prometheus.portainer.example.com (port 9090)
- **Traefik Dashboard**: https://traefik.example.com (port 8080)

## Default Credentials

- **Portainer Admin**: admin / [PORTAINER_ADMIN_PASSWORD]
- **PostgreSQL**: portainer / [POSTGRES_PASSWORD]
- **Grafana Admin**: admin / [GRAFANA_ADMIN_PASSWORD]

## System Requirements

- Docker 20.10+
- Docker Compose 2.0+
- 2+ CPU cores
- 2+ GB RAM
- 50+ GB storage
- Public domain for HTTPS

## Supported Environments

- Docker standalone
- Docker Swarm
- Kubernetes
- Multiple remote hosts

## Backup Strategy

- Portainer database (PostgreSQL)
- Configuration files
- Daily automated backups
- 30-day retention

---

**TP18 - Status**: ✅ Production-Ready
**Created**: 2025-12-07
**Version**: 1.0
