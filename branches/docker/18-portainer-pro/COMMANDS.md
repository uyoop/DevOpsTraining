# TP18 - Portainer Enterprise Commands

## Deployment

```bash
# Deploy Portainer
chmod +x scripts/*.sh
./scripts/deploy.sh

# Stop services
docker-compose down

# View status
docker-compose ps

# View logs
docker-compose logs -f portainer
docker-compose logs -f postgres
docker-compose logs -f prometheus
docker-compose logs -f grafana
```

## Access

```bash
# Portainer
https://portainer.example.com

# Grafana
https://grafana.portainer.example.com

# Prometheus
https://prometheus.portainer.example.com

# Health check
curl https://portainer.example.com/api/health
```

## Database

```bash
# Connect to PostgreSQL
docker-compose exec postgres psql -U portainer -d portainer

# Backup database
docker-compose exec -T postgres pg_dump -U portainer portainer | gzip > postgres-backup.sql.gz

# Restore database
gunzip -c postgres-backup.sql.gz | \
  docker-compose exec -T postgres psql -U portainer portainer
```

## Backup

```bash
# Create backup
./scripts/backup.sh

# Custom name
./scripts/backup.sh production-backup-20241207

# List backups
ls -la backups/

# Backup size
du -sh backups/*
```

## Portainer API

```bash
# List environments
curl -s https://portainer.example.com/api/endpoints | jq .

# List containers
curl -s https://portainer.example.com/api/containers | jq .

# Create container
curl -X POST https://portainer.example.com/api/containers/create \
  -H "Content-Type: application/json" \
  -d '{...}'
```

## User Management

```bash
# Via API
curl -s https://portainer.example.com/api/users | jq .

# Create user
curl -X POST https://portainer.example.com/api/users \
  -H "Content-Type: application/json" \
  -d '{...}'
```

## Monitoring

```bash
# Prometheus queries
curl http://localhost:9090/api/v1/query?query=up

# Grafana datasources
curl http://localhost:3000/api/datasources
```

## Stack Management

```bash
# List stacks
curl https://portainer.example.com/api/stacks

# Deploy stack
curl -X POST https://portainer.example.com/api/stacks \
  -H "Content-Type: application/json" \
  -d '{...}'
```

---

**TP18 - Portainer Enterprise Setup**
