#!/bin/bash
# Portainer Backup Script
# ==============================================================================

set -e

BACKUP_DIR="${BACKUP_DESTINATION:-.}/backups"
BACKUP_NAME="${1:-portainer-backup-$(date +%Y%m%d-%H%M%S)}"
BACKUP_PATH="$BACKUP_DIR/$BACKUP_NAME"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() { echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1" >&2; exit 1; }

mkdir -p "$BACKUP_PATH" || error "Failed to create backup directory"
log "Backup directory: $BACKUP_PATH"

log "Backing up Portainer data..."
docker cp portainer:/data/portainer.db "$BACKUP_PATH/" 2>/dev/null || true
docker cp portainer:/data "$BACKUP_PATH/portainer-data" 2>/dev/null || true

log "Backing up PostgreSQL..."
docker-compose exec -T postgres pg_dump -U portainer portainer | gzip > "$BACKUP_PATH/postgres-dump.sql.gz" || true

log "Backup completed: $BACKUP_PATH"
echo "Backup size: $(du -sh $BACKUP_PATH | cut -f1)"
