#!/bin/bash
# Script d'installation de Docker sur Debian/Ubuntu

set -e

echo "========================================="
echo "   Installation de Docker"
echo "========================================="
echo ""

# Couleurs
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Vérifier si on est root ou avec sudo
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}Ce script doit être exécuté avec sudo${NC}"
    echo "Usage: sudo ./install-docker.sh"
    exit 1
fi

# Vérifier le système d'exploitation
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
else
    echo -e "${RED}Impossible de détecter le système d'exploitation${NC}"
    exit 1
fi

if [ "$OS" != "ubuntu" ] && [ "$OS" != "debian" ]; then
    echo -e "${YELLOW}Ce script est conçu pour Ubuntu/Debian${NC}"
    echo "Consultez https://docs.docker.com/engine/install/ pour votre système"
    exit 1
fi

echo -e "${YELLOW}→ Mise à jour des paquets...${NC}"
apt-get update

echo -e "${YELLOW}→ Installation des dépendances...${NC}"
apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

echo -e "${YELLOW}→ Ajout de la clé GPG Docker...${NC}"
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/${OS}/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

echo -e "${YELLOW}→ Ajout du repository Docker...${NC}"
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/${OS} \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

echo -e "${YELLOW}→ Installation de Docker...${NC}"
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo -e "${YELLOW}→ Démarrage de Docker...${NC}"
systemctl start docker
systemctl enable docker

echo -e "${YELLOW}→ Ajout de l'utilisateur au groupe docker...${NC}"
if [ -n "$SUDO_USER" ]; then
    usermod -aG docker $SUDO_USER
    echo -e "${GREEN}✓ Utilisateur $SUDO_USER ajouté au groupe docker${NC}"
else
    echo -e "${YELLOW}⚠ Exécutez manuellement: sudo usermod -aG docker \$USER${NC}"
fi

echo ""
echo -e "${GREEN}=========================================${NC}"
echo -e "${GREEN}   ✓ Docker installé avec succès !${NC}"
echo -e "${GREEN}=========================================${NC}"
echo ""
echo "Versions installées :"
docker --version
docker compose version
echo ""
echo -e "${YELLOW}⚠ IMPORTANT : Déconnectez-vous et reconnectez-vous pour que les changements prennent effet${NC}"
echo "Ou exécutez : newgrp docker"
echo ""
