# TP16 - Harbor Production-Ready Setup

## Overview

**TP16** is a comprehensive, production-ready Harbor (container registry) deployment with advanced features for enterprise environments.

### What is Harbor?

[Harbor](https://goharbor.io/) is an open-source cloud native registry that stores, signs, and scans container images for vulnerabilities. It extends the Docker Registry with features required by enterprise users.

### TP16 Features

✅ **Reverse Proxy & Load Balancing**
- Traefik v3 with automatic SSL/TLS via Let's Encrypt
- HTTP to HTTPS redirection
- Rate limiting and compression middleware

✅ **High Availability**
- PostgreSQL with streaming replication (1 primary + 2 replicas)
- Redis Sentinel with automatic failover (1 master + 2 replicas + 3 sentinels)
- Health checks on all critical services

✅ **Monitoring & Observability**
- Prometheus for metrics collection
- Grafana for visualization and dashboarding
- Loki for log aggregation
- AlertManager for alert routing and notifications
- Promtail for log shipping

✅ **Security**
- Trivy security scanner for vulnerability scanning
- Notary for image signing and verification (optional)
- LDAP/OIDC integration support
- Custom CA certificate support
- TLS 1.2+ enforcement

✅ **Backup & Disaster Recovery**
- Automated backup scripts for data, database, and configs
- Restore scripts for quick recovery
- Retention policy management

✅ **Container Orchestration**
- Docker Compose v3.9 for easy deployment
- Service health checks and automatic restart
- Resource limits and reservations
- Network isolation

---

## Architecture

```
                          Internet
                              |
                    ┌─────────▼─────────┐
                    │    Traefik v3     │
                    │  (SSL/TLS, LB)    │
                    └────────┬──────────┘
                             |
              ┌──────────────┼──────────────┐
              |              |              |
         ┌────▼───┐   ┌─────▼────┐   ┌───▼────┐
         │ Harbor │   │ Grafana  │   │Alerts  │
         │  Core  │   │  Dashboard   │Manager │
         └────┬───┘   └────┬─────┘   └───┬────┘
              |            |             |
              └────────────┼─────────────┘
                           |
            ┌──────────────┼──────────────┐
            |              |              |
        ┌───▼────┐    ┌───▼────┐    ┌──▼──────┐
        │Postgres│    │ Redis  │    │Trivy    │
        │  HA    │    │Sentinel│    │Security │
        └────────┘    └────────┘    └─────────┘
        
        Monitoring Stack:
        Prometheus → Loki → Promtail → AlertManager
```

---

## Prerequisites

### System Requirements

- **OS**: Linux (Ubuntu 20.04+, CentOS 8+, Debian 11+)
- **CPU**: 4 cores minimum (8 recommended for production)
- **RAM**: 8 GB minimum (16+ GB recommended for production)
- **Storage**: 50 GB minimum (more depending on image volume)
- **Docker**: 20.10+
- **Docker Compose**: 2.0+

### Network Requirements

- Public domain with DNS A record pointing to your server
- Port 80 (HTTP) open for ACME challenge
- Port 443 (HTTPS) open for Harbor access
- Port 8080 (Traefik Dashboard) accessible from admin network only

### External Services (Optional)

- LDAP/Active Directory for authentication
- OIDC provider (e.g., Keycloak, Okta)
- S3-compatible storage for registry backend
- SMTP server for email notifications
- Slack workspace for alerting

---

## Quick Start

### 1. Clone and Configure

```bash
cd /path/to/16-harbor-pro
cp .env.example .env
```

### 2. Edit Configuration

Edit `.env` with your settings:

```bash
# Essential settings
HARBOR_HOSTNAME=harbor.example.com
HARBOR_ADMIN_PASSWORD=YourSecurePassword123!
CERT_EMAIL=admin@example.com
TRAEFIK_DASHBOARD_PASSWORD=$(openssl passwd -apr1)
```

### 3. Make Scripts Executable

```bash
chmod +x scripts/*.sh
```

### 4. Deploy

```bash
./scripts/deploy.sh
```

### 5. Verify

```bash
docker-compose ps
docker-compose logs -f harbor
```

### 6. Access Harbor

- **URL**: https://harbor.example.com
- **Username**: admin
- **Password**: [From HARBOR_ADMIN_PASSWORD in .env]

---

## Configuration Guide

### Harbor Core

| Variable | Description |
|----------|-------------|
| `HARBOR_HOSTNAME` | Fully qualified domain name for Harbor |
| `HARBOR_ADMIN_PASSWORD` | Initial admin password (change after first login) |
| `HARBOR_VERSION` | Harbor version (e.g., v2.9.1) |

### Database (PostgreSQL)

| Variable | Description |
|----------|-------------|
| `POSTGRES_PASSWORD` | Superuser password |
| `POSTGRES_USER_PASSWORD` | Harbor database user password |
| `POSTGRES_REPLICATION_PASSWORD` | Replication user password |

### Cache (Redis)

| Variable | Description |
|----------|-------------|
| `REDIS_PASSWORD` | Redis master password |
| `REDIS_SENTINEL_PASSWORD` | Sentinel password |

### SSL/TLS

| Variable | Description |
|----------|-------------|
| `CERT_EMAIL` | Email for Let's Encrypt notifications |
| `ACME_SERVER` | ACME server URL (production or staging) |

### S3 Backend (Optional)

Set `S3_ENABLED=true` and configure:

```env
S3_ENDPOINT=s3.amazonaws.com
S3_REGION=us-east-1
S3_BUCKET=harbor-registry
S3_ACCESS_KEY=YOUR_ACCESS_KEY
S3_SECRET_KEY=YOUR_SECRET_KEY
```

### LDAP Integration (Optional)

Set `LDAP_ENABLED=true` and configure:

```env
LDAP_URL=ldap://ldap.example.com:389
LDAP_BASE_DN=dc=example,dc=com
```

Then configure in Harbor UI: Administration → Configuration → Authentication

### OIDC Integration (Optional)

Set `OIDC_ENABLED=true` and configure:

```env
OIDC_ENDPOINT=https://oidc.example.com
OIDC_CLIENT_ID=harbor-app
OIDC_CLIENT_SECRET=YOUR_SECRET
```

---

## Service Management

### View Service Status

```bash
docker-compose ps
```

### View Logs

```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f harbor
docker-compose logs -f postgres-primary
docker-compose logs -f prometheus
```

### Stop Services

```bash
docker-compose down
```

### Restart Services

```bash
# All services
docker-compose restart

# Specific service
docker-compose restart harbor
```

### Update Docker Images

```bash
docker-compose pull
docker-compose up -d
```

---

## Backup & Restore

### Automated Backup

```bash
# Run backup
./scripts/backup.sh

# Backup with custom name
./scripts/backup.sh my-backup-20241207
```

Backups are stored in `./backups/` directory with retention policy (default: 30 days).

Backup includes:
- Harbor data and configurations
- PostgreSQL database dump
- Redis snapshot
- Configuration files

### Restore from Backup

```bash
# List available backups
ls -la backups/

# Restore specific backup
./scripts/restore.sh harbor-backup-20241207-143022
```

### Manual Backup

```bash
# Backup PostgreSQL
docker-compose exec postgres-primary pg_dump -U harbor harbor | gzip > harbor.sql.gz

# Backup Redis
docker-compose exec redis-master redis-cli BGSAVE
docker cp redis-master:/data/dump.rdb redis-dump.rdb

# Backup Harbor data
docker-compose exec harbor tar czf - /data > harbor-data.tar.gz
```

---

## Monitoring & Alerting

### Access Dashboards

- **Prometheus**: https://prometheus.harbor.example.com (metrics)
- **Grafana**: https://grafana.harbor.example.com (dashboards)
- **AlertManager**: https://alerts.harbor.example.com (alerts)
- **Traefik**: https://traefik.harbor.example.com (reverse proxy)

### Configure Alerting

Edit `alertmanager/config.yml`:

```yaml
receivers:
  - name: 'critical-receiver'
    slack_configs:
      - channel: '#alerts-critical'
        api_url: 'YOUR_SLACK_WEBHOOK_URL'
    email_configs:
      - to: 'ops@example.com'
        from: 'alerts@example.com'
```

Reload AlertManager:
```bash
docker-compose restart alertmanager
```

### Add Custom Metrics

Edit `prometheus/prometheus.yml` to add new scrape targets:

```yaml
scrape_configs:
  - job_name: 'custom-service'
    static_configs:
      - targets: ['custom-service:8080']
```

---

## Security Considerations

### 1. Change Default Passwords

```bash
# Harbor admin password (change in Harbor UI)
# Menu: Administration → Users → Admin

# Database password (update .env and restart)
POSTGRES_PASSWORD=NewSecurePassword123!

# Redis password (update .env and restart)
REDIS_PASSWORD=NewSecurePassword123!
```

### 2. Enable HTTPS Everywhere

- Let's Encrypt is automatically configured
- All HTTP traffic is redirected to HTTPS
- TLS certificates are renewed automatically

### 3. Network Isolation

- Internal services communicate via `harbor-internal` network
- External traffic goes through Traefik
- Database and Redis not exposed to the internet

### 4. Firewall Rules

```bash
# Allow only required ports
sudo ufw allow 80/tcp   # HTTP for ACME challenge
sudo ufw allow 443/tcp  # HTTPS for Harbor
sudo ufw allow 8080/tcp # Traefik dashboard (restrict by IP)
sudo ufw deny from any to any port 5432   # PostgreSQL
sudo ufw deny from any to any port 6379   # Redis
```

### 5. Image Scanning

- Trivy is automatically configured for vulnerability scanning
- Enable policy enforcement in Harbor UI
- Configure Trivy severity levels in `.env`

### 6. Content Trust (Optional)

Enable Notary in `docker-compose.yml`:

```yaml
NOTARY_ENABLED: 'true'
```

Then sign images:
```bash
docker push -DCT=true user/image:tag
```

---

## Troubleshooting

### Harbor Not Starting

```bash
# Check logs
docker-compose logs harbor

# Common issues:
# 1. PostgreSQL not ready - wait 30+ seconds
# 2. Port 443 already in use - check with: lsof -i :443
# 3. .env file missing - copy from .env.example
```

### Database Connection Issues

```bash
# Test PostgreSQL connection
docker-compose exec postgres-primary psql -U harbor -d harbor -c "SELECT 1"

# Test replica connection
docker-compose exec postgres-replica-1 psql -U harbor -d harbor -c "SELECT 1"
```

### Redis Connection Issues

```bash
# Test Redis connection
docker-compose exec redis-master redis-cli -a PASSWORD ping

# Check replication status
docker-compose exec redis-master redis-cli -a PASSWORD info replication
```

### SSL Certificate Issues

```bash
# Check certificate status
docker-compose logs traefik | grep -i "tls\|acme\|certificate"

# Manually trigger certificate renewal
docker-compose restart traefik
```

### Monitoring not collecting metrics

```bash
# Check Prometheus targets
docker-compose logs prometheus | grep "scrape"

# Test metric endpoint
docker-compose exec harbor curl localhost:8080/metrics
```

---

## Performance Tuning

### Database Optimization

Edit `config/postgres/postgresql.conf`:

```conf
# For 16GB RAM server
shared_buffers = 4GB
effective_cache_size = 12GB
work_mem = 32MB
maintenance_work_mem = 512MB
```

### Redis Optimization

```bash
# Increase memory limit if needed
docker update --memory 2g redis-master
```

### Container Resource Limits

Update `docker-compose.yml`:

```yaml
harbor:
  mem_limit: 2g
  memswap_limit: 2g
```

---

## Maintenance

### Regular Tasks

- **Daily**: Monitor alerting dashboard
- **Weekly**: Review Grafana dashboards for trends
- **Monthly**: Run backups and test restore
- **Quarterly**: Update Docker images and applications

### Update Harbor

```bash
# 1. Backup current installation
./scripts/backup.sh pre-upgrade-backup

# 2. Update HARBOR_VERSION in .env
HARBOR_VERSION=v2.10.0

# 3. Restart with new images
docker-compose pull
docker-compose up -d

# 4. Verify
docker-compose ps
```

---

## Useful Commands

```bash
# View container resource usage
docker stats

# Clean up unused images
docker image prune -a

# Restart all services
docker-compose restart

# Rebuild specific service
docker-compose up -d --build harbor

# Execute command in container
docker-compose exec harbor bash

# Monitor real-time logs
docker-compose logs -f --tail=100 service-name
```

---

## Support & Documentation

- **Harbor Official Docs**: https://goharbor.io/docs
- **Docker Compose Docs**: https://docs.docker.com/compose
- **Traefik Docs**: https://doc.traefik.io/traefik/
- **Prometheus Docs**: https://prometheus.io/docs

---

## License

This TP16 setup is provided as-is for educational and production use.

---

## Contact & Feedback

For issues or improvements, please refer to the project documentation and logs.

**Last Updated**: 2025-12-07
