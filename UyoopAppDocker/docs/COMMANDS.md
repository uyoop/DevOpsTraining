# Commandes UyoopApp - Référence complète

## 🚀 Installation et démarrage

```bash
# Installation complète (recommandé pour première fois)
make install

# Déploiement avec script
./deploy.sh

# Docker manuel
docker compose up -d --build

# Afficher la structure du projet
./show-structure.sh
```

## 📦 Gestion Docker

```bash
# Démarrer l'application
make up
docker compose up -d

# Arrêter l'application
make down
docker compose down

# Redémarrer
make restart
docker compose restart

# Rebuild complet
make redeploy
docker compose down && docker compose up -d --build

# Mode développement (avec logs directs)
make dev
docker compose up --build
```

## 📊 Monitoring et logs

```bash
# Voir tous les logs en temps réel
make logs
docker compose logs -f

# Logs PHP uniquement
make logs-php
docker compose logs -f php

# Logs Nginx uniquement
make logs-nginx
docker compose logs -f nginx

# Statut des conteneurs
make status
docker compose ps

# Statistiques ressources
docker stats uyoop-nginx uyoop-php

# Healthcheck manuel
docker compose exec php /usr/local/bin/healthcheck.sh
```

## 🔍 Debugging

```bash
# Accéder au shell du conteneur PHP
make shell-php
docker compose exec php sh

# Accéder au shell du conteneur Nginx
make shell-nginx
docker compose exec nginx sh

# Inspecter un conteneur
docker inspect uyoop-php
docker inspect uyoop-nginx

# Voir les processus dans un conteneur
docker compose top php
```

## 💾 Backup et restauration

```bash
# Créer un backup de la base de données
make backup

# Restaurer depuis un backup
make restore FILE=backups/uyoop-20231203.db

# Backup manuel
cp data/uyoop.db backups/uyoop-$(date +%Y%m%d-%H%M%S).db

# Restaurer manuellement
cp backups/uyoop-20231203.db data/uyoop.db
make restart
```

## 🧪 Tests

```bash
# Lancer tous les tests
make test
./test.sh

# Test manuel de l'application
curl http://localhost:8080
curl http://localhost:8080/admin.php

# Test de l'API
curl -X POST http://localhost:8080/api/save \
  -H "Content-Type: application/json" \
  -d '{"org_name":"Test","project_type":"site_web"}'
```

## 🧹 Nettoyage

```bash
# Nettoyer conteneurs et volumes
make clean
docker compose down -v

# Nettoyer images Docker
docker image prune -a

# Nettoyer tout le système Docker
docker system prune -a --volumes

# Désinstaller complètement
make uninstall
```

## 🤖 Ansible - Déploiement distant

```bash
# Éditer l'inventaire des serveurs
nano ansible/inventory.ini

# Tester la connexion
cd ansible && ansible all -m ping

# Déployer sur tous les serveurs
cd ansible && ansible-playbook deploy.yml

# Déployer sur un serveur spécifique
cd ansible && ansible-playbook deploy.yml --limit production

# Dry-run (vérifier sans exécuter)
cd ansible && ansible-playbook deploy.yml --check

# Avec prompt mot de passe sudo
cd ansible && ansible-playbook deploy.yml --ask-become-pass

# Voir les logs sur serveur distant
cd ansible && ansible uyoop_servers -m shell -a "docker compose -f /opt/uyoop/docker-compose.yml logs --tail=50"

# Redémarrer sur serveur distant
cd ansible && ansible uyoop_servers -m shell -a "docker compose -f /opt/uyoop/docker-compose.yml restart"
```

## 🔧 Configuration

```bash
# Créer le fichier .env
cp .env.example .env
nano .env

# Voir la configuration active
cat .env
docker compose config

# Changer le port (éditer docker-compose.yml)
nano docker-compose.yml
# Modifier : ports: - "9090:80"

# Variables d'environnement disponibles
# HTTP_PORT, PHP_MEMORY_LIMIT, PHP_UPLOAD_MAX_FILESIZE, TZ
```

