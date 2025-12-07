#!/bin/bash
# Script de déploiement pour UyoopApp avec Docker

set -e

echo "========================================="
echo "   Déploiement UyoopApp avec Docker"
echo "========================================="
echo ""

# Couleurs pour les messages
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Vérifier que Docker est installé
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker n'est pas installé. Veuillez l'installer d'abord.${NC}"
    exit 1
fi

# Vérifier que Docker Compose est installé
if ! command -v docker compose &> /dev/null; then
    echo -e "${RED}❌ Docker Compose n'est pas installé. Veuillez l'installer d'abord.${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Docker et Docker Compose sont installés${NC}"
echo ""

# Créer le répertoire data s'il n'existe pas
if [ ! -d "data" ]; then
    echo -e "${YELLOW}→ Création du répertoire data...${NC}"
    mkdir -p data
    chmod 755 data
fi

# Arrêter les conteneurs existants
echo -e "${YELLOW}→ Arrêt des conteneurs existants...${NC}"
docker compose -f docker/docker-compose.yml down 2>/dev/null || true

# Construire les images
echo -e "${YELLOW}→ Construction des images Docker...${NC}"
docker compose -f docker/docker-compose.yml build --no-cache

# Démarrer les conteneurs
echo -e "${YELLOW}→ Démarrage des conteneurs...${NC}"
docker compose -f docker/docker-compose.yml up -d

# Attendre que les services soient prêts
echo -e "${YELLOW}→ Attente du démarrage des services...${NC}"
sleep 5

# Vérifier le statut
echo ""
echo -e "${GREEN}✓ Vérification du statut des conteneurs :${NC}"
docker compose -f docker/docker-compose.yml ps

echo ""
echo -e "${GREEN}=========================================${NC}"
echo -e "${GREEN}   Déploiement terminé avec succès !${NC}"
echo -e "${GREEN}=========================================${NC}"
echo ""
echo -e "Application disponible sur : ${YELLOW}http://localhost:8080${NC}"
echo -e "Page d'administration : ${YELLOW}http://localhost:8080/admin.php${NC}"
echo ""
echo "Commandes utiles :"
echo "  - Voir les logs : docker compose -f docker/docker-compose.yml logs -f"
echo "  - Arrêter : docker compose -f docker/docker-compose.yml down"
echo "  - Redémarrer : docker compose -f docker/docker-compose.yml restart"
echo "  - Rebuild : docker compose -f docker/docker-compose.yml up -d --build"
echo ""
