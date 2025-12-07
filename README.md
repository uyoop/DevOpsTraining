# 🐳 TPs Docker - Formation DevOps

Bienvenue dans la formation Docker ! Cette branche contient l'ensemble des travaux pratiques pour maîtriser Docker de A à Z.

## 📚 Liste des TPs

### [01 - Installation de Docker](./01-docker-install/)
Installation et configuration de Docker Engine sur Linux.
- Installation automatique et manuelle
- Configuration post-installation
- Vérification et tests
- **Durée estimée** : 30 min

### [02 - Commandes Docker de Base](./02-docker-basics/)
Maîtrise des commandes essentielles Docker.
- Gestion des images et conteneurs
- Logs et inspection
- Cycle de vie des conteneurs
- Exercices pratiques (Nginx, PostgreSQL, Python)
- **Durée estimée** : 1h30

### [03 - Docker Compose](./03-docker-compose/)
Orchestration d'applications multi-conteneurs.
- Syntaxe docker-compose.yml
- Stack WordPress, Monitoring
- Variables d'environnement et secrets
- Commandes Compose avancées
- **Durée estimée** : 2h

### [04 - Docker Registry Privé](./04-docker-registry-prive/)
Déploiement d'un registry Docker sécurisé.
- Configuration TLS avec certificats auto-signés
- Authentication htpasswd
- Déploiement avec Vagrant + Ansible
- Push/Pull d'images personnalisées
- **Durée estimée** : 2h

### [05 - Réseaux Docker](./05-docker-network/)
Maîtrise des réseaux et communication inter-conteneurs.
- Types de réseaux (bridge, host, overlay)
- Isolation et segmentation
- DNS et service discovery
- Reverse proxy avec Nginx
- **Durée estimée** : 1h30

### [06 - Volumes Docker](./06-docker-volumes/)
Persistance des données et gestion du stockage.
- Volumes, bind mounts, tmpfs
- Backup et restore
- Permissions et sécurité
- Drivers NFS et CIFS
- **Durée estimée** : 1h30

### [07 - Création de Dockerfiles](./07-dockerfiles/)
Construction d'images Docker personnalisées.
- Syntaxe et instructions
- Multi-stage builds
- Optimisation et best practices
- Exemples : Python, Node.js, Go, PHP
- **Durée estimée** : 2h30

### [08 - Docker Swarm](./08-docker-swarm/)
Orchestration et haute disponibilité.
- Initialisation d'un cluster Swarm
- Services et stacks
- Scaling et rolling updates
- Secrets et configs
- Haute disponibilité
- **Durée estimée** : 3h

### [09 - BookStack Docker (Basique)](./09-bookstack-docker/)
Déploiement de BookStack pour la documentation.
- Stack BookStack + MySQL
- Configuration de base
- Variables d'environnement
- Premier déploiement simple
- **Durée estimée** : 1h
- **Niveau** : Débutant

### [10 - BookStack Production Sécurisé](./10-bookstack-production/) ⭐
**Production-grade deployment** avec sécurité multi-couches.
- **Architecture complète** : 11 services orchestrés
- **Sécurité** : Traefik v3 + Authelia 2FA + CrowdSec + Docker Secrets
- **Réseaux isolés** : proxy, backend internal, database isolated
- **Monitoring** : Prometheus + Grafana + Node-exporter
- **Backup** : Restic avec chiffrement GPG
- **Hardening** : UFW, Fail2Ban, kernel tuning, SSH hardening, auditd
- **Automation** : Scripts install/backup/restore/hardening + Playbook Ansible
- **Documentation** : 500+ lignes avec architecture, troubleshooting, exercices
- **Durée estimée** : 4-6h
- **Niveau** : Avancé/Production

### [11 - NetBox Docker (Basique)](./11-netbox-docker/)
Gestion d'infrastructure réseau avec NetBox.
- Docker Compose simple (PostgreSQL + Redis + NetBox)
- 3 containers (app, worker, housekeeping)
- API REST configuration
- Device Type Library import
- Documentation interactive
- **Durée estimée** : 2h
- **Niveau** : Débutant

