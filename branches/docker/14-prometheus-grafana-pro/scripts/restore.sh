#!/bin/bash

set -e

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <backup_file.tar.gz>"
    echo "Example: $0 /backups/monitoring_backup_20241207_153000.tar.gz"
    exit 1
fi

BACKUP_FILE="$1"

if [ ! -f "${BACKUP_FILE}" ]; then
    echo "Error: Backup file not found: ${BACKUP_FILE}"
    exit 1
fi

echo "=================================================="
echo "Monitoring Stack Restore Script"
echo "=================================================="
echo "Restore started at: $(date)"
echo "Backup file: ${BACKUP_FILE}"
echo ""

# Extract backup
echo "[1/7] Extracting backup archive..."
TEMP_DIR=$(mktemp -d)
tar xzf ${BACKUP_FILE} -C ${TEMP_DIR}
BACKUP_NAME=$(ls ${TEMP_DIR})
BACKUP_DIR="${TEMP_DIR}/${BACKUP_NAME}"
echo "✓ Backup extracted to: ${BACKUP_DIR}"

# Show manifest
echo ""
echo "Backup manifest:"
cat ${BACKUP_DIR}/manifest.txt
echo ""

read -p "Do you want to continue with the restore? (yes/no): " CONFIRM
if [ "${CONFIRM}" != "yes" ]; then
    echo "Restore cancelled."
    rm -rf ${TEMP_DIR}
    exit 0
fi

# Stop services
echo ""
echo "[2/7] Stopping services..."
docker compose down
echo "✓ Services stopped"

# Restore Prometheus data
echo "[3/7] Restoring Prometheus data..."
docker volume rm prometheus_data 2>/dev/null || true
docker volume create prometheus_data
docker run --rm -v prometheus_data:/prometheus -v ${BACKUP_DIR}:/backup alpine \
  sh -c "cd / && tar xzf /backup/prometheus_data.tar.gz"
echo "✓ Prometheus data restored"

# Restore Grafana data
echo "[4/7] Restoring Grafana data..."
docker volume rm grafana_data 2>/dev/null || true
docker volume create grafana_data
docker run --rm -v grafana_data:/var/lib/grafana -v ${BACKUP_DIR}:/backup alpine \
  sh -c "cd / && tar xzf /backup/grafana_data.tar.gz"
echo "✓ Grafana data restored"

# Restore Loki data
echo "[5/7] Restoring Loki data..."
docker volume rm loki_data 2>/dev/null || true
docker volume create loki_data
docker run --rm -v loki_data:/loki -v ${BACKUP_DIR}:/backup alpine \
  sh -c "cd / && tar xzf /backup/loki_data.tar.gz"
echo "✓ Loki data restored"

# Restore Alertmanager data
echo "[6/7] Restoring Alertmanager data..."
docker volume rm alertmanager_data 2>/dev/null || true
docker volume create alertmanager_data
docker run --rm -v alertmanager_data:/alertmanager -v ${BACKUP_DIR}:/backup alpine \
  sh -c "cd / && tar xzf /backup/alertmanager_data.tar.gz"
echo "✓ Alertmanager data restored"

# Restore configurations
echo "[7/7] Restoring configurations..."
tar xzf ${BACKUP_DIR}/configs.tar.gz -C .
echo "✓ Configurations restored"

# Cleanup temp directory
rm -rf ${TEMP_DIR}

# Start services
echo ""
echo "Starting services..."
docker compose up -d
echo "✓ Services started"

echo ""
echo "Waiting for services to be healthy..."
sleep 10

# Check service health
docker compose ps

echo ""
echo "=================================================="
echo "Restore completed successfully!"
echo "=================================================="
echo "Restore finished at: $(date)"
echo ""
echo "Services status:"
docker compose ps
echo ""
echo "Access your services:"
echo "  - Grafana: https://grafana.${DOMAIN}"
echo "  - Prometheus: https://prometheus.${DOMAIN}"
echo "  - Alertmanager: https://alertmanager.${DOMAIN}"
