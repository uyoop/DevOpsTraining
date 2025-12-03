# Changelog - UyoopApp

Tous les changements notables de ce projet seront documentés dans ce fichier.

## [2.0.0] - 2024-12-03

### 🐳 Conteneurisation complète

#### Ajouté
- **Docker**
  - `Dockerfile` avec PHP 8.4-FPM Alpine et extension SQLite
  - `docker-compose.yml` pour environnement de développement
  - `docker-compose.prod.yml` pour environnement de production
  - `nginx.conf` - Configuration Nginx optimisée
  - `healthcheck.sh` - Script de vérification de santé des conteneurs
  - `.dockerignore` - Exclusions pour build Docker
  - `.env.example` - Template de variables d'environnement

- **Automatisation**
  - `deploy.sh` - Script de déploiement automatique avec vérifications
  - `test.sh` - Suite de tests automatiques (endpoints, DB, API)
  - `Makefile` - Commandes simplifiées (make install, make deploy, etc.)

- **Ansible**
  - `ansible/deploy.yml` - Playbook de déploiement automatisé
  - `ansible/inventory.ini` - Template d'inventaire serveurs
  - `ansible/ansible.cfg` - Configuration Ansible
  - `ansible/README.md` - Guide complet Ansible

- **Documentation**
  - `DOCKER.md` - Guide complet Docker (installation, déploiement, production)
  - `ARCHITECTURE.md` - Architecture technique détaillée
  - `QUICKSTART.md` - Guide de démarrage rapide
  - `.gitignore` - Exclusions Git
  - README.md amélioré avec sections Docker

#### Améliorations
- Architecture multi-conteneurs (Nginx + PHP-FPM)
- Isolation réseau avec Docker network
- Persistance des données avec volumes Docker
- Healthchecks intégrés pour monitoring
- Logs rotatifs en production
- Scripts de backup/restore automatiques
- Configuration optimisée pour développement et production
- Support du déploiement distant (Ansible)

#### Sécurité
- Permissions strictes sur répertoire data/
- Protection Nginx contre accès directs
- Variables d'environnement pour configuration
- Isolation des conteneurs

### 📦 Dépendances
- Docker 20.10+
- Docker Compose V2
- Ansible 2.9+ (optionnel, pour déploiement automatisé)

## [1.0.0] - Date précédente

### Ajouté
- Application PHP minimale
- Formulaire intelligent de recueil de besoins
- Génération automatique de cahier des charges
- Base de données SQLite
- Page d'administration
- Interface responsive

---

## Types de changements

- `Ajouté` : pour les nouvelles fonctionnalités
- `Modifié` : pour les changements dans les fonctionnalités existantes
- `Déprécié` : pour les fonctionnalités bientôt supprimées
- `Supprimé` : pour les fonctionnalités supprimées
- `Corrigé` : pour les corrections de bugs
- `Sécurité` : en cas de vulnérabilités
