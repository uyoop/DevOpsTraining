# 🐳 Configuration Docker

Ce dossier contient tous les fichiers de configuration Docker.

## 📦 Fichiers

### **Dockerfile**
Image Docker personnalisée avec PHP 8.4-FPM Alpine et extension SQLite.

### **docker-compose.yml**
Configuration Docker Compose pour l'environnement de **développement**.
- Port : 8080
- Volumes en lecture/écriture
- Logs verbeux

### **docker-compose.prod.yml**
Configuration Docker Compose pour l'environnement de **production**.
- Port : 80
- Volumes en lecture seule pour le code
- Healthchecks activés
- Logs rotatifs
- Restart automatique

### **nginx.conf**
Configuration Nginx optimisée :
- Proxy FastCGI vers PHP-FPM
- Gestion des assets statiques
- Cache et compression
- Sécurité (blocage fichiers cachés)

### **healthcheck.sh**
Script de vérification de santé des conteneurs PHP-FPM.

## 🚀 Utilisation

### Depuis la racine du projet

#### Développement
```bash
docker compose -f docker/docker-compose.yml up -d
```

#### Production
```bash
docker compose -f docker/docker-compose.prod.yml up -d
```

### Via Make (recommandé)
```bash
# Développement
make up
make logs
make down

# Production
docker compose -f docker/docker-compose.prod.yml up -d
```

## 📝 Notes

- Les chemins sont relatifs (`..`) pour pointer vers la racine
- Deux réseaux isolés : dev et prod
- Volumes persistants pour `data/`
- Healthcheck uniquement en production

## 🔧 Personnalisation

### Changer le port
Éditez `docker-compose.yml` :
```yaml
ports:
  - "9090:80"  # Au lieu de 8080:80
```

### Modifier PHP
Éditez `Dockerfile` pour ajouter extensions ou configurer PHP.

## 🔙 Retour

- [INDEX.md](../INDEX.md) - Guide de navigation principal
- [docs/DOCKER.md](../docs/DOCKER.md) - Documentation Docker complète
