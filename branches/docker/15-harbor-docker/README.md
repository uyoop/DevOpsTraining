# TP15 - Harbor Docker 🏭

Registry sécurisé de conteneurs avec Harbor pour la gestion d'images Docker à grande échelle.

## 📋 Table des Matières

- [Vue d'ensemble](#vue-densemble)
- [Architecture](#architecture)
- [Prérequis](#prérequis)
- [Installation](#installation)
- [Configuration](#configuration)
- [Utilisation](#utilisation)
- [Gestion des images](#gestion-des-images)
- [Sécurité & Scanning](#sécurité--scanning)
- [Dépannage](#dépannage)
- [Ressources](#ressources)

## 🎯 Vue d'ensemble

Harbor est un registre de conteneurs open-source qui offre :
- **Sécurité** : Scanning des vulnérabilités avec Trivy
- **Gestion** : Interface Web pour gérer projets et images
- **Performance** : Cache Redis et stockage optimisé
- **Intégration** : Compatibilité Docker, Kubernetes, Helm
- **Audit** : Logs complets des actions

### Composants

| Service | Port | Description |
|---------|------|-------------|
| **Nginx** | 80/443 | Reverse proxy |
| **Core** | 8080 | API et logique applicative |
| **Registry** | 5000 | Registre Docker |
| **PostgreSQL** | 5432 | Base de données |
| **Redis** | 6379 | Cache et jobs |
| **Portal** | 8080 | Interface Web |
| **JobService** | - | Jobs asynchrones |
| **Trivy** | - | Scanning vulnérabilités |

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────┐
│              Docker Clients                          │
│   (docker login, push, pull)                        │
└──────────────────┬──────────────────────────────────┘
                   │
        ┌──────────▼──────────┐
        │  Nginx :80 :443     │
        │  (Reverse Proxy)    │
        └────┬───┬───┬────┐   │
             │   │   │    │   │
    ┌────────┴─┐ │   │    │   │
    │ Portal   │ │   │    │   │
    │ (Web UI) │ │   │    │   │
    └──────────┘ │   │    │   │
                 │   │    │   │
    ┌────────────▼─┐ │    │   │
    │    Core      │ │    │   │
    │   (API)      │ │    │   │
    └──────────────┘ │    │   │
                     │    │   │
    ┌────────────────▼──┐ │   │
    │    Registry       │ │   │
    │  (Docker Reg)     │ │   │
    └───────────────────┘ │   │
                          │   │
    ┌─────────────────────▼───┴──┐
    │   JobService (async jobs)   │
    │   Trivy (security scanning) │
    └─────────┬───────────────────┘
              │
    ┌─────────┴─────────┬───────────────┐
    │                   │               │
┌───▼───┐       ┌───────▼────┐   ┌─────▼──┐
│ Redis │       │ PostgreSQL  │   │ Storage│
│ Cache │       │ Database    │   │ (Files)│
└───────┘       └─────────────┘   └────────┘
```

## ✅ Prérequis

- Docker Engine 20.10+
- Docker Compose 2.0+
- 4+ CPU cores
- 8GB+ RAM
- 50GB+ espace disque libre
- Accès internet (pour Trivy)

## 🚀 Installation

### 1. Cloner et configurer

```bash
cd 15-harbor-docker
cp .env.example .env
```

### 2. Configurer les variables

```bash
nano .env
```

**Variables essentielles** :

```env
# Passwords (CHANGE THEM!)
DB_PASSWORD=very_secure_password_32_chars_minimum
HARBOR_ADMIN_PASSWORD=harbor_admin_password
CORE_SECRET=generated_secret
JOBSERVICE_SECRET=generated_secret
```

### 3. Générer les secrets

```bash
# Générer des secrets sécurisés
openssl rand -base64 32
```

### 4. Démarrer Harbor

```bash
docker compose up -d
```

### 5. Attendre que tout soit prêt

```bash
# Vérifier les logs
docker compose logs -f

# Vérifier les conteneurs
docker compose ps
```

### 6. Accéder à Harbor

- **URL** : http://localhost
- **Login** : admin / votre_mot_de_passe
- **Registry** : localhost:80

## ⚙️ Configuration

### Interface Web

1. Login à http://localhost
2. Aller dans **Administration > Projects**
3. Créer un nouveau projet (ex: monprojet)
4. Configurer les permissions RBAC

### Scan Trivy

Trivy scanne automatiquement les images poussées pour déterminer les vulnérabilités :

1. Push une image
2. Aller dans **Projects > monprojet > Images**
3. Cliquer sur l'image
4. Voir les résultats du scan en bas

## 📦 Gestion des Images

### Login à Harbor

```bash
docker login localhost
# Username: admin
# Password: votre_mot_de_passe
```

### Créer une image de test

```bash
# Créer Dockerfile
cat > Dockerfile << EOF
FROM nginx:alpine
COPY index.html /usr/share/nginx/html/
EXPOSE 80
EOF

# Créer index.html
cat > index.html << EOF
<!DOCTYPE html>
<html>
<body><h1>Test Harbor</h1></body>
</html>
EOF

# Construire l'image
docker build -t myapp:1.0 .
```

### Taguer pour Harbor

```bash
docker tag myapp:1.0 localhost/monprojet/myapp:1.0
```

### Pousser vers Harbor

```bash
docker push localhost/monprojet/myapp:1.0
```

### Vérifier dans Harbor

1. Aller dans **Projects > monprojet**
2. Voir l'image `myapp:1.0`
3. Cliquer pour voir les détails et résultats du scan

### Puller depuis Harbor

```bash
docker pull localhost/monprojet/myapp:1.0
docker run -p 8000:80 localhost/monprojet/myapp:1.0
```

## 🔒 Sécurité & Scanning

### Trivy Integration

Harbor intègre Trivy pour scanner automatiquement les vulnérabilités :

- **Trivy Database** : Mise à jour automatique
- **Scanning Automatique** : À chaque push
- **Rapports Détaillés** : Gravité et CVE

### Résultats de Scan

| Sévérité | Couleur | Action |
|----------|--------|--------|
| 🔴 Critical | Rouge | Bloquer le déploiement |
| 🟠 High | Orange | Vérifier et approuver |
| 🟡 Medium | Jaune | Surveiller |
| 🟢 Low | Vert | Acceptable |
| ⚪ Unknown | Gris | Investiguer |

### Bloquer les images non-sécurisées

1. Aller dans **Administration > Configuration**
2. Activer **Prevent vulnerable images from running**
3. Configurer les seuils

## 🔧 Dépannage

### Harbor ne démarre pas

```bash
# Vérifier les logs
docker compose logs

# Vérifier les conteneurs
docker compose ps

# Restart
docker compose restart
```

### Cannot login to Harbor

```bash
# Vérifier les credentials
# Aller dans Administration > System Settings
# Vérifier HARBOR_ADMIN_PASSWORD dans .env

# Réinitialiser le mot de passe
docker compose exec core curl -X PATCH http://localhost:8080/api/v2.0/users/1 \
  -H 'Content-Type: application/json' \
  -d '{"password":"newpassword"}'
```

### Pas de connectivité au registry

```bash
# Vérifier que le registry démarre
docker compose logs registry

# Tester la connectivité
curl -v http://localhost:80/v2/

# Redémarrer
docker compose restart registry
```

### PostgreSQL ne démarre pas

```bash
# Vérifier les permissions
sudo chown -R 999:999 postgresql-data

# Restart
docker compose restart postgresql
```

### Pas assez d'espace disque

```bash
# Nettoyer les anciennes images
docker compose exec registry rm -rf /storage/*

# Ou augmenter l'espace disque disponible
df -h
```

## 📚 Ressources

### Documentation Officielle

- [Harbor Documentation](https://goharbor.io/docs/)
- [Harbor GitHub](https://github.com/goharbor/harbor)
- [Trivy Documentation](https://aquasecurity.github.io/trivy/)

### Tutoriels

- [Article Stéphane Robert](https://blog.stephane-robert.info/docs/developper/artefacts/harbor/)
- [Harbor Quick Start](https://goharbor.io/docs/2.9.0/install-config/quick-start-installation/)
- [Using Harbor with Docker](https://goharbor.io/docs/2.9.0/working-with-images/)

### CLI Commands

```bash
# Login
docker login registry.harbor.io

# Push
docker push registry.harbor.io/project/image:tag

# Pull
docker pull registry.harbor.io/project/image:tag

# List repositories
curl -u admin:password http://localhost:80/api/v2.0/projects

# Search images
curl -u admin:password http://localhost:80/api/v2.0/search\?q\=nginx
```

## 🎓 Objectifs Pédagogiques

Après ce TP, vous serez capable de :

✅ Déployer Harbor en tant que registre privé  
✅ Configurer les projets et permissions RBAC  
✅ Pousser et puller des images vers Harbor  
✅ Scanner les images pour détecter les vulnérabilités  
✅ Monitorer les logs et activités  
✅ Gérer l'authentification et la sécurité  
✅ Intégrer Harbor dans des pipelines CI/CD  

## 🚀 Prochaines Étapes

1. **TP16 - Harbor Production** : Architecture enterprise-grade
2. Intégrer avec Kubernetes
3. Ajouter LDAP/OIDC authentication
4. Configurer la réplication entre registres
5. Intégrer avec Jenkins/GitLab CI

## 📝 Licence

Ce projet fait partie du repository CJ-DEVOPS - Portfolio DevOps.

---

**Auteur** : CJenkins-AFPA  
**Dernière mise à jour** : Décembre 2024  
**Version Harbor** : 2.9.1