### [12 - NetBox Professionnel](./12-netbox-professionnel/) ⭐⭐
**Production-ready IPAM/DCIM solution**.
- **Architecture complète** : 6 services (NetBox, PostgreSQL, Redis, Traefik, Prometheus, Grafana)
- **Sécurité** : Traefik v3 + SSL/TLS + Rate limiting + Security headers
- **Monitoring** : Prometheus + Grafana avec dashboards
- **Backup** : Scripts automatisés de sauvegarde/restauration
- **API** : REST + GraphQL activés
- **Automation** : Scripts import/export + Device Types
- **Use Cases** : IPAM, DCIM, Circuits, Cables, Contacts
- **Documentation** : Guide complet avec exemples API/Ansible
- **Durée estimée** : 3-4h
- **Niveau** : Avancé/Infrastructure

## 🎯 Objectifs Globaux

À la fin de cette formation, vous serez capable de :

✅ Installer et configurer Docker  
✅ Gérer des conteneurs et images  
✅ Orchestrer des applications multi-conteneurs avec Docker Compose  
✅ Déployer un registry privé sécurisé  
✅ Maîtriser les réseaux et volumes Docker  
✅ Créer des Dockerfiles optimisés  
✅ Déployer des applications en haute disponibilité avec Docker Swarm  
✅ **Déployer des stacks production avec sécurité multi-couches** (reverse proxy, 2FA, IDS, monitoring)  
✅ **Automatiser avec Ansible** et gérer des secrets Docker  
✅ **Implémenter monitoring, backups et disaster recovery**  

## 📋 Prérequis

- **Linux** : Ubuntu 20.04+ ou Debian 11+
- **RAM** : 4 GB minimum (8 GB recommandé)
- **Disk** : 20 GB d'espace libre
- **Connaissances** : 
  - Ligne de commande Linux
  - Concepts réseaux de base
  - Notions de développement (pour les Dockerfiles)

## 🚀 Démarrage Rapide

### Installation Docker (Méthode rapide)

```bash
# Script d'installation automatique
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Ajouter votre utilisateur au groupe docker
sudo usermod -aG docker $USER
newgrp docker

# Vérifier l'installation
docker --version
docker run hello-world
```

### Cloner ce repository

```bash
git clone https://github.com/CJenkins-AFPA/CJ-DEVOPS.git
cd CJ-DEVOPS
git checkout docker
```

## 📖 Parcours Recommandé

### 🟢 Débutant (Jour 1-2)
1. TP 01 - Installation
2. TP 02 - Commandes de base
3. TP 03 - Docker Compose (partie 1)
4. TP 09 - BookStack basique
5. TP 11 - NetBox basique

### 🟡 Intermédiaire (Jour 3-4)
6. TP 03 - Docker Compose (partie 2)
7. TP 05 - Réseaux
8. TP 06 - Volumes
9. TP 04 - Registry Privé

### 🔴 Avancé (Jour 5-7)
10. TP 07 - Dockerfiles avancés
11. TP 08 - Docker Swarm

### 🏆 Expert / Production (Jour 8-12)
12. **TP 10 - BookStack Production Sécurisé** ⭐
    - Architecture de sécurité multi-couches
    - Reverse proxy, 2FA, IDS/IPS
    - Monitoring et observabilité
    - Backups automatisés chiffrés
    - Automation avec Ansible
    - Hardening système complet

13. **TP 12 - NetBox Professionnel** ⭐⭐
    - IPAM/DCIM solution complète
    - Traefik reverse proxy
    - Prometheus + Grafana monitoring
    - API REST + GraphQL
    - Device types import
    - Backup/restore scripts
    - Intégration automation

> **💡 Note** : Les TP 10 et 12 représentent des mises en production réelles et démontrent des compétences DevOps avancées recherchées en entreprise. Parfaits pour un portfolio professionnel.

## 🔧 Outils Complémentaires

### VS Code Extensions
- Docker (ms-azuretools.vscode-docker)
- YAML (redhat.vscode-yaml)

### CLI Tools
```bash
# Docker Compose v2
sudo apt install docker-compose-plugin

# ctop (monitoring conteneurs)
sudo wget https://github.com/bcicen/ctop/releases/download/v0.7.7/ctop-0.7.7-linux-amd64 -O /usr/local/bin/ctop
sudo chmod +x /usr/local/bin/ctop

# dive (analyser les layers d'images)
wget https://github.com/wagoodman/dive/releases/download/v0.11.0/dive_0.11.0_linux_amd64.deb
sudo apt install ./dive_0.11.0_linux_amd64.deb
```

