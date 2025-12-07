# 📂 Index - Guide de navigation UyoopApp

## 🚀 Démarrage rapide

**Vous voulez démarrer rapidement ?**  
👉 Consultez **[docs/QUICKSTART.md](docs/QUICKSTART.md)**

---

## 📚 Documentation complète

### Pour les débutants
- **[docs/QUICKSTART.md](docs/QUICKSTART.md)** - Démarrage en 3 commandes
- **[docs/PREREQUISITES.md](docs/PREREQUISITES.md)** - Installation de Docker

### Guides principaux
- **[README.md](README.md)** - Vue d'ensemble du projet
- **[docs/DOCKER.md](docs/DOCKER.md)** - Guide Docker complet
- **[docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)** - Architecture technique détaillée
- **[docs/SUMMARY.md](docs/SUMMARY.md)** - Résumé complet du projet

### Références
- **[docs/COMMANDS.md](docs/COMMANDS.md)** - Toutes les commandes disponibles
- **[docs/CHANGELOG.md](docs/CHANGELOG.md)** - Historique des versions

---

## 🛠️ Scripts disponibles

### Scripts principaux
- **[scripts/deploy.sh](scripts/deploy.sh)** - Déploiement automatique
- **[scripts/test.sh](scripts/test.sh)** - Suite de tests automatiques
- **[scripts/install-docker.sh](scripts/install-docker.sh)** - Installation Docker
- **[scripts/show-structure.sh](scripts/show-structure.sh)** - Affichage de la structure

### Makefile
```bash
make help    # Voir toutes les commandes disponibles
```

---

## 🐳 Configuration Docker

### Fichiers Docker
- **[docker/Dockerfile](docker/Dockerfile)** - Image PHP avec SQLite
- **[docker/docker-compose.yml](docker/docker-compose.yml)** - Configuration développement
- **[docker/docker-compose.prod.yml](docker/docker-compose.prod.yml)** - Configuration production
- **[docker/nginx.conf](docker/nginx.conf)** - Configuration Nginx
- **[docker/healthcheck.sh](docker/healthcheck.sh)** - Script de santé

---

## 🤖 Automatisation Ansible

**Déploiement automatisé sur serveur distant**  
👉 Consultez **[ansible/README.md](ansible/README.md)**

Fichiers :
- **[ansible/deploy.yml](ansible/deploy.yml)** - Playbook de déploiement
- **[ansible/inventory.ini](ansible/inventory.ini)** - Inventaire des serveurs
- **[ansible/ansible.cfg](ansible/ansible.cfg)** - Configuration Ansible

---

## 📱 Code de l'application

### Frontend
- **[public/index.php](public/index.php)** - Page principale
- **[public/admin.php](public/admin.php)** - Administration
- **[public/assets/](public/assets/)** - CSS, JS, images

### Backend
- **[src/db.php](src/db.php)** - Connexion SQLite
- **[src/api_save.php](src/api_save.php)** - API de sauvegarde
- **[src/generate.php](src/generate.php)** - Génération cahier des charges

---

## 🎯 Par cas d'usage

### Je veux installer l'application
1. **[docs/PREREQUISITES.md](docs/PREREQUISITES.md)** - Installer Docker
2. **[docs/QUICKSTART.md](docs/QUICKSTART.md)** - Démarrer l'app

### Je veux comprendre l'architecture
1. **[docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)** - Architecture complète
2. **[README.md](README.md)** - Structure du projet

### Je veux déployer en production
1. **[docs/DOCKER.md](docs/DOCKER.md)** - Guide production
2. **[ansible/README.md](ansible/README.md)** - Automatisation Ansible

### Je cherche une commande
1. **[docs/COMMANDS.md](docs/COMMANDS.md)** - Référence complète
2. `make help` - Commandes Make

### J'ai un problème
1. **[docs/DOCKER.md](docs/DOCKER.md)** - Section "Dépannage"
2. **[docs/COMMANDS.md](docs/COMMANDS.md)** - Section "Aide et dépannage"
3. Logs : `make logs` ou `docker compose -f docker/docker-compose.yml logs -f`

---

## 🔍 Recherche rapide

| Je veux... | Voir |
|-----------|------|
| Démarrer rapidement | [docs/QUICKSTART.md](docs/QUICKSTART.md) |
| Installer Docker | [docs/PREREQUISITES.md](docs/PREREQUISITES.md) |
| Comprendre Docker | [docs/DOCKER.md](docs/DOCKER.md) |
| Voir l'architecture | [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) |
| Trouver une commande | [docs/COMMANDS.md](docs/COMMANDS.md) |
| Déployer avec Ansible | [ansible/README.md](ansible/README.md) |
| Voir le résumé complet | [docs/SUMMARY.md](docs/SUMMARY.md) |
| Voir les changements | [docs/CHANGELOG.md](docs/CHANGELOG.md) |

---

## 📞 Support

- **Documentation** : Voir ci-dessus selon votre besoin
- **Logs** : `make logs`
- **Tests** : `make test`
- **Statut** : `make status`
- **Aide** : `make help`

---

## 🗂️ Structure des dossiers

```
UyoopAppDocker/
├── docs/          # 📚 Toute la documentation
├── scripts/       # 🚀 Scripts d'automatisation
├── docker/        # 🐳 Configuration Docker
├── ansible/       # 🤖 Automatisation Ansible
├── public/        # 📱 Frontend de l'application
├── src/           # 💻 Backend PHP
└── data/          # 💾 Base de données SQLite
```

Chaque dossier contient un README.md ou des fichiers bien organisés.

---

**Bonne utilisation ! 🎉**
