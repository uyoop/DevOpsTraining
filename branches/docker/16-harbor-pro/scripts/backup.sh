#!/bin/bash
# Harbor Backup Script
# ==============================================================================
# Description: Backup Harbor data, databases, and configurations
# Usage: ./backup.sh [backup_name]
# ==============================================================================

set -e

BACKUP_DIR="${BACKUP_DESTINATION:-.}/backups"
BACKUP_NAME="${1:-harbor-backup-$(date +%Y%m%d-%H%M%S)}"
BACKUP_PATH="$BACKUP_DIR/$BACKUP_NAME"
RETENTION_DAYS="${BACKUP_RETENTION_DAYS:-30}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Functions
log() { echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1" >&2; exit 1; }
warn() { echo -e "${YELLOW}[WARNING]${NC} $1"; }

# Check prerequisites
check_prerequisites() {
  command -v docker &> /dev/null || error "Docker is not installed"
  command -v docker-compose &> /dev/null || error "Docker Compose is not installed"
  [[ -n "$BACKUP_DIR" ]] || error "BACKUP_DESTINATION is not set"
}

# Create backup directory
create_backup_dir() {
  mkdir -p "$BACKUP_PATH" || error "Failed to create backup directory"
  log "Backup directory created: $BACKUP_PATH"
}

# Backup Harbor data
backup_harbor_data() {
  log "Backing up Harbor data..."
  docker-compose exec -T harbor tar czf - /data | gzip > "$BACKUP_PATH/harbor-data.tar.gz" || error "Failed to backup Harbor data"
  log "Harbor data backup completed"
}

# Backup PostgreSQL
backup_postgres() {
  log "Backing up PostgreSQL database..."
  docker-compose exec -T postgres-primary pg_dump -U "$POSTGRES_USER" "$POSTGRES_DATABASE" | gzip > "$BACKUP_PATH/postgres-dump.sql.gz" || error "Failed to backup PostgreSQL"
  log "PostgreSQL backup completed"
}

# Backup Redis
backup_redis() {
  log "Backing up Redis data..."
  docker-compose exec -T redis-master redis-cli BGSAVE || error "Failed to trigger Redis BGSAVE"
  sleep 5
  docker cp redis-master:/data/dump.rdb "$BACKUP_PATH/redis-dump.rdb" || error "Failed to copy Redis dump"
  log "Redis backup completed"
}

# Backup configurations
backup_configs() {
  log "Backing up configurations..."
  tar czf "$BACKUP_PATH/configs.tar.gz" \
    config/ \
    traefik/ \
    prometheus/ \
    grafana/ \
    loki/ \
    alertmanager/ \
    promtail/ \
    trivy/ \
    .env \
    2>/dev/null || warn "Some configuration files may not exist"
  log "Configuration backup completed"
}

# Generate backup manifest
generate_manifest() {
  log "Generating backup manifest..."
  cat > "$BACKUP_PATH/MANIFEST.txt" <<EOF
Harbor Backup Manifest
======================
Backup Name: $BACKUP_NAME
Backup Date: $(date -u +'%Y-%m-%d %H:%M:%S UTC')
Backup Path: $BACKUP_PATH

Included Components:
- Harbor Core data
- PostgreSQL database dump
- Redis snapshot
- Configuration files

Backup Files:
$(ls -lh "$BACKUP_PATH" | tail -n +2)

Total Size: $(du -sh "$BACKUP_PATH" | cut -f1)

Restore Instructions:
1. Review the restore.sh script
2. Ensure Harbor services are stopped
3. Run: ./restore.sh $BACKUP_NAME
4. Verify all services are running correctly

EOF
  log "Backup manifest generated"
}

# Clean up old backups
cleanup_old_backups() {
  log "Cleaning up backups older than $RETENTION_DAYS days..."
  find "$BACKUP_DIR" -maxdepth 1 -type d -name "harbor-backup-*" -mtime "+$RETENTION_DAYS" -exec rm -rf {} \; 2>/dev/null || true
  log "Cleanup completed"
}

# Main execution
main() {
  log "Starting Harbor backup..."
  check_prerequisites
  create_backup_dir
  backup_harbor_data
  backup_postgres
  backup_redis
  backup_configs
  generate_manifest
  cleanup_old_backups
  log "✅ Backup completed successfully!"
  log "Backup location: $BACKUP_PATH"
  log "Backup size: $(du -sh "$BACKUP_PATH" | cut -f1)"
}

main "$@"
