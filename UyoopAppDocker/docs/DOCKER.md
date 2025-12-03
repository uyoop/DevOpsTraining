# Documentation de déploiement Docker - UyoopApp

## Vue d'ensemble

Cette application PHP est conteneurisée avec Docker pour faciliter le déploiement sur n'importe quel environnement (développement, staging, production).

## Architecture

```
┌─────────────────┐
│   Nginx (80)    │ ← Port 8080 (externe)
│  Serveur Web    │
└────────┬────────┘
         │
         ↓
┌─────────────────┐
│  PHP-FPM (9000) │
│   PHP 8.4 +     │
│   SQLite        │
└────────┬────────┘
         │
         ↓
┌─────────────────┐
│   Volume data/  │
│  uyoop.db       │
└─────────────────┘
```

## Prérequis

### Installation Docker sur Ubuntu/Debian
```bash
# Mise à jour du système
sudo apt update && sudo apt upgrade -y

# Installation des dépendances
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common

# Ajout de la clé GPG Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Ajout du repository Docker
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Installation Docker
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Ajouter l'utilisateur au groupe docker
sudo usermod -aG docker $USER
newgrp docker

# Vérifier l'installation
docker --version
docker compose version
```

## Déploiement local

### Méthode 1 : Script automatique (recommandé)
```bash
./deploy.sh
```

### Méthode 2 : Commandes manuelles
```bash
# Créer le répertoire data
mkdir -p data

# Construire les images
docker compose build

# Démarrer les conteneurs
docker compose up -d

# Vérifier le statut
docker compose ps
```

## Déploiement sur serveur distant

### Option 1 : Copie manuelle
```bash
# Sur votre machine locale
scp -r /path/to/UyoopAppDocker user@server:/opt/

# Sur le serveur
cd /opt/UyoopAppDocker
./deploy.sh
```

### Option 2 : Avec Git
```bash
# Sur le serveur
cd /opt
git clone <repository-url> UyoopAppDocker
cd UyoopAppDocker
./deploy.sh
```

### Option 3 : Avec Ansible (automatisé)
Voir `ansible/README.md` pour les instructions détaillées.

## Configuration

### Variables d'environnement
Créez un fichier `.env` à partir de `.env.example` :
```bash
cp .env.example .env
nano .env
```

Modifiez les valeurs selon vos besoins :
- `HTTP_PORT` : Port externe (défaut: 8080)
- `PHP_MEMORY_LIMIT` : Limite mémoire PHP
- `PHP_UPLOAD_MAX_FILESIZE` : Taille max des uploads

### Modification du docker-compose.yml
Pour utiliser les variables d'environnement, modifiez `docker-compose.yml` :
```yaml
services:
  nginx:
    ports:
      - "${HTTP_PORT:-8080}:80"
```

## Gestion de l'application

### Commandes essentielles

```bash
# Démarrer
docker compose up -d

# Arrêter
docker compose down

# Redémarrer
docker compose restart

# Voir les logs
docker compose logs -f

# Voir les logs d'un service spécifique
docker compose logs -f php
docker compose logs -f nginx

# Rebuilder après modifications
docker compose up -d --build

# Voir le statut des conteneurs
docker compose ps

# Accéder au shell du conteneur PHP
docker compose exec php sh

# Accéder au shell du conteneur Nginx
docker compose exec nginx sh
```

### Commandes de maintenance

```bash
# Nettoyer les images inutilisées
docker system prune -a

# Voir l'utilisation disque
docker system df

# Backup de la base de données
docker compose exec php sh -c "cp /var/www/html/data/uyoop.db /var/www/html/data/uyoop.db.backup"

# Ou depuis l'hôte
cp data/uyoop.db data/uyoop.db.backup-$(date +%Y%m%d)
```

## Surveillance

### Vérifier que l'application fonctionne
```bash
# Tester l'accès HTTP
curl http://localhost:8080

# Vérifier les processus
docker compose top

# Statistiques en temps réel
docker stats
```

