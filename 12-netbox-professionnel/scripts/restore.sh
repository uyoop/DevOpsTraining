#!/bin/bash
# Restore script for NetBox production

set -e

if [ $# -ne 3 ]; then
    echo "Usage: $0 <db_backup.sql.gz> <media_backup.tar.gz> <config_backup.tar.gz>"
    exit 1
fi

DB_BACKUP="$1"
MEDIA_BACKUP="$2"
CONFIG_BACKUP="$3"

echo "[$(date)] Starting NetBox restore..."

# Verify backups exist
for backup in "$DB_BACKUP" "$MEDIA_BACKUP" "$CONFIG_BACKUP"; do
    if [ ! -f "$backup" ]; then
        echo "Error: Backup file not found: $backup"
        exit 1
    fi
done

# Stop services
echo "[$(date)] Stopping services..."
docker compose down

# Restore configuration
echo "[$(date)] Restoring configuration..."
tar xzf "$CONFIG_BACKUP"

# Restore PostgreSQL
echo "[$(date)] Restoring PostgreSQL..."
docker compose up -d postgres
sleep 10
gunzip -c "$DB_BACKUP" | \
  docker compose exec -T postgres psql -U netbox netbox
echo "[$(date)] PostgreSQL restored"

# Restore media files
echo "[$(date)] Restoring media files..."
docker compose up -d netbox
sleep 10
docker compose exec -T netbox rm -rf /opt/netbox/netbox/media/*
tar xzf "$MEDIA_BACKUP" -C / --strip-components=1
echo "[$(date)] Media files restored"

# Start all services
echo "[$(date)] Starting all services..."
docker compose up -d

# Verify
sleep 30
if curl -f http://localhost:8080/ > /dev/null 2>&1; then
    echo "[$(date)] Restore completed successfully!"
else
    echo "[$(date)] ERROR: Services not responding!"
    exit 1
fi
