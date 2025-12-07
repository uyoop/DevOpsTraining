# TP17 - Portainer Commands

## Deployment

```bash
# Start Portainer
docker-compose up -d

# Stop Portainer
docker-compose down

# View status
docker-compose ps

# View logs
docker-compose logs -f portainer

# Restart
docker-compose restart portainer
```

## Access

```bash
# HTTP
curl http://localhost:9000

# Health check
docker-compose exec portainer wget -q -O- http://localhost:9000
```

## Backup

```bash
# Backup data
docker cp portainer:/data ./portainer-backup

# Full volume backup
docker run --rm -v portainer-data:/data -v $(pwd):/backup \
  alpine tar czf /backup/portainer-backup-$(date +%Y%m%d).tar.gz -C /data .
```

## Container Operations via Portainer CLI

```bash
# List containers (via Docker)
docker ps

# Create container
docker run -d --name mycontainer image:tag

# Stop container
docker stop container-id

# View logs
docker logs container-id
```

---

**TP17 - Portainer Basic Setup**
