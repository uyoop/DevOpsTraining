#!/bin/bash

set -e

BACKUP_DIR="/backups"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_NAME="monitoring_backup_${TIMESTAMP}"

echo "=================================================="
echo "Monitoring Stack Backup Script"
echo "=================================================="
echo "Backup started at: $(date)"
echo ""

# Create backup directory
mkdir -p ${BACKUP_DIR}/${BACKUP_NAME}

# Backup Prometheus data
echo "[1/6] Backing up Prometheus data..."
docker compose exec -T prometheus tar czf - /prometheus \
  > ${BACKUP_DIR}/${BACKUP_NAME}/prometheus_data.tar.gz
echo "✓ Prometheus data backed up"

# Backup Grafana data
echo "[2/6] Backing up Grafana data..."
docker compose exec -T grafana tar czf - /var/lib/grafana \
  > ${BACKUP_DIR}/${BACKUP_NAME}/grafana_data.tar.gz
echo "✓ Grafana data backed up"

# Backup Loki data
echo "[3/6] Backing up Loki data..."
docker compose exec -T loki tar czf - /loki \
  > ${BACKUP_DIR}/${BACKUP_NAME}/loki_data.tar.gz
echo "✓ Loki data backed up"

# Backup Alertmanager data
echo "[4/6] Backing up Alertmanager data..."
docker compose exec -T alertmanager tar czf - /alertmanager \
  > ${BACKUP_DIR}/${BACKUP_NAME}/alertmanager_data.tar.gz
echo "✓ Alertmanager data backed up"

# Backup configurations
echo "[5/6] Backing up configurations..."
tar czf ${BACKUP_DIR}/${BACKUP_NAME}/configs.tar.gz \
  prometheus/ alertmanager/ grafana/ loki/ blackbox/ traefik/ .env
echo "✓ Configurations backed up"

# Create backup manifest
echo "[6/6] Creating backup manifest..."
cat > ${BACKUP_DIR}/${BACKUP_NAME}/manifest.txt << EOF
Backup Date: $(date)
Backup Name: ${BACKUP_NAME}
Docker Compose Version: $(docker compose version)
Prometheus Version: $(docker compose exec prometheus prometheus --version 2>&1 | head -n1)
Grafana Version: $(docker compose exec grafana grafana-cli --version 2>&1)
Loki Version: $(docker compose exec loki /usr/bin/loki --version 2>&1 | head -n1)

Files:
$(ls -lh ${BACKUP_DIR}/${BACKUP_NAME}/)
EOF
echo "✓ Manifest created"

# Compress entire backup
echo ""
echo "Creating final compressed archive..."
cd ${BACKUP_DIR}
tar czf ${BACKUP_NAME}.tar.gz ${BACKUP_NAME}/
BACKUP_SIZE=$(du -h ${BACKUP_NAME}.tar.gz | cut -f1)
rm -rf ${BACKUP_NAME}/

echo ""
echo "=================================================="
echo "Backup completed successfully!"
echo "=================================================="
echo "Backup location: ${BACKUP_DIR}/${BACKUP_NAME}.tar.gz"
echo "Backup size: ${BACKUP_SIZE}"
echo "Backup finished at: $(date)"
echo ""

# Cleanup old backups (keep last 7 days)
echo "Cleaning up old backups (keeping last 7 days)..."
find ${BACKUP_DIR} -name "monitoring_backup_*.tar.gz" -mtime +7 -delete
echo "✓ Cleanup completed"

echo ""
echo "To restore this backup, run:"
echo "./scripts/restore.sh ${BACKUP_DIR}/${BACKUP_NAME}.tar.gz"
