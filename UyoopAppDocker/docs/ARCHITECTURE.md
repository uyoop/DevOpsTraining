# Architecture UyoopApp - Vue d'ensemble

## Diagramme d'architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      CLIENT (Navigateur)                     │
│                   http://localhost:8080                      │
└────────────────────────────┬────────────────────────────────┘
                             │
                             │ HTTP
                             ▼
┌─────────────────────────────────────────────────────────────┐
│                   CONTENEUR NGINX (Alpine)                   │
│                          Port 80                             │
│  ┌────────────────────────────────────────────────────────┐ │
│  │  • Serveur web                                         │ │
│  │  • Reverse proxy vers PHP-FPM                          │ │
│  │  • Gestion des fichiers statiques (CSS, JS, images)   │ │
│  │  • Configuration: nginx.conf                           │ │
│  └────────────────────────────────────────────────────────┘ │
└────────────────────────────┬────────────────────────────────┘
                             │
                             │ FastCGI (port 9000)
                             ▼
┌─────────────────────────────────────────────────────────────┐
│              CONTENEUR PHP-FPM (Alpine 8.4)                  │
│                          Port 9000                           │
│  ┌────────────────────────────────────────────────────────┐ │
│  │  • PHP 8.4-FPM                                         │ │
│  │  • Extension PDO SQLite                                │ │
│  │  • Gestion de la logique métier                        │ │
│  │  • Healthcheck intégré                                 │ │
│  └────────────────────────────────────────────────────────┘ │
└────────────────────────────┬────────────────────────────────┘
                             │
                             │ PDO
                             ▼
┌─────────────────────────────────────────────────────────────┐
│                     VOLUME DATA (persistant)                 │
│                        ./data/uyoop.db                       │
│  ┌────────────────────────────────────────────────────────┐ │
│  │  • Base de données SQLite                              │ │
│  │  • Persistance des formulaires                         │ │
│  │  • Sauvegardable facilement                            │ │
│  └────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

## Structure des fichiers de l'application

```
UyoopAppDocker/
│
├── 🐳 CONTENEURISATION
│   ├── Dockerfile                    # Image PHP avec SQLite
│   ├── docker-compose.yml            # Configuration développement
│   ├── docker-compose.prod.yml       # Configuration production
│   ├── nginx.conf                    # Configuration Nginx
│   ├── healthcheck.sh                # Script de santé conteneur
│   ├── .dockerignore                 # Exclusions Docker
│   └── .env.example                  # Variables d'environnement
│
├── 🚀 DÉPLOIEMENT
│   ├── deploy.sh                     # Script déploiement automatique
│   ├── test.sh                       # Script de tests
│   ├── Makefile                      # Commandes simplifiées
│   └── ansible/                      # Automatisation Ansible
│       ├── deploy.yml                # Playbook de déploiement
│       ├── inventory.ini             # Inventaire des serveurs
│       ├── ansible.cfg               # Configuration Ansible
│       └── README.md                 # Documentation Ansible
│
├── 📱 APPLICATION
│   ├── public/                       # Racine web publique
│   │   ├── index.php                 # Page principale + routeur
│   │   ├── admin.php                 # Page d'administration
│   │   └── assets/
│   │       ├── app.js                # Logique front-end
│   │       ├── style.css             # Styles
│   │       └── uyoop-logo.png        # Logo
│   │
│   └── src/                          # Logique back-end
│       ├── db.php                    # Connexion SQLite
│       ├── api_save.php              # API sauvegarde
│       └── generate.php              # Génération cahier charges
│
├── 💾 DONNÉES
│   └── data/                         # Base de données (volume)
│       └── uyoop.db                  # SQLite (créé auto)
│
└── 📚 DOCUMENTATION
    ├── README.md                     # Documentation principale
    ├── DOCKER.md                     # Documentation Docker
    └── ARCHITECTURE.md               # Ce fichier
```

## Flux de données

### 1. Affichage du formulaire
```
Client → Nginx → index.php → HTML/CSS/JS
```

### 2. Sauvegarde d'un formulaire
```
Client (JS) → POST /api/save
            → Nginx → PHP-FPM
            → api_save.php
            → PDO → SQLite (data/uyoop.db)
            → JSON response avec ID
```

### 3. Génération du cahier des charges
```
Client → GET /generate?id=X
       → Nginx → PHP-FPM
       → generate.php
       → PDO → SQLite (lecture)
       → HTML généré
```

### 4. Page d'administration
```
Client → GET /admin.php
       → Nginx → PHP-FPM
       → admin.php
       → PDO → SQLite (liste)
       → HTML tableau des formulaires
```

## Technologies utilisées

