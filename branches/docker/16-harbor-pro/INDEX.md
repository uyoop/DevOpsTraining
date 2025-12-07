# TP16 - Harbor Production-Ready Setup - Quick Index

## 📚 Documentation

Start here to understand and deploy TP16:

1. **[README.md](README.md)** - Complete setup guide and overview
   - Architecture overview
   - Prerequisites and system requirements
   - Quick start guide
   - Configuration guide
   - Monitoring setup
   - Security considerations
   - Troubleshooting

2. **[COMMANDS.md](COMMANDS.md)** - Command reference
   - Deployment commands
   - Service management
   - Backup & restore operations
   - Monitoring and metrics
   - Database management
   - Security operations

3. **[MANIFEST.md](MANIFEST.md)** - Project inventory
   - Complete file structure
   - Services inventory
   - Configuration files
   - Volume mappings
   - Features checklist
   - Performance metrics

---

## 🚀 Quick Start (5 minutes)

```bash
# 1. Configure environment
cp .env.example .env
nano .env                    # Edit HARBOR_HOSTNAME, passwords, etc.

# 2. Make scripts executable
chmod +x scripts/*.sh

# 3. Deploy
./scripts/deploy.sh

# 4. Access Harbor
# URL: https://harbor.example.com
# Username: admin
# Password: [HARBOR_ADMIN_PASSWORD from .env]
```

---

## 📋 Key Features

✅ **Production-Ready**
- Traefik v3 reverse proxy with SSL/TLS
- PostgreSQL HA with streaming replication
- Redis Sentinel for cache failover
- Comprehensive monitoring & alerting

✅ **Enterprise Features**
- LDAP/OIDC authentication support
- S3-compatible storage backend option
- Image vulnerability scanning (Trivy)
- Content trust and signing (Notary)

✅ **Operational Excellence**
- Automated backup/restore scripts
- Health checks and auto-recovery
- Comprehensive documentation
- Detailed troubleshooting guide

---

## 🔧 Essential Commands

### Deployment
```bash
./scripts/deploy.sh                 # Full deployment
docker-compose up -d               # Start services
docker-compose ps                  # View status
```

### Backup & Restore
```bash
./scripts/backup.sh                # Create backup
./scripts/restore.sh backupname    # Restore from backup
```

### Monitoring
```bash
# Access dashboards
# Prometheus: https://prometheus.harbor.example.com
# Grafana: https://grafana.harbor.example.com
# AlertManager: https://alerts.harbor.example.com

# View logs
docker-compose logs -f harbor
docker-compose logs -f postgres-primary
docker-compose logs -f prometheus
```

### Troubleshooting
```bash
docker-compose ps                              # Check service status
docker-compose logs service-name               # View logs
docker-compose exec harbor curl http://localhost:8080/api/v2.0/health  # Health check
```

---

## 📁 Directory Structure

```
16-harbor-pro/
├── docker-compose.yml       # Main orchestration file
├── .env.example             # Configuration template
├── README.md               # Complete documentation
├── COMMANDS.md             # Command reference
├── MANIFEST.md             # Project inventory
├── INDEX.md                # This file
│
├── config/                 # Service configurations
│   ├── postgres/           # Database configuration
│   └── redis/              # Cache configuration
│
├── traefik/                # Reverse proxy config
├── prometheus/             # Metrics collection
├── grafana/                # Visualization
├── loki/                   # Log aggregation
├── alertmanager/           # Alert routing
├── trivy/                  # Security scanner
│
├── scripts/                # Automation scripts
│   ├── deploy.sh          # Deployment
│   ├── backup.sh          # Backup creation
│   └── restore.sh         # Restore from backup
│
└── backups/               # Backup storage (auto-created)
```

---

## 🔐 Security Checklist

- [ ] Update all passwords in `.env` file
- [ ] Configure firewall rules (allow 80, 443 only)
- [ ] Enable HTTPS (automatic with Let's Encrypt)
- [ ] Configure LDAP/OIDC for authentication
- [ ] Set up email notifications in AlertManager
- [ ] Configure backup location (off-server preferred)
- [ ] Enable image scanning and policy enforcement
- [ ] Review network isolation (internal networks)

---

## 📊 Monitoring Setup

1. **Prometheus** (metrics):
   - Automatically scrapes Harbor, PostgreSQL, Redis, system metrics
   - Access: https://prometheus.harbor.example.com

2. **Grafana** (dashboards):
   - Pre-configured datasources for Prometheus and Loki
   - Access: https://grafana.harbor.example.com

3. **Loki** (logs):
   - Aggregates logs from all services
   - Accessed through Grafana

4. **AlertManager** (alerts):
   - Sends alerts to Slack or email
   - Configure in `alertmanager/config.yml`

---

## 🆘 Troubleshooting Quick Links

**Harbor not starting?**
- Check logs: `docker-compose logs harbor`
- Wait for PostgreSQL: `docker-compose logs postgres-primary`
- See [README.md#troubleshooting](README.md#troubleshooting)

**Connection errors?**
- Test PostgreSQL: `docker-compose exec postgres-primary pg_isready`
- Test Redis: `docker-compose exec redis-master redis-cli ping`
- See [COMMANDS.md#troubleshooting](COMMANDS.md#troubleshooting)

**Backup issues?**
- List backups: `ls -la backups/`
- See [COMMANDS.md#backup--restore](COMMANDS.md#backup--restore)

---

## 📞 Support Resources

- **Harbor Documentation**: https://goharbor.io/docs/
- **Docker Compose**: https://docs.docker.com/compose/
- **Traefik**: https://doc.traefik.io/traefik/
- **Prometheus**: https://prometheus.io/docs/

---

## 📝 Configuration Files Reference

| File | Purpose |
|------|---------|
| `.env` | Environment variables and secrets (copy from .env.example) |
| `docker-compose.yml` | Service definitions and orchestration |
| `config/postgres/postgresql.conf` | PostgreSQL tuning parameters |
| `config/redis/sentinel.conf` | Redis Sentinel failover config |
| `traefik/dynamic/config.yml` | Traefik routing and middleware |
| `prometheus/prometheus.yml` | Prometheus scrape targets |
| `prometheus/rules/harbor-alerts.yml` | Alert rule definitions |
| `alertmanager/config.yml` | Alert notification routing |
| `loki/loki-config.yml` | Log retention and chunk settings |
| `grafana/provisioning/datasources/*.yml` | Grafana data sources |

---

## 🎯 Next Steps

1. ✅ Read [README.md](README.md) for complete overview
2. ✅ Configure `.env` with your settings
3. ✅ Run `./scripts/deploy.sh` to deploy
4. ✅ Access Harbor at your configured hostname
5. ✅ Review [COMMANDS.md](COMMANDS.md) for operations
6. ✅ Set up backups and monitoring
7. ✅ Configure authentication (LDAP/OIDC)

---

## 📅 Project Information

- **Created**: 2025-12-07
- **Version**: Production-Ready v1.0
- **Status**: ✅ Complete
- **Tested**: Yes
- **Compatibility**: Docker 20.10+, Docker Compose 2.0+

---

**Start with README.md for the complete guide!**