### Logs
```bash
# Logs en temps réel
docker compose logs -f

# Logs des 100 dernières lignes
docker compose logs --tail=100

# Logs avec timestamp
docker compose logs -f --timestamps
```

## Production

### Recommandations de sécurité

1. **Utiliser un reverse proxy (Nginx/Traefik)**
```nginx
server {
    listen 80;
    server_name votre-domaine.com;
    
    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

2. **Activer HTTPS avec Let's Encrypt**
```bash
sudo apt install certbot python3-certbot-nginx
sudo certbot --nginx -d votre-domaine.com
```

3. **Firewall**
```bash
# UFW
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw enable

# iptables
sudo iptables -A INPUT -p tcp --dport 80 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 443 -j ACCEPT
```

4. **Limiter l'accès au port Docker**
Modifiez `docker-compose.yml` :
```yaml
ports:
  - "127.0.0.1:8080:80"  # Accessible uniquement en local
```

5. **Backup automatique**
Créez un cron job :
```bash
crontab -e
# Ajouter :
0 2 * * * cp /opt/UyoopAppDocker/data/uyoop.db /opt/backups/uyoop-$(date +\%Y\%m\%d).db
```

### Monitoring avec Docker stats
```bash
# Créer un script de monitoring
cat > monitor.sh << 'EOF'
#!/bin/bash
while true; do
  clear
  echo "=== Status UyoopApp ==="
  docker compose ps
  echo ""
  echo "=== Stats ==="
  docker stats --no-stream uyoop-nginx uyoop-php
  sleep 5
done
EOF

chmod +x monitor.sh
./monitor.sh
```

## Dépannage

### L'application ne démarre pas
```bash
# Vérifier les logs
docker compose logs

# Vérifier les ports
sudo netstat -tulpn | grep 8080

# Reconstruire complètement
docker compose down -v
docker compose up -d --build
```

### Problèmes de permissions sur data/
```bash
# Depuis l'hôte
sudo chown -R 33:33 data/  # UID 33 = www-data
sudo chmod -R 755 data/
```

### Base de données corrompue
```bash
# Restaurer depuis le backup
cp data/uyoop.db.backup data/uyoop.db
docker compose restart
```

### Conteneur crash en boucle
```bash
# Voir les logs du crash
docker compose logs php --tail=50

# Accéder au conteneur pour debug
docker compose run --rm php sh
```

## Désinstallation

```bash
# Arrêter et supprimer les conteneurs
docker compose down

# Supprimer les volumes (⚠️ perte de données)
docker compose down -v

# Supprimer les images
docker rmi uyoopappdocker-php nginx:alpine

# Nettoyer complètement Docker
docker system prune -a --volumes
```

## Performance

### Optimisations Docker

1. **Multi-stage build** (déjà implémenté dans le Dockerfile)
2. **Layer caching** : Organiser le Dockerfile pour maximiser le cache
3. **Volume tmpfs** pour les fichiers temporaires :
```yaml
volumes:
  - type: tmpfs
    target: /tmp
```

### Optimisations PHP-FPM

Modifiez le Dockerfile pour ajuster les paramètres :
```dockerfile
RUN echo "pm.max_children = 20" >> /usr/local/etc/php-fpm.d/www.conf && \
    echo "pm.start_servers = 5" >> /usr/local/etc/php-fpm.d/www.conf && \
    echo "pm.min_spare_servers = 5" >> /usr/local/etc/php-fpm.d/www.conf && \
    echo "pm.max_spare_servers = 10" >> /usr/local/etc/php-fpm.d/www.conf
```

## Support

Pour plus d'informations :
- Documentation Docker : https://docs.docker.com/
- Documentation Docker Compose : https://docs.docker.com/compose/
- Documentation PHP-FPM : https://www.php.net/manual/fr/install.fpm.php
