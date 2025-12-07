#!/bin/bash

# ==========================================
# Script d'installation BookStack Production
# ==========================================

set -e

echo "🚀 Installation BookStack Production Sécurisé"
echo "=============================================="

# Vérifier les prérequis
command -v docker >/dev/null 2>&1 || { echo "❌ Docker n'est pas installé"; exit 1; }
command -v docker-compose >/dev/null 2>&1 || command -v docker compose >/dev/null 2>&1 || { echo "❌ Docker Compose n'est pas installé"; exit 1; }

# Créer les dossiers nécessaires
echo "📁 Création des dossiers..."
mkdir -p secrets
mkdir -p config/{traefik/dynamic,authelia,mysql,prometheus}
mkdir -p backups

# Générer les secrets
echo "🔐 Génération des secrets..."
if [ ! -f secrets/db_root_password.txt ]; then
    openssl rand -base64 32 > secrets/db_root_password.txt
    echo "✅ Mot de passe root DB généré"
fi

if [ ! -f secrets/db_password.txt ]; then
    openssl rand -base64 32 > secrets/db_password.txt
    echo "✅ Mot de passe DB généré"
fi

if [ ! -f secrets/mail_password.txt ]; then
    echo "your-mail-password" > secrets/mail_password.txt
    echo "⚠️  Mot de passe mail par défaut (à modifier dans secrets/mail_password.txt)"
fi

if [ ! -f secrets/backup_password.txt ]; then
    openssl rand -base64 32 > secrets/backup_password.txt
    echo "✅ Mot de passe backup généré"
fi

if [ ! -f secrets/grafana_password.txt ]; then
    openssl rand -base64 32 > secrets/grafana_password.txt
    echo "✅ Mot de passe Grafana généré"
fi

# Permissions
chmod 600 secrets/*

# Copier .env.example si .env n'existe pas
if [ ! -f .env ]; then
    cp .env.example .env
    echo "⚠️  Fichier .env créé, MODIFIEZ-LE avec vos valeurs !"
fi

# Configuration UFW
echo "🔥 Configuration du pare-feu UFW..."
sudo ufw allow 22/tcp comment 'SSH'
sudo ufw allow 80/tcp comment 'HTTP'
sudo ufw allow 443/tcp comment 'HTTPS'
sudo ufw --force enable
echo "✅ Pare-feu configuré"

# Installation Fail2Ban
echo "🛡️  Installation Fail2Ban..."
if ! command -v fail2ban-client >/dev/null 2>&1; then
    sudo apt update
    sudo apt install -y fail2ban
    sudo systemctl enable fail2ban
    sudo systemctl start fail2ban
    echo "✅ Fail2Ban installé et activé"
else
    echo "✅ Fail2Ban déjà installé"
fi

# Créer les réseaux Docker
echo "🌐 Création des réseaux Docker..."
docker network create proxy 2>/dev/null || echo "Réseau proxy existe déjà"
docker network create backend 2>/dev/null || echo "Réseau backend existe déjà"
docker network create database 2>/dev/null || echo "Réseau database existe déjà"

echo ""
echo "✅ Installation terminée !"
echo ""
echo "📝 Prochaines étapes :"
echo "1. Modifiez le fichier .env avec vos paramètres"
echo "2. Modifiez config/traefik/traefik.yml avec votre email"
echo "3. Configurez Cloudflare DNS API token"
echo "4. Lancez : docker-compose up -d"
echo ""
echo "🔐 Mots de passe générés dans le dossier secrets/"
echo "📖 Consultez le README.md pour plus d'informations"
