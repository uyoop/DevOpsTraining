# TP16 - Harbor Commands Reference

Complete reference for managing Harbor production-ready setup.

---

## Table of Contents

1. [Deployment](#deployment)
2. [Service Management](#service-management)
3. [Backup & Restore](#backup--restore)
4. [Monitoring](#monitoring)
5. [Troubleshooting](#troubleshooting)
6. [Database Management](#database-management)
7. [Security & Access](#security--access)

---

## Deployment

### Initial Setup

```bash
# Copy environment template
cp .env.example .env

# Edit configuration
nano .env

# Make scripts executable
chmod +x scripts/*.sh

# Deploy Harbor
./scripts/deploy.sh
```

### Verify Deployment

```bash
# Check all services running
docker-compose ps

# Check service health
docker-compose exec harbor curl -s http://localhost:8080/api/v2.0/health | jq .

# View deployment logs
docker-compose logs --tail=50 harbor
```

### Redeploy Services

```bash
# Pull latest images
docker-compose pull

# Restart all services
docker-compose up -d

# Rebuild specific service
docker-compose up -d --build harbor
```

---

## Service Management

### Status & Health

```bash
# List all services
docker-compose ps

# Check specific service
docker-compose ps harbor

# Get service details
docker inspect harbor

# Service resource usage
docker stats harbor redis-master postgres-primary
```

### Start/Stop/Restart

```bash
# Stop all services
docker-compose down

# Stop without removing containers
docker-compose stop

# Restart all services
docker-compose restart

# Restart specific service
docker-compose restart harbor

# Start services (from stopped state)
docker-compose start
```

### Logs Management

```bash
# View logs (last 50 lines)
docker-compose logs --tail=50

# Follow logs in real-time
docker-compose logs -f

# Logs for specific service
docker-compose logs -f harbor
docker-compose logs -f postgres-primary
docker-compose logs -f redis-master
docker-compose logs -f prometheus
docker-compose logs -f grafana

# Logs with timestamps
docker-compose logs -t harbor

# Filter logs
docker-compose logs harbor | grep error
docker-compose logs harbor | grep -i "failed"
```

### Container Operations

```bash
# Open container shell
docker-compose exec harbor bash

# Execute command in container
docker-compose exec postgres-primary psql -U harbor -d harbor -c "SELECT * FROM pg_stat_replication;"

# Copy file from container
docker cp harbor:/data/config.json ./config.json

# Copy file to container
docker cp ./config.json harbor:/data/config.json
```

---

## Backup & Restore

### Automated Backup

```bash
# Run backup with timestamp
./scripts/backup.sh

# Run backup with custom name
./scripts/backup.sh production-backup-20241207

# List available backups
ls -lah backups/

# View backup manifest
cat backups/harbor-backup-20241207-143022/MANIFEST.txt

# Backup size
du -sh backups/harbor-backup-*
```

### Manual Backups

```bash
# PostgreSQL dump
docker-compose exec -T postgres-primary pg_dump -U harbor -d harbor | gzip > postgres-dump-$(date +%Y%m%d).sql.gz

# PostgreSQL dump with verbose
docker-compose exec -T postgres-primary pg_dump -U harbor -d harbor -v | gzip > postgres-dump-verbose.sql.gz

# Redis snapshot
docker-compose exec -T redis-master redis-cli BGSAVE
docker cp redis-master:/data/dump.rdb ./redis-dump-$(date +%Y%m%d).rdb

# Harbor data
docker-compose exec harbor tar czf - /data > harbor-data-$(date +%Y%m%d).tar.gz

# Configuration backup
tar czf config-backup-$(date +%Y%m%d).tar.gz config/ traefik/ prometheus/ grafana/ loki/ alertmanager/
```

### Restore from Backup

```bash
# List backups
ls -la backups/

# Restore specific backup
./scripts/restore.sh harbor-backup-20241207-143022

# Restore with confirmation
./scripts/restore.sh my-backup-2024

# Manual restore (advanced)
# Stop services first
docker-compose down

# Restore PostgreSQL
gunzip -c backups/harbor-backup-*/postgres-dump.sql.gz | docker-compose exec -T postgres-primary psql -U harbor -d harbor

# Restart services
docker-compose up -d
```

---

## Monitoring

### Dashboard Access

```bash
# Harbor URL
https://harbor.example.com

# Prometheus (metrics)
https://prometheus.harbor.example.com

# Grafana (dashboards)
https://grafana.harbor.example.com

# AlertManager (alerts)
https://alerts.harbor.example.com

# Traefik Dashboard
https://traefik.harbor.example.com
```

### Metrics

```bash
# Query Harbor metrics
docker-compose exec harbor curl -s http://localhost:8080/metrics | head -20

# Query Registry metrics
docker-compose exec harbor-registry curl -s http://localhost:5000/metrics

# Prometheus API (list metrics)
curl -s http://localhost:9090/api/v1/label/__name__/values | jq . | head -20

# Prometheus query
curl -s 'http://localhost:9090/api/v1/query?query=up' | jq .

# Query time range
curl -s 'http://localhost:9090/api/v1/query_range?query=up&start=2024-12-07T00:00:00Z&end=2024-12-07T23:59:59Z&step=1m'
```

### Health Checks

```bash
# Harbor Core health
docker-compose exec harbor curl -s http://localhost:8080/api/v2.0/health | jq .

# PostgreSQL
docker-compose exec postgres-primary pg_isready -U harbor

# Redis
docker-compose exec redis-master redis-cli -a PASSWORD ping

# Prometheus
docker-compose exec prometheus curl -s http://localhost:9090/-/healthy

# Grafana
docker-compose exec grafana curl -s http://localhost:3000/api/health | jq .

# AlertManager
docker-compose exec alertmanager curl -s http://localhost:9093/-/healthy
```

### View Metrics Summary

```bash
# Top 10 metrics by type
curl -s http://localhost:9090/api/v1/label/__name__/values | jq . | sort | head -10

# Current alerts
curl -s http://localhost:9090/api/v1/alerts | jq '.data[] | {alertname: .labels.alertname, state: .state, severity: .labels.severity}'

# AlertManager alerts
curl -s http://localhost:9093/api/v1/alerts | jq .

# Firing alerts
curl -s http://localhost:9093/api/v1/alerts | jq '.[] | select(.status.state == "active") | {alertname: .labels.alertname, severity: .labels.severity}'
```

---

## Troubleshooting

### General Diagnostics

```bash
# System resource usage
docker stats

# Disk usage
du -sh *

# Check disk space
df -h

# Memory usage
free -h

# Network connections
netstat -tulpn | grep LISTEN

# DNS resolution
nslookup harbor.example.com
```

### Service-specific Diagnostics

```bash
# Harbor connectivity
docker-compose exec harbor curl -v https://harbor.example.com/api/v2.0/health

# PostgreSQL replication status
docker-compose exec postgres-primary psql -U postgres -c "SELECT slot_name, slot_type, active FROM pg_replication_slots;"

# PostgreSQL connected replicas
docker-compose exec postgres-primary psql -U postgres -c "SELECT client_addr, state, sync_state FROM pg_stat_replication;"

# Redis replication
docker-compose exec redis-master redis-cli -a PASSWORD info replication

# Redis Sentinel status
docker-compose exec redis-sentinel-1 redis-cli -p 26379 sentinel masters

# Redis Sentinel monitoring
docker-compose exec redis-sentinel-1 redis-cli -p 26379 sentinel slaves mymaster
```

### Port Availability

```bash
# Check port 443 (HTTPS)
lsof -i :443

# Check port 5432 (PostgreSQL)
lsof -i :5432

# Check port 6379 (Redis)
lsof -i :6379

# Check all Harbor ports
netstat -tulpn | grep LISTEN
```

### Container Logs

```bash
# Recent errors in Harbor
docker-compose logs harbor 2>&1 | grep -i error

# Database connection issues
docker-compose logs postgres-primary 2>&1 | grep -i "error\|connection\|fail"

# Redis connectivity
docker-compose logs redis-master 2>&1 | grep -i "error"

# Traefik certificate issues
docker-compose logs traefik 2>&1 | grep -i "tls\|certificate\|acme"
```

### Reset/Recovery

```bash
# Reset Harbor (data loss - BE CAREFUL!)
docker-compose down -v

# Remove all volumes
docker volume rm 16-harbor-pro_*

# Fresh restart
docker-compose up -d

# Check logs during startup
docker-compose logs -f
```

---

## Database Management

### PostgreSQL Administration

```bash
# Connect to primary
docker-compose exec postgres-primary psql -U harbor -d harbor

# List databases
docker-compose exec postgres-primary psql -U postgres -l

# List tables
docker-compose exec postgres-primary psql -U harbor -d harbor -c "\dt"

# Database size
docker-compose exec postgres-primary psql -U harbor -d harbor -c "SELECT pg_size_pretty(pg_database_size('harbor'));"

# Table sizes
docker-compose exec postgres-primary psql -U harbor -d harbor -c "SELECT schemaname, tablename, pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) FROM pg_tables WHERE schemaname != 'pg_catalog' ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;"

# Connection count
docker-compose exec postgres-primary psql -U postgres -c "SELECT datname, count(*) FROM pg_stat_activity GROUP BY datname;"

# Replication status
docker-compose exec postgres-primary psql -U postgres -c "SELECT client_addr, usename, application_name, state, sync_state FROM pg_stat_replication;"

# Backup specific table
docker-compose exec postgres-primary pg_dump -U harbor -d harbor -t table_name | gzip > table_backup.sql.gz
```

### Redis Administration

```bash
# Connect to Redis
docker-compose exec redis-master redis-cli -a PASSWORD

# Redis info
docker-compose exec redis-master redis-cli -a PASSWORD info

# Memory usage
docker-compose exec redis-master redis-cli -a PASSWORD info memory

# Key statistics
docker-compose exec redis-master redis-cli -a PASSWORD dbsize

# List all keys
docker-compose exec redis-master redis-cli -a PASSWORD keys '*'

# Get value
docker-compose exec redis-master redis-cli -a PASSWORD get key_name

# Delete key
docker-compose exec redis-master redis-cli -a PASSWORD del key_name

# Flush database (clear all)
docker-compose exec redis-master redis-cli -a PASSWORD flushdb

# Sentinel info
docker-compose exec redis-sentinel-1 redis-cli -p 26379 sentinel masters

# Failover simulation
docker-compose exec redis-sentinel-1 redis-cli -p 26379 sentinel failover mymaster
```

---

## Security & Access

### User Management

```bash
# Access Harbor API
curl -u admin:password https://harbor.example.com/api/v2.0/users

# List users
curl -s -u admin:password https://harbor.example.com/api/v2.0/users | jq .

# Create user
curl -X POST https://harbor.example.com/api/v2.0/users \
  -H "Content-Type: application/json" \
  -u admin:password \
  -d '{
    "username": "newuser",
    "password": "newpassword",
    "email": "user@example.com",
    "realname": "New User"
  }'
```

### Project Management

```bash
# List projects
curl -s -u admin:password https://harbor.example.com/api/v2.0/projects | jq .

# Create project
curl -X POST https://harbor.example.com/api/v2.0/projects \
  -H "Content-Type: application/json" \
  -u admin:password \
  -d '{
    "project_name": "myproject",
    "public": false
  }'

# Get project details
curl -s -u admin:password https://harbor.example.com/api/v2.0/projects/1 | jq .
```

### Image & Repository Management

```bash
# List repositories in project
curl -s -u admin:password https://harbor.example.com/api/v2.0/projects/myproject/repositories | jq .

# List images in repository
curl -s -u admin:password https://harbor.example.com/api/v2.0/projects/myproject/repositories/myrepo/artifacts | jq .

# Get image details
curl -s -u admin:password https://harbor.example.com/api/v2.0/projects/myproject/repositories/myrepo/artifacts/latest | jq .

# Tag image
docker tag myimage:latest harbor.example.com/myproject/myimage:latest

# Push image
docker push harbor.example.com/myproject/myimage:latest

# Pull image
docker pull harbor.example.com/myproject/myimage:latest
```

### SSL/TLS

```bash
# Check certificate expiration
openssl s_client -connect harbor.example.com:443 -showcerts | grep -A5 "Validity"

# View certificate details
docker cp traefik:/traefik/acme.json . && jq . acme.json

# Test HTTPS
curl -v https://harbor.example.com/api/v2.0/health
```

---

## Advanced Operations

### Docker Registry Operations

```bash
# List registries
curl -s -u admin:password https://harbor.example.com/api/v2.0/registries | jq .

# Get registry logs
docker-compose logs harbor-registry

# Registry storage usage
docker-compose exec harbor du -sh /storage
```

### Garbage Collection

```bash
# Trigger garbage collection (removes untagged layers)
curl -X PUT https://harbor.example.com/api/v2.0/configurations \
  -H "Content-Type: application/json" \
  -u admin:password \
  -d '{
    "gc_enabled": true,
    "gc_schedule": "0 0 * * SUN"
  }'
```

### Replication

```bash
# Configure harbor as source for replication
# Via Harbor UI: Administration → Replication

# List replication policies
curl -s -u admin:password https://harbor.example.com/api/v2.0/replication/policies | jq .

# Create replication policy
curl -X POST https://harbor.example.com/api/v2.0/replication/policies \
  -H "Content-Type: application/json" \
  -u admin:password \
  -d '{
    "name": "replicate-to-backup",
    "src_registry": {"id": 0},
    "dest_registry": {"id": 1},
    "dest_namespace": "replicated",
    "trigger": {"type": "manual"}
  }'
```

---

## Performance Tuning

```bash
# Check container limits
docker inspect harbor | grep -i memory

# Update memory limit
docker update --memory 2g harbor

# Check CPU usage
docker stats --no-stream

# View resource constraints
docker inspect postgres-primary | jq '.[0].HostConfig | {Memory, MemorySwap, CpuQuota, CpuPeriod}'
```

---

**Last Updated**: 2025-12-07
