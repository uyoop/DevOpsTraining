#!/bin/bash
# Harbor Restore Script
# ==============================================================================
# Description: Restore Harbor from backup
# Usage: ./restore.sh [backup_name]
# ==============================================================================

set -e

BACKUP_DIR="${BACKUP_DESTINATION:-.}/backups"
BACKUP_NAME="${1:-}"
BACKUP_PATH="$BACKUP_DIR/$BACKUP_NAME"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Functions
log() { echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1" >&2; exit 1; }
warn() { echo -e "${YELLOW}[WARNING]${NC} $1"; }

# Validate backup
validate_backup() {
  [[ -z "$BACKUP_NAME" ]] && error "Backup name is required. Usage: ./restore.sh <backup_name>"
  [[ ! -d "$BACKUP_PATH" ]] && error "Backup directory not found: $BACKUP_PATH"
  [[ ! -f "$BACKUP_PATH/MANIFEST.txt" ]] && warn "Backup manifest not found"
  log "Backup validated: $BACKUP_PATH"
}

# Check prerequisites
check_prerequisites() {
  command -v docker &> /dev/null || error "Docker is not installed"
  command -v docker-compose &> /dev/null || error "Docker Compose is not installed"
}

# Confirm restore
confirm_restore() {
  echo -e "${YELLOW}WARNING: This will restore Harbor from a backup.${NC}"
  echo "Backup: $BACKUP_PATH"
  read -p "Continue? (yes/no) " -r
  [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]] && error "Restore cancelled"
}

# Stop services
stop_services() {
  log "Stopping Harbor services..."
  docker-compose stop || error "Failed to stop services"
}

# Restore Harbor data
restore_harbor_data() {
  log "Restoring Harbor data..."
  [[ ! -f "$BACKUP_PATH/harbor-data.tar.gz" ]] && warn "Harbor data backup not found" && return
  docker-compose start harbor || error "Failed to start Harbor service"
  sleep 10
  docker-compose exec -T harbor rm -rf /data/* || true
  gunzip -c "$BACKUP_PATH/harbor-data.tar.gz" | docker-compose exec -T harbor tar xzf - || error "Failed to restore Harbor data"
  log "Harbor data restored"
}

# Restore PostgreSQL
restore_postgres() {
  log "Restoring PostgreSQL database..."
  [[ ! -f "$BACKUP_PATH/postgres-dump.sql.gz" ]] && warn "PostgreSQL backup not found" && return
  gunzip -c "$BACKUP_PATH/postgres-dump.sql.gz" | docker-compose exec -T postgres-primary psql -U "$POSTGRES_USER" "$POSTGRES_DATABASE" || error "Failed to restore PostgreSQL"
  log "PostgreSQL restored"
}

# Restore Redis
restore_redis() {
  log "Restoring Redis data..."
  [[ ! -f "$BACKUP_PATH/redis-dump.rdb" ]] && warn "Redis backup not found" && return
  docker cp "$BACKUP_PATH/redis-dump.rdb" redis-master:/data/dump.rdb || error "Failed to copy Redis dump"
  docker-compose exec -T redis-master redis-cli SHUTDOWN NOSAVE || true
  docker-compose start redis-master || error "Failed to start Redis service"
  sleep 5
  log "Redis restored"
}

# Restore configurations
restore_configs() {
  log "Restoring configurations..."
  [[ ! -f "$BACKUP_PATH/configs.tar.gz" ]] && warn "Configuration backup not found" && return
  gunzip -c "$BACKUP_PATH/configs.tar.gz" | tar xzf - || warn "Some configuration files may have failed to restore"
  log "Configurations restored"
}

# Start services
start_services() {
  log "Starting all Harbor services..."
  docker-compose up -d || error "Failed to start services"
  log "Services started"
}

# Verify restore
verify_restore() {
  log "Verifying restore..."
  local retries=0
  local max_retries=30
  
  while [[ $retries -lt $max_retries ]]; do
    if docker-compose exec -T harbor curl -f http://localhost:8080/api/v2.0/health &>/dev/null; then
      log "✅ Harbor is healthy"
      return 0
    fi
    sleep 2
    ((retries++))
  done
  
  warn "Harbor health check failed - please verify manually"
}

# Main execution
main() {
  log "Starting Harbor restore..."
  check_prerequisites
  validate_backup
  confirm_restore
  stop_services
  restore_harbor_data
  restore_postgres
  restore_redis
  restore_configs
  start_services
  verify_restore
  log "✅ Restore completed!"
}

main "$@"
