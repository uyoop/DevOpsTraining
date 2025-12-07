#!/bin/bash
# Backup script for NetBox production

set -e

BACKUP_DIR="./backups"
DATE=$(date +%Y%m%d_%H%M%S)
LOG_FILE="${BACKUP_DIR}/backup_${DATE}.log"

# Créer le répertoire de backup
mkdir -p "${BACKUP_DIR}"

echo "[$(date)] Starting NetBox backup..." | tee "${LOG_FILE}"

# Backup PostgreSQL
echo "[$(date)] Backing up PostgreSQL..." | tee -a "${LOG_FILE}"
docker compose exec -T postgres pg_dump -U netbox netbox | \
  gzip > "${BACKUP_DIR}/netbox_db_${DATE}.sql.gz"
echo "[$(date)] PostgreSQL backup completed" | tee -a "${LOG_FILE}"

# Backup Media files
echo "[$(date)] Backing up media files..." | tee -a "${LOG_FILE}"
docker compose exec -T netbox tar czf /backups/netbox_media_${DATE}.tar.gz \
  -C /opt/netbox/netbox media/
echo "[$(date)] Media backup completed" | tee -a "${LOG_FILE}"

# Backup Configuration
echo "[$(date)] Backing up configuration..." | tee -a "${LOG_FILE}"
tar czf "${BACKUP_DIR}/netbox_config_${DATE}.tar.gz" \
  ./config/ \
  ./.env \
  ./docker-compose.yml
echo "[$(date)] Configuration backup completed" | tee -a "${LOG_FILE}"

# Cleanup old backups (keep last 10)
echo "[$(date)] Cleaning up old backups (keeping last 10)..." | tee -a "${LOG_FILE}"
cd "${BACKUP_DIR}"
ls -t *.sql.gz | tail -n +11 | xargs -r rm
ls -t *.tar.gz | tail -n +11 | xargs -r rm
ls -t *.log | tail -n +11 | xargs -r rm
cd - > /dev/null

echo "[$(date)] Backup completed successfully!" | tee -a "${LOG_FILE}"
echo "Backup location: ${BACKUP_DIR}/netbox_*_${DATE}.*"
