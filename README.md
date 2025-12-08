# 🐳 TPs Docker - Formation DevOps

Bienvenue dans la formation Docker ! Cette branche contient l'ensemble des travaux pratiques pour maîtriser Docker de A à Z.

## 📚 Liste des TPs (1-22)

### Fondamentaux Docker
| TP | Titre | Focus | Durée | Niveau |
|----|-------|-------|-------|--------|
| **01** | Installation de Docker | Setup Docker Engine | 30 min | Débutant |
| **02** | Commandes Docker de Base | Images, conteneurs, logs | 1h30 | Débutant |
| **03** | Docker Compose | Multi-conteneurs, stacks | 2h | Intermédiaire |
| **04** | Docker Registry Privé | Registry sécurisé, TLS, auth | 2h | Intermédiaire |
| **05** | Réseaux Docker | Bridge, host, overlay, DNS | 1h30 | Intermédiaire |
| **06** | Volumes Docker | Persistance, backups | 1h30 | Intermédiaire |
| **07** | Dockerfiles | Multi-stage, optimisation | 2h30 | Intermédiaire |
| **08** | Docker Swarm | Orchestration, HA | 3h | Avancé |

### Applications & Observabilité
| TP | Titre | Focus | Durée | Niveau |
|----|-------|-------|-------|--------|
| **09** | BookStack Docker (Basique) | Déploiement simple BookStack | 1h | Débutant |
| **10** ⭐ | BookStack Production Sécurisé | Traefik v3, Authelia 2FA, CrowdSec, backups | 4-6h | Avancé/Prod |
| **11** | NetBox Docker (Basique) | IPAM/DCIM rapide (PostgreSQL, Redis, Worker) | 2h | Intermédiaire |
| **12** ⭐ | NetBox Professionnel | Reverse proxy TLS, monitoring, API GraphQL | 3-4h | Avancé/Prod |
| **13** | Prometheus Docker | Prometheus + Node Exporter + cAdvisor + Alertmanager | 2-3h | Intermédiaire |
| **14** ⭐⭐ | Prometheus + Grafana Pro | Grafana, Loki, Blackbox, alerting multi-canal | 4-6h | Expert/Prod |

### Registries & Ops
| TP | Titre | Focus | Durée | Niveau |
|----|-------|-------|-------|--------|
| **15** | Harbor Docker (Basique) | Registry + Trivy + portail web | 2-3h | Intermédiaire |
| **16** ⭐ | Harbor Production | HA (PostgreSQL/Redis), Traefik, monitoring, backups | 4-6h | Avancé/Prod |
| **17** | Portainer Docker (Basique) | Portainer CE, gestion conteneurs/stacks | 1h | Débutant |
| **18** ⭐ | Portainer Enterprise | Portainer EE, PostgreSQL, GitOps, Traefik, metrics | 3-4h | Avancé/Prod |

### Audit & Qualité d'Image
| TP | Titre | Focus | Durée | Niveau |
|----|-------|-------|-------|--------|
| **20** | Dive Docker | Analyse des layers, optimisation Dockerfile, score d'efficacité | 45 min | Intermédiaire |
| **21** ⭐ | Dive + Harbor (Ansible) | Audit non interactif, rapports JSON, gating CI/CD | 1h30 | Avancé/Prod |
| **22** 🧪 | Dive Test Suite | Exercice complet : bad vs good, Dive TUI, comparaison | 2h | Intermédiaire |

### Projets applicatifs complémentaires
| TP | Titre | Focus | Dossier |
|----|-------|-------|---------|
| **19** | AfpaBike (refonte Dev/DevOps) | Repackaging Docker, refonte DevOps, variante appli corrigée | `19-App-AfpaBike/` (`AB-projet-base`, `AB-Devops-ok`, `AB-App-ok`) |
| **20** | Dive Docker | Audit d'images local (TUI/CI) | `20-Dive-docker/` |
| **21** | Dive + Harbor (Ansible) | Audit pro connecté au registry Harbor | `21-Dive-harbor-Docker-pro/` |
| **22** | Dive Test Suite | Exercice complet avec Dockerfiles bad/good, scripts, Ansible | `22-Dive-test/` |

> Branche `docker` = référence principale des TPs. Dossier `branches/docker/` = snapshot consultable sans changer de branche.

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
10. TP 13 - Prometheus Docker (monitoring)

### 🔴 Avancé (Jour 5-7)
11. TP 07 - Dockerfiles avancés
12. TP 08 - Docker Swarm

### 🏆 Expert / Production (Jour 8-14)
13. **TP 10 - BookStack Production Sécurisé** ⭐
    - Architecture de sécurité multi-couches
    - Reverse proxy, 2FA, IDS/IPS
    - Monitoring et observabilité
    - Backups automatisés chiffrés
    - Automation avec Ansible
    - Hardening système complet

14. **TP 12 - NetBox Professionnel** ⭐⭐
    - IPAM/DCIM solution complète
    - Traefik reverse proxy
    - Prometheus + Grafana monitoring
    - API REST + GraphQL
    - Device types import

15. **TP 14 - Prometheus + Grafana Production** ⭐⭐⭐
    - Stack monitoring enterprise-grade
    - 10 services orchestrés
    - Logs + Metrics + Alerting
    - SSL/TLS + Security hardening
    - Multi-canal alerting
    - Backup/Restore automatisés
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
