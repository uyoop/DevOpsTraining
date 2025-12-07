# TP16 - Harbor Project Manifest

Complete manifest and inventory of TP16 Harbor production-ready setup.

---

## Project Structure

```
16-harbor-pro/
├── docker-compose.yml          # Main Docker Compose file
├── .env.example                 # Environment template
├── .gitignore                   # Git ignore rules
├── README.md                    # Complete documentation
├── COMMANDS.md                  # Commands reference
├── MANIFEST.md                  # This file
│
├── config/                      # Service configurations
│   ├── postgres/
│   │   ├── postgresql.conf      # PostgreSQL settings
│   │   └── pg_hba.conf          # Client authentication
│   └── redis/
│       └── sentinel.conf        # Redis Sentinel settings
│
├── traefik/                     # Reverse proxy configuration
│   ├── dynamic/
│   │   └── config.yml           # Dynamic routing config
│   └── acme.json                # TLS certificates (auto-generated)
│
├── prometheus/                  # Metrics collection
│   ├── prometheus.yml           # Prometheus configuration
│   └── rules/
│       └── harbor-alerts.yml    # Alert rules
│
├── grafana/                     # Visualization
│   └── provisioning/
│       ├── dashboards/          # Dashboard definitions
│       └── datasources/
│           └── prometheus.yml   # Data source config
│
├── loki/                        # Log aggregation
│   └── loki-config.yml          # Loki configuration
│
├── promtail/                    # Log shipping agent
│   └── config.yml               # Promtail configuration
│
├── alertmanager/                # Alert routing
│   └── config.yml               # Alert management config
│
├── trivy/                       # Security scanner
│   └── trivy.yaml               # Trivy configuration
│
├── scripts/                     # Automation scripts
│   ├── deploy.sh               # Deployment script
│   ├── backup.sh               # Backup script
│   ├── restore.sh              # Restore script
│   ├── init-db.sh              # Database initialization
│   └── init-replica.sh         # Replica initialization
│
└── backups/                     # Backup storage (created at runtime)
    └── harbor-backup-*/        # Dated backup directories
```

---

## Services Inventory

### Core Services

| Service | Image | Port | Network | Description |
|---------|-------|------|---------|-------------|
| traefik | traefik:v3.1 | 80, 443, 8080 | traefik-network | Reverse proxy, SSL/TLS, load balancing |
| harbor | goharbor/harbor-core:v2.9.1 | 8080 | harbor-network | Container registry core |
| harbor-registry | goharbor/registry-photon:v2.9.1 | 5000 | harbor-network | Docker registry backend |
| harbor-jobservice | goharbor/harbor-jobservice:v2.9.1 | 8080 | harbor-network | Asynchronous job service |

### Database Services

| Service | Image | Port | Network | Description |
|---------|-------|------|---------|-------------|
| postgres-primary | postgres:15-alpine | 5432 | harbor-internal | Primary PostgreSQL database |
| postgres-replica-1 | postgres:15-alpine | 5433 | harbor-internal | Streaming replica #1 |
| postgres-replica-2 | postgres:15-alpine | 5434 | harbor-internal | Streaming replica #2 |

### Cache Services

| Service | Image | Port | Network | Description |
|---------|-------|------|---------|-------------|
| redis-master | redis:7-alpine | 6379 | harbor-internal | Redis master for caching |
| redis-replica-1 | redis:7-alpine | 6380 | harbor-internal | Redis replica #1 |
| redis-replica-2 | redis:7-alpine | 6381 | harbor-internal | Redis replica #2 |
| redis-sentinel-1 | redis:7-alpine | 26379 | harbor-internal | Sentinel node #1 |
| redis-sentinel-2 | redis:7-alpine | 26380 | harbor-internal | Sentinel node #2 |
| redis-sentinel-3 | redis:7-alpine | 26381 | harbor-internal | Sentinel node #3 |

### Monitoring Services

| Service | Image | Port | Network | Description |
|---------|-------|------|---------|-------------|
| prometheus | prom/prometheus:latest | 9090 | harbor-network | Metrics collection |
| grafana | grafana/grafana:latest | 3000 | harbor-network | Visualization dashboards |
| alertmanager | prom/alertmanager:latest | 9093 | harbor-network | Alert routing & notifications |
| loki | grafana/loki:latest | 3100 | harbor-network | Log aggregation |
| promtail | grafana/promtail:latest | N/A | harbor-network | Log shipping agent |

### Security Services

| Service | Image | Port | Network | Description |
|---------|-------|------|---------|-------------|
| trivy | aquasec/trivy:latest | 8080 | harbor-network | Vulnerability scanner |

---

## Networks

| Name | Type | Internal | Connected Services |
|------|------|----------|-------------------|
| harbor-network | bridge | false | harbor, registry, jobservice, prometheus, grafana, loki, promtail, alertmanager, trivy |
| harbor-internal | bridge | true | postgres-primary, postgres-replica-*, redis-master, redis-replica-*, redis-sentinel-* |
| traefik-network | bridge | false | traefik, harbor, prometheus, grafana, alertmanager |