## 📦 Environnements multiples

```bash
# Développement (défaut)
docker compose up -d

# Production (configuration optimisée)
docker compose -f docker-compose.prod.yml up -d
docker compose -f docker-compose.prod.yml logs -f
docker compose -f docker-compose.prod.yml down
```

## 🔐 Sécurité et production

```bash
# Limiter l'accès au localhost uniquement
# Éditer docker-compose.yml :
# ports: - "127.0.0.1:8080:80"

# Vérifier les permissions du répertoire data/
ls -la data/
sudo chown -R 33:33 data/  # 33 = www-data
sudo chmod -R 755 data/

# Voir les ports ouverts
sudo netstat -tulpn | grep docker

# Configurer le firewall (UFW)
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw enable
```

## 📈 Performance

```bash
# Voir l'utilisation des ressources
docker stats --no-stream uyoop-nginx uyoop-php

# Voir l'espace disque utilisé
docker system df

# Optimiser les images (rebuild)
docker compose build --no-cache

# Limiter les ressources (éditer docker-compose.yml)
# deploy:
#   resources:
#     limits:
#       cpus: '2'
#       memory: 1G
```

## 🌐 Réseau

```bash
# Lister les réseaux Docker
docker network ls

# Inspecter le réseau de l'application
docker network inspect uyoopappdocker_uyoop-network

# Voir les conteneurs sur le réseau
docker network inspect uyoopappdocker_uyoop-network | grep Name
```

## 🔄 Mise à jour

```bash
# Mettre à jour le code
git pull

# Rebuilder et redéployer
make redeploy
# ou
docker compose down
docker compose up -d --build

# Mettre à jour Docker
sudo apt update && sudo apt upgrade docker-ce docker-compose-plugin
```

## 📱 Accès à l'application

```bash
# Page principale
open http://localhost:8080
# ou
curl http://localhost:8080

# Administration
open http://localhost:8080/admin.php
# ou
curl http://localhost:8080/admin.php

# API endpoint
curl -X POST http://localhost:8080/api/save \
  -H "Content-Type: application/json" \
  -d @form-data.json

# Génération cahier des charges
open http://localhost:8080/generate?id=1
```

## 📚 Documentation

```bash
# Voir toutes les commandes Make
make help
make

# Lire les guides
cat QUICKSTART.md
cat README.md
cat DOCKER.md
cat ARCHITECTURE.md
cat ansible/README.md

# Guide visuel
./show-structure.sh
```

## 🆘 Aide et dépannage

```bash
# Problème de démarrage - voir les logs
make logs

# Problème de connexion - vérifier le statut
make status
docker compose ps

# Problème de port - trouver le processus
sudo lsof -i :8080
sudo netstat -tulpn | grep 8080

# Problème de permissions
sudo chown -R $(whoami):$(whoami) data/
sudo chmod -R 755 data/

# Redémarrage complet
make down
make clean
make install

# Vérifier Docker
docker --version
docker compose version
docker ps
docker images

# Récupérer après erreur
docker compose down -v
docker system prune -a
make install
```

## 💡 Astuces

```bash
# Alias utiles (ajouter à ~/.bashrc ou ~/.zshrc)
alias uyoop-start="cd /path/to/UyoopAppDocker && make up"
alias uyoop-stop="cd /path/to/UyoopAppDocker && make down"
alias uyoop-logs="cd /path/to/UyoopAppDocker && make logs"
alias uyoop-status="cd /path/to/UyoopAppDocker && make status"

# Watch logs en couleur
make logs | ccze -A

# Backup automatique (crontab)
crontab -e
# Ajouter : 0 2 * * * cd /path/to/UyoopAppDocker && make backup

# Monitoring continu
watch -n 5 'docker stats --no-stream uyoop-nginx uyoop-php'
```

## 📞 Support

- Documentation : `README.md`, `DOCKER.md`, `ARCHITECTURE.md`
- Logs : `make logs`
- Tests : `make test`
- Statut : `make status`
- Aide Make : `make help`