## 📊 Structure du Projet

```
docker/
├── 01-docker-install/          # Installation Docker
│   └── README.md
├── 02-docker-basics/           # Commandes essentielles
│   └── README.md
├── 03-docker-compose/          # Orchestration multi-conteneurs
│   └── README.md
├── 04-docker-registry-prive/   # Registry sécurisé
│   ├── README.md
│   ├── Vagrantfile
│   ├── playbook.yml
│   └── inventory.ini
├── 05-docker-network/          # Réseaux Docker
│   └── README.md
├── 06-docker-volumes/          # Persistance des données
│   └── README.md
├── 07-dockerfiles/             # Construction d'images
│   └── README.md
└── 08-docker-swarm/            # Orchestration Swarm
    └── README.md
```

## 🎓 Ressources Externes

### Documentation Officielle
- [Docker Docs](https://docs.docker.com/)
- [Docker Hub](https://hub.docker.com/)
- [Docker Compose](https://docs.docker.com/compose/)

### Tutoriels et Guides
- [Play with Docker](https://labs.play-with-docker.com/)
- [Docker Curriculum](https://docker-curriculum.com/)
- [Awesome Docker](https://github.com/veggiemonk/awesome-docker)

### Livres Recommandés
- "Docker Deep Dive" - Nigel Poulton
- "Docker in Action" - Jeff Nickoloff
- "Kubernetes Patterns" - Bilgin Ibryam (pour après Docker)

## 🛡️ Technologies Modernes Utilisées (TP10)

Ce repository inclut les dernières technologies DevOps pour production :

| Technologie | Usage | Version |
|-------------|-------|---------|
| **Traefik** | Reverse Proxy & SSL | v3.x |
| **Authelia** | 2FA / SSO | v4.x |
| **CrowdSec** | IDS/IPS collaboratif | Latest |
| **Prometheus** | Monitoring metrics | Latest |
| **Grafana** | Dashboards & alerting | Latest |
| **Restic** | Backups chiffrés | Latest |
| **Docker Secrets** | Gestion credentials | Built-in |
| **Ansible** | Infrastructure as Code | 2.9+ |

### Stack de Sécurité (TP10)
```
Internet → UFW Firewall
       → Traefik (SSL/TLS 1.3)
          → Authelia (2FA TOTP)
             → CrowdSec (IDS/IPS)
                → Application (BookStack)
                   → MySQL (Isolated Network)
```

## 💡 Conseils d'Apprentissage

1. **Pratiquez régulièrement** : Docker s'apprend en faisant
2. **Expérimentez** : Cassez des choses, c'est normal !
3. **Lisez les logs** : `docker logs` est votre ami
4. **Utilisez docker inspect** : Pour comprendre ce qui se passe
5. **Nettoyez régulièrement** : `docker system prune` pour libérer de l'espace

## 🐛 Debugging Courant

### Conteneur qui ne démarre pas
```bash
docker logs <container-id>
docker inspect <container-id>
```

### Port déjà utilisé
```bash
sudo netstat -tulpn | grep <port>
sudo lsof -i :<port>
```

### Espace disque saturé
```bash
docker system df
docker system prune -a --volumes
```

### Réseau qui ne fonctionne pas
```bash
docker network inspect <network-name>
docker exec <container> ping <other-container>
```

## 🤝 Contribution

Cette formation est open-source. N'hésitez pas à :
- Signaler des erreurs (Issues)
- Proposer des améliorations (Pull Requests)
- Partager vos retours d'expérience

## 📧 Contact

- **Author** : CJenkins-AFPA
- **GitHub** : [CJenkins-AFPA/CJ-DEVOPS](https://github.com/CJenkins-AFPA/CJ-DEVOPS)
- **Branch** : `docker`

## 📝 Licence

Ce projet est sous licence MIT - voir le fichier [LICENSE](../LICENSE) pour plus de détails.

---

## 🎯 Checklist de Progression

- [ ] TP 01 - Installation Docker
- [ ] TP 02 - Commandes de base
- [ ] TP 03 - Docker Compose
- [ ] TP 04 - Registry Privé
- [ ] TP 05 - Réseaux Docker
- [ ] TP 06 - Volumes Docker
- [ ] TP 07 - Dockerfiles
- [ ] TP 08 - Docker Swarm

**Bon apprentissage ! 🚀**