---

## Volumes

| Name | Type | Mount Point | Used By | Purpose |
|------|------|------------|---------|---------|
| postgres-primary-data | named | /var/lib/postgresql/data | postgres-primary | Primary database data |
| postgres-replica-1-data | named | /var/lib/postgresql/data | postgres-replica-1 | Replica #1 data |
| postgres-replica-2-data | named | /var/lib/postgresql/data | postgres-replica-2 | Replica #2 data |
| redis-master-data | named | /data | redis-master | Master cache data |
| redis-replica-1-data | named | /data | redis-replica-1 | Replica #1 cache |
| redis-replica-2-data | named | /data | redis-replica-2 | Replica #2 cache |
| redis-sentinel-1-data | named | /data | redis-sentinel-1 | Sentinel #1 state |
| redis-sentinel-2-data | named | /data | redis-sentinel-2 | Sentinel #2 state |
| redis-sentinel-3-data | named | /data | redis-sentinel-3 | Sentinel #3 state |
| harbor-data | named | /data | harbor | Harbor configuration & data |
| harbor-registry-data | named | /storage | harbor-registry | Registry image storage |
| harbor-jobservice-data | named | /var/log/jobs | harbor-jobservice | Job logs |
| prometheus-data | named | /prometheus | prometheus | Time series database |
| grafana-data | named | /var/lib/grafana | grafana | Dashboards & settings |
| loki-data | named | /loki | loki | Log index & chunks |
| alertmanager-data | named | /alertmanager | alertmanager | Alert silence history |
| trivy-cache | named | /root/.cache/trivy | trivy | Vulnerability database |

---

## Environment Variables

### Harbor Core

```env
HARBOR_HOSTNAME=harbor.example.com
HARBOR_HTTP_PORT=80
HARBOR_HTTPS_PORT=443
HARBOR_ADMIN_PASSWORD=***
HARBOR_VERSION=v2.9.1
```

### TLS/SSL

```env
CERT_EMAIL=admin@example.com
ACME_SERVER=https://acme-v02.api.letsencrypt.org/directory
```

### Traefik

```env
TRAEFIK_DASHBOARD_HOST=traefik.example.com
TRAEFIK_DASHBOARD_USER=admin
TRAEFIK_DASHBOARD_PASSWORD=***
TRAEFIK_LOG_LEVEL=INFO
```

### PostgreSQL

```env
POSTGRES_PASSWORD=***
POSTGRES_REPLICATION_PASSWORD=***
POSTGRES_SUPERUSER=postgres
POSTGRES_DATABASE=harbor
POSTGRES_USER=harbor
POSTGRES_USER_PASSWORD=***
```

### Redis

```env
REDIS_PASSWORD=***
REDIS_SENTINEL_PASSWORD=***
REDIS_QUORUM=2
REDIS_FAILOVER_TIMEOUT=3000
```

### S3 (Optional)

```env
S3_ENABLED=false
S3_ENDPOINT=s3.amazonaws.com
S3_REGION=us-east-1
S3_BUCKET=harbor-registry
S3_ACCESS_KEY=***
S3_SECRET_KEY=***
S3_ENCRYPT=true
```

### Monitoring

```env
PROMETHEUS_RETENTION=30d
PROMETHEUS_SCRAPE_INTERVAL=15s
GRAFANA_ADMIN_PASSWORD=***
LOKI_RETENTION_DAYS=30
```

### Alerting

```env
ALERTMANAGER_SLACK_WEBHOOK=***
ALERTMANAGER_EMAIL_FROM=alerts@example.com
ALERTMANAGER_EMAIL_TO=ops@example.com
ALERTMANAGER_SMTP_HOST=smtp.example.com
ALERTMANAGER_SMTP_PORT=587
```

---

## Features Checklist

### ✅ Core Features
- [x] Harbor v2.9.1+ registry
- [x] Docker image storage & management
- [x] Image vulnerability scanning
- [x] Image replication
- [x] Helm chart hosting
- [x] RBAC with projects

### ✅ High Availability
- [x] PostgreSQL streaming replication (3-way)
- [x] Redis Sentinel failover (3 sentinels)
- [x] Health checks on all services
- [x] Automatic service restart

