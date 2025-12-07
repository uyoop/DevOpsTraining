#!/bin/bash

# ==========================================
# Script de backup BookStack
# ==========================================

set -e

BACKUP_DIR="./backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="bookstack_backup_${TIMESTAMP}.tar.gz"

echo "🔄 Démarrage du backup..."

# Créer le dossier de backup
mkdir -p "${BACKUP_DIR}"

# Backup de la base de données
echo "📦 Backup de la base de données..."
docker-compose exec -T bookstack-db mysqldump \
    -u bookstack \
    -p$(cat secrets/db_password.txt) \
    bookstack > "${BACKUP_DIR}/db_${TIMESTAMP}.sql"

# Backup des volumes
echo "📦 Backup des volumes..."
docker run --rm \
    -v bookstack-app-data:/data/app:ro \
    -v "$(pwd)/${BACKUP_DIR}:/backup" \
    alpine tar czf "/backup/app_${TIMESTAMP}.tar.gz" -C /data app

# Combiner tous les backups
cd "${BACKUP_DIR}"
tar czf "${BACKUP_FILE}" "db_${TIMESTAMP}.sql" "app_${TIMESTAMP}.tar.gz"

# Nettoyer les fichiers temporaires
rm "db_${TIMESTAMP}.sql" "app_${TIMESTAMP}.tar.gz"

# Chiffrer le backup
echo "🔐 Chiffrement du backup..."
gpg --symmetric --cipher-algo AES256 "${BACKUP_FILE}"
rm "${BACKUP_FILE}"

cd ..

echo "✅ Backup terminé : ${BACKUP_DIR}/${BACKUP_FILE}.gpg"
echo "📊 Taille : $(du -h ${BACKUP_DIR}/${BACKUP_FILE}.gpg | cut -f1)"

# Garder seulement les 10 derniers backups
echo "🧹 Nettoyage des anciens backups..."
cd "${BACKUP_DIR}"
ls -t bookstack_backup_*.tar.gz.gpg | tail -n +11 | xargs -r rm
cd ..

echo "✅ Backup complet terminé !"
