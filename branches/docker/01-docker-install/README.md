# TP 1 : Installation de Docker

## 🎯 Objectifs

- Installer Docker Engine sur Ubuntu/Debian
- Configurer Docker pour l'utilisation sans sudo
- Vérifier l'installation avec des commandes de base
- Comprendre l'architecture Docker

## 📋 Prérequis

- Ubuntu 20.04+ ou Debian 11+
- Accès sudo
- Connexion Internet

## 🚀 Installation

### Méthode 1 : Script d'installation automatique

```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
```

### Méthode 2 : Installation manuelle

```bash
# Mise à jour des paquets
sudo apt-get update

# Installation des dépendances
sudo apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# Ajout de la clé GPG officielle Docker
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Configuration du repository Docker
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Installation Docker Engine
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

## ⚙️ Configuration Post-Installation

### Ajouter votre utilisateur au groupe docker

```bash
sudo usermod -aG docker $USER
newgrp docker
```

### Démarrer et activer Docker

```bash
sudo systemctl start docker
sudo systemctl enable docker
```

## ✅ Vérification

```bash
# Version Docker
docker --version

# Informations système
docker info

# Test avec hello-world
docker run hello-world

# Liste des conteneurs
docker ps -a

# Liste des images
docker images
```

## 📚 Concepts Clés

- **Docker Engine** : Moteur pour exécuter les conteneurs
- **Docker CLI** : Interface en ligne de commande
- **Containerd** : Runtime de conteneurs
- **Docker Daemon** : Service qui gère les conteneurs

## 🔍 Commandes Utiles

```bash
# Statut du service Docker
sudo systemctl status docker

# Logs Docker
sudo journalctl -u docker

# Désinstaller Docker
sudo apt-get purge docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo rm -rf /var/lib/docker
sudo rm -rf /var/lib/containerd
```

## 📖 Ressources

- [Documentation officielle Docker](https://docs.docker.com/engine/install/)
- [Post-installation steps](https://docs.docker.com/engine/install/linux-postinstall/)