### ✅ Networking & Security
- [x] Traefik v3 reverse proxy
- [x] Automatic SSL/TLS (Let's Encrypt)
- [x] HTTP to HTTPS redirection
- [x] Network isolation (internal networks)
- [x] Rate limiting middleware
- [x] Compression middleware

### ✅ Monitoring & Observability
- [x] Prometheus metrics collection
- [x] Grafana dashboards
- [x] Loki log aggregation
- [x] Promtail log shipping
- [x] AlertManager for alerts
- [x] Custom alert rules

### ✅ Security
- [x] Trivy vulnerability scanner
- [x] Content Trust (Notary) support
- [x] LDAP integration support
- [x] OIDC authentication support
- [x] Custom CA certificate support
- [x] TLS 1.2+ enforcement

### ✅ Operations
- [x] Automated backup scripts
- [x] Restore scripts
- [x] Deployment automation
- [x] Docker Compose orchestration
- [x] Health checks & recovery
- [x] Resource limits

### ✅ Documentation
- [x] README.md (setup guide)
- [x] COMMANDS.md (reference)
- [x] MANIFEST.md (this file)
- [x] Configuration examples
- [x] Troubleshooting guide
- [x] Security guidelines

---

## Configuration Files

| File | Purpose | Editable | Format |
|------|---------|----------|--------|
| docker-compose.yml | Service orchestration | Yes | YAML |
| .env.example | Environment template | No | Shell |
| .env | Environment secrets | Yes | Shell |
| config/postgres/postgresql.conf | PostgreSQL tuning | Yes | Config |
| config/postgres/pg_hba.conf | Database auth | Yes | Config |
| config/redis/sentinel.conf | Sentinel failover | Yes | Config |
| traefik/dynamic/config.yml | Routing & TLS | Yes | YAML |
| prometheus/prometheus.yml | Metrics scraping | Yes | YAML |
| prometheus/rules/harbor-alerts.yml | Alert rules | Yes | YAML |
| alertmanager/config.yml | Alert routing | Yes | YAML |
| loki/loki-config.yml | Log retention | Yes | YAML |
| promtail/config.yml | Log collection | Yes | YAML |
| trivy/trivy.yaml | Security scanning | Yes | YAML |
| grafana/provisioning/datasources/*.yml | Data sources | Yes | YAML |

---

## Deployment Requirements

### Minimum

- 4 CPU cores
- 8 GB RAM
- 50 GB storage
- Ubuntu 20.04 / CentOS 8 / Debian 11+
- Docker 20.10+
- Docker Compose 2.0+

### Recommended (Production)

- 8+ CPU cores
- 16+ GB RAM
- 250+ GB storage (depending on image volume)
- High-speed network connection
- Dedicated storage backend (S3, NFS)
- Load balancer for HA

---

## Backup Strategy

| Component | Frequency | Retention | Tool |
|-----------|-----------|-----------|------|
| Harbor data | Daily | 30 days | backup.sh |
| PostgreSQL | Daily | 30 days | backup.sh |
| Redis | Daily | 30 days | backup.sh |
| Configurations | Daily | 30 days | backup.sh |
| TLS certificates | Never | Auto-renew | Traefik |

---

## Monitoring & Alerting

### Prometheus Scrape Targets

- Prometheus self-monitoring
- Docker daemon metrics
- Harbor Core API
- Harbor Registry
- PostgreSQL (via exporter)
- Redis (via exporter)
- Node system metrics

### Alert Rules

- Service health alerts
- Database replication lag
- Redis failover
- Disk space warnings
- CPU/Memory alerts
- Network traffic monitoring

### Notification Channels

- Slack (configured in AlertManager)
- Email (SMTP configured)
- Webhooks (extensible)

---

## Security Considerations

### Authentication

- Harbor: Local users, LDAP, OIDC
- PostgreSQL: User-based replication, password protected
- Redis: AUTH protected
- Traefik: Basic auth for dashboard

### Encryption

- HTTPS/TLS 1.2+ for all external traffic
- PostgreSQL replication with password
- Redis AUTH passwords
- Environment variables with secrets

### Network Isolation

- `harbor-internal`: Only internal services (DB, Cache)
- `harbor-network`: Harbor + monitoring
- `traefik-network`: Public-facing services
- No direct exposure of databases/cache to internet

---

## Performance Metrics

### Expected Baseline

- **Harbor API**: < 100ms response time
- **PostgreSQL**: < 10ms query latency
- **Redis**: < 1ms cache access
- **Prometheus**: < 30s scrape interval
- **CPU usage**: 10-20% idle
- **Memory usage**: 60-70% capacity

### Scaling Recommendations

| Metric | Threshold | Action |
|--------|-----------|--------|
| Memory > 85% | Scale up container RAM |
| CPU > 80% | Add more cores or instances |
| Disk > 80% | Add storage or cleanup |
| Registry size > 100GB | Consider S3 backend |
| Connection count > 80 | Tune PostgreSQL |

---

## Support & Documentation

- **Harbor Docs**: https://goharbor.io/docs/
- **Docker Compose**: https://docs.docker.com/compose/
- **Traefik**: https://doc.traefik.io/traefik/
- **Prometheus**: https://prometheus.io/docs/
- **PostgreSQL**: https://www.postgresql.org/docs/
- **Redis**: https://redis.io/documentation

---

## Version Information

| Component | Version | Last Updated |
|-----------|---------|--------------|
| Harbor | v2.9.1+ | 2025-12-07 |
| Docker | 20.10+ | - |
| Docker Compose | 2.0+ | - |
| Traefik | v3.1 | 2025-12-07 |
| PostgreSQL | 15 | 2025-12-07 |
| Redis | 7 | 2025-12-07 |
| Prometheus | latest | - |
| Grafana | latest | - |
| Loki | latest | - |
| Trivy | latest | - |

---

**Project Created**: 2025-12-07
**Last Updated**: 2025-12-07
**Status**: Production-Ready
