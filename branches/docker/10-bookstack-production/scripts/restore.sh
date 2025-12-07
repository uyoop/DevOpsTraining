#!/bin/bash

# ==========================================
# Script de restauration BookStack
# ==========================================

set -e

if [ -z "$1" ]; then
    echo "Usage: $0 <backup_file.tar.gz.gpg>"
    echo ""
    echo "Backups disponibles :"
    ls -lh backups/bookstack_backup_*.tar.gz.gpg 2>/dev/null || echo "Aucun backup trouvé"
    exit 1
fi

BACKUP_FILE="$1"

if [ ! -f "${BACKUP_FILE}" ]; then
    echo "❌ Fichier de backup introuvable : ${BACKUP_FILE}"
    exit 1
fi

echo "⚠️  ATTENTION : Cette opération va écraser les données actuelles !"
read -p "Voulez-vous continuer ? (yes/no) : " confirm

if [ "$confirm" != "yes" ]; then
    echo "❌ Restauration annulée"
    exit 0
fi

TEMP_DIR=$(mktemp -d)
trap "rm -rf ${TEMP_DIR}" EXIT

echo "🔓 Déchiffrement du backup..."
gpg --decrypt "${BACKUP_FILE}" > "${TEMP_DIR}/backup.tar.gz"

echo "📦 Extraction du backup..."
cd "${TEMP_DIR}"
tar xzf backup.tar.gz

# Arrêter les services
echo "⏸️  Arrêt des services..."
cd - > /dev/null
docker-compose stop bookstack bookstack-db

# Restaurer la base de données
echo "📥 Restauration de la base de données..."
DB_BACKUP=$(ls ${TEMP_DIR}/db_*.sql | head -1)
docker-compose exec -T bookstack-db mysql \
    -u bookstack \
    -p$(cat secrets/db_password.txt) \
    bookstack < "${DB_BACKUP}"

# Restaurer les fichiers
echo "📥 Restauration des fichiers..."
APP_BACKUP=$(ls ${TEMP_DIR}/app_*.tar.gz | head -1)
docker run --rm \
    -v bookstack-app-data:/data \
    -v "${TEMP_DIR}:/backup" \
    alpine sh -c "cd /data && tar xzf /backup/$(basename ${APP_BACKUP}) --strip-components=1"

# Redémarrer les services
echo "▶️  Redémarrage des services..."
docker-compose start bookstack-db bookstack

echo "✅ Restauration terminée !"
echo "🌐 BookStack sera disponible dans quelques instants"