### Backend
- **PHP 8.4** : Langage serveur
- **PHP-FPM** : Gestionnaire de processus PHP
- **PDO** : Abstraction base de données
- **SQLite 3** : Base de données légère

### Frontend
- **HTML5** : Structure
- **CSS3** : Styles (Inter font, responsive)
- **Vanilla JavaScript** : Logique client (aucune dépendance)

### Infrastructure
- **Docker** : Conteneurisation
- **Docker Compose** : Orchestration multi-conteneurs
- **Nginx** : Serveur web et reverse proxy
- **Alpine Linux** : OS léger pour conteneurs

### DevOps (optionnel)
- **Ansible** : Automatisation déploiement
- **Make** : Simplification commandes
- **Bash** : Scripts utilitaires

## Sécurité

### Mesures implémentées

1. **Isolation des conteneurs**
   - Network bridge isolé
   - Pas de ports PHP-FPM exposés directement

2. **Permissions fichiers**
   - www-data (UID 33) propriétaire des fichiers
   - Répertoire data accessible en écriture uniquement

3. **Protection Nginx**
   - Blocage accès fichiers cachés (.)
   - Blocage accès direct au répertoire data/
   - Headers de sécurité

4. **PHP**
   - Déclarations strictes (strict_types)
   - Échappement HTML (htmlspecialchars)
   - Prepared statements PDO (injection SQL)

### Recommandations production

1. **HTTPS obligatoire** (Let's Encrypt + Certbot)
2. **Firewall** (UFW ou iptables)
3. **Limiter accès admin** (IP whitelisting)
4. **Backups automatiques** (cron)
5. **Monitoring** (logs, healthchecks)
6. **Variables d'environnement** pour secrets
7. **Rate limiting** (fail2ban)

## Scalabilité

### Vertical scaling (ressources)
```yaml
# docker-compose.yml
services:
  php:
    deploy:
      resources:
        limits:
          cpus: '2'
          memory: 1G
```

### Horizontal scaling (réplication)
```bash
# Plusieurs instances PHP-FPM
docker compose up -d --scale php=3
```

### Load balancing
Ajouter un load balancer (Traefik, HAProxy) devant Nginx

## Monitoring

### Healthchecks
```bash
# Vérifier l'état des conteneurs
docker compose ps

# Logs détaillés
docker compose logs -f

# Healthcheck manuel
docker compose exec php /usr/local/bin/healthcheck.sh
```

### Métriques
```bash
# Statistiques ressources
docker stats uyoop-nginx uyoop-php

# Espace disque
docker system df
```

## Backup & Restauration

### Backup
```bash
# Automatique
make backup

# Manuel
cp data/uyoop.db backups/uyoop-$(date +%Y%m%d).db
```

### Restauration
```bash
# Avec Make
make restore FILE=backups/uyoop-20231203.db

# Manuel
cp backups/uyoop-20231203.db data/uyoop.db
docker compose restart
```

## Environnements

### Développement
- Port 8080
- Logs verbeux
- Hot reload avec volumes
- Commande : `docker compose up`

### Production
- Port 80 (+ 443 HTTPS)
- Logs rotatifs
- Volumes read-only pour code
- Restart policy: always
- Commande : `docker compose -f docker-compose.prod.yml up -d`

## Performance

### Optimisations appliquées

1. **Docker**
   - Images Alpine (légères)
   - Multi-stage build
   - Layer caching optimisé

2. **Nginx**
   - FastCGI caching
   - Gzip compression
   - Cache statique assets (30 jours)

3. **PHP-FPM**
   - Process manager optimisé
   - OpCache activé par défaut
   - Memory limit adapté

4. **SQLite**
   - WAL mode (Write-Ahead Logging)
   - Index sur colonnes fréquentes
   - Pas de connexion persistante

## Maintenance

### Mise à jour de l'application
```bash
git pull
docker compose up -d --build
```

### Mise à jour de Docker
```bash
sudo apt update && sudo apt upgrade docker-ce docker-compose-plugin
```

### Nettoyage
```bash
# Images non utilisées
docker image prune -a

# Système complet
docker system prune -a --volumes
```

## Support

- **Documentation principale** : `README.md`
- **Guide Docker** : `DOCKER.md`
- **Guide Ansible** : `ansible/README.md`
- **Tests** : `./test.sh`
- **Logs** : `docker compose logs -f`

## Contributeurs

Pour contribuer :
1. Fork le projet
2. Créer une branche (`git checkout -b feature/amelioration`)
3. Commit (`git commit -am 'Ajout fonctionnalité'`)
4. Push (`git push origin feature/amelioration`)
5. Pull Request

## Licence

Ce projet est sous licence [À définir]
