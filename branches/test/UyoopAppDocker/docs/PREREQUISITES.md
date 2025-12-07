# 📋 Installation des pré-requis - UyoopApp

## Docker et Docker Compose

### Vérifier si Docker est installé

```bash
docker --version
docker compose version
```

Si ces commandes fonctionnent, **vous pouvez passer directement au déploiement** :
```bash
make install
```

---

## Installation de Docker

### 🚀 Méthode 1 : Script automatique (recommandé)

```bash
# Pour Ubuntu/Debian
sudo ./install-docker.sh

# Puis se déconnecter/reconnecter OU exécuter :
newgrp docker

# Vérifier l'installation
docker --version
docker compose version
```

---

### 🔧 Méthode 2 : Installation manuelle

#### Ubuntu/Debian

```bash
# 1. Mettre à jour les paquets
sudo apt-get update

# 2. Installer les dépendances
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# 3. Ajouter la clé GPG Docker
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
    sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# 4. Ajouter le repository Docker
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# 5. Installer Docker
sudo apt-get update
sudo apt-get install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin

# 6. Ajouter votre utilisateur au groupe docker
sudo usermod -aG docker $USER

# 7. Activer et démarrer Docker
sudo systemctl enable docker
sudo systemctl start docker

# 8. Se déconnecter/reconnecter OU exécuter :
newgrp docker

# 9. Vérifier l'installation
docker --version
docker compose version
docker run hello-world
```

#### Fedora/CentOS/RHEL

```bash
# 1. Installer dnf-plugins-core
sudo dnf -y install dnf-plugins-core

# 2. Ajouter le repository Docker
sudo dnf config-manager --add-repo \
    https://download.docker.com/linux/fedora/docker-ce.repo

# 3. Installer Docker
sudo dnf install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin

# 4. Démarrer Docker
sudo systemctl start docker
sudo systemctl enable docker

# 5. Ajouter votre utilisateur au groupe docker
sudo usermod -aG docker $USER
newgrp docker
```

#### Arch Linux

```bash
sudo pacman -S docker docker-compose
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER
newgrp docker
```

---

### 🍎 macOS

```bash
# Télécharger et installer Docker Desktop
# https://docs.docker.com/desktop/install/mac-install/

# Ou avec Homebrew
brew install --cask docker

# Lancer Docker Desktop depuis Applications
```

---

### 🪟 Windows

```bash
# Télécharger et installer Docker Desktop
# https://docs.docker.com/desktop/install/windows-install/

# Ou avec Chocolatey
choco install docker-desktop

# Ou avec winget
winget install Docker.DockerDesktop
```

---

## Vérification de l'installation

```bash
# Version Docker
docker --version
# Devrait afficher : Docker version 24.x.x ou plus

# Version Docker Compose
docker compose version
# Devrait afficher : Docker Compose version v2.x.x ou plus

# Test Docker
docker run hello-world
# Devrait télécharger et exécuter une image de test

# Vérifier que Docker tourne
docker ps
# Devrait afficher une liste vide (ou vos conteneurs actifs)
```

---

## Problèmes courants

### "Permission denied" lors de l'exécution de docker

**Solution** : Ajouter votre utilisateur au groupe docker
```bash
sudo usermod -aG docker $USER
newgrp docker
# Ou se déconnecter/reconnecter
```

### "Cannot connect to the Docker daemon"

**Solution** : Démarrer le service Docker
```bash
sudo systemctl start docker
sudo systemctl enable docker
```

### Docker Compose V1 (docker-compose) au lieu de V2 (docker compose)

**Solution** : Installer docker-compose-plugin
```bash
sudo apt-get install docker-compose-plugin
```

### Erreur de proxy/firewall

**Solution** : Configurer le proxy Docker
```bash
sudo mkdir -p /etc/systemd/system/docker.service.d
sudo nano /etc/systemd/system/docker.service.d/http-proxy.conf
```

Ajouter :
```ini
[Service]
Environment="HTTP_PROXY=http://proxy.example.com:80"
Environment="HTTPS_PROXY=https://proxy.example.com:443"
Environment="NO_PROXY=localhost,127.0.0.1"
```

Puis :
```bash
sudo systemctl daemon-reload
sudo systemctl restart docker
```

---

## Après l'installation de Docker

Une fois Docker installé et vérifié, vous pouvez **déployer l'application** :

```bash
# Retour au répertoire du projet
cd /home/cj/gitdata/UyoopAppDocker

# Installation complète
make install

# Ou script manuel
./deploy.sh

# Ou Docker direct
docker compose up -d --build
```

L'application sera accessible sur : **http://localhost:8080**

---

## Resources supplémentaires

- **Documentation officielle Docker** : https://docs.docker.com/
- **Guide d'installation** : https://docs.docker.com/engine/install/
- **Docker Compose** : https://docs.docker.com/compose/
- **Post-installation** : https://docs.docker.com/engine/install/linux-postinstall/

---

## Alternative sans Docker

Si vous ne pouvez/voulez pas installer Docker, vous pouvez exécuter l'application **en mode traditionnel** :

```bash
# Pré-requis
sudo apt install -y php8.4 php8.4-sqlite3 php8.4-fpm nginx

# Configuration Nginx
sudo cp nginx.conf /etc/nginx/sites-available/uyoop
sudo ln -s /etc/nginx/sites-available/uyoop /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx

# Permissions
sudo chown -R www-data:www-data data/
sudo chmod -R 755 data/

# Accès
# http://localhost
```

Voir `README.md` section "Déploiement traditionnel" pour plus de détails.
