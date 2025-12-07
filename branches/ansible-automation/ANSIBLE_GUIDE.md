# Ansible Playbooks & Roles - DevOps Portfolio

Guide complet pour utiliser les playbooks et rôles Ansible dans ce portefeuille.

## 📋 Structure du Projet

```
/
├── Playbooks/              # Playbooks d'orchestration (scénarios complets)
├── roles/                  # Rôles réutilisables (composants)
├── ansible.cfg            # Configuration Ansible
├── inventory.ini          # Inventaire des hôtes
└── hosts                  # Fichier hosts personnalisé (optionnel)
```

## 🚀 Démarrage Rapide

### Installation

```bash
# Installer Ansible (Ubuntu/Debian)
sudo apt-get update
sudo apt-get install -y ansible

# Vérifier l'installation
ansible --version
```

### Configuration de Base

```bash
# Copier/modifier le fichier d'inventaire
cp inventory.ini inventory.ini.local
# Éditer avec vos hosts

# Tester la connectivité
ansible all -i inventory.ini -m ping
```

## 📚 Utilisation des Playbooks

### Syntaxe Générale

```bash
ansible-playbook Playbooks/<playbook-name>.yml -i inventory.ini [options]
```

### Options Courantes

```bash
# Exécuter avec escalade de privilèges
ansible-playbook Playbooks/docker-install.yml -i inventory.ini --become

# Utiliser un utilisateur SSH spécifique
ansible-playbook Playbooks/docker-install.yml -i inventory.ini -u ubuntu

# Utiliser une clé SSH
ansible-playbook Playbooks/docker-install.yml -i inventory.ini --private-key=~/.ssh/id_rsa

# Mode verbeux
ansible-playbook Playbooks/docker-install.yml -i inventory.ini -vvv

# Mode dry-run (pas de modifications)
ansible-playbook Playbooks/docker-install.yml -i inventory.ini --check

# Tags spécifiques
ansible-playbook Playbooks/docker-install.yml -i inventory.ini --tags docker-install

# Cibler des hôtes
ansible-playbook Playbooks/docker-install.yml -i inventory.ini -l web_servers
```

## 🎯 Playbooks Disponibles

### 1. Système & Maintenance

**system-update.yml** - Mise à jour sécurisée du système
```bash
ansible-playbook Playbooks/system-update.yml -i inventory.ini -l all
```
Tags: `system`, `updates`, `maintenance`

**user-management.yml** - Gestion des utilisateurs et SSH
```bash
ansible-playbook Playbooks/user-management.yml -i inventory.ini -l all
```
Tags: `users`, `access`, `security`

**firewall-configure.yml** - Configuration du pare-feu
```bash
ansible-playbook Playbooks/firewall-configure.yml -i inventory.ini -l all
```
Tags: `security`, `firewall`, `network`

### 2. Infrastructure & Réseau

**pfsense-install.yml** - Déploiement pfSense
```bash
ansible-playbook Playbooks/pfsense-install.yml -i inventory.ini -l pfsense_servers
```
Tags: `network`, `pfsense`, `firewall`

**opnsense-install.yml** - Déploiement OPNsense
```bash
ansible-playbook Playbooks/opnsense-install.yml -i inventory.ini -l opnsense_servers
```
Tags: `network`, `opnsense`, `firewall`

### 3. Conteneurs & Docker

**docker-install.yml** - Installation Docker Engine
```bash
ansible-playbook Playbooks/docker-install.yml -i inventory.ini -l all
```
Tags: `containers`, `docker`

**docker-registry-deploy.yml** - Déploiement Docker Registry Privé
```bash
ansible-playbook Playbooks/docker-registry-deploy.yml -i inventory.ini -l registry_servers
```
Tags: `containers`, `registry`

**kubernetes-setup.yml** - Cluster Kubernetes
```bash
ansible-playbook Playbooks/kubernetes-setup.yml -i inventory.ini
```
Tags: `kubernetes`, `orchestration`

### 4. Git & CI/CD

**gitlab-install.yml** - GitLab complet
```bash
ansible-playbook Playbooks/gitlab-install.yml -i inventory.ini -l git_servers
```
Tags: `git`, `ci-cd`, `gitlab`

**jenkins-install.yml** - Serveur Jenkins
```bash
ansible-playbook Playbooks/jenkins-install.yml -i inventory.ini -l ci_servers
```
Tags: `ci-cd`, `jenkins`

### 5. Monitoring & Observabilité

**monitoring-stack-deploy.yml** - Prometheus + Grafana + Alertmanager
```bash
ansible-playbook Playbooks/monitoring-stack-deploy.yml -i inventory.ini -l monitoring_servers
```
Tags: `monitoring`, `observability`, `prometheus`

### 6. Sécurité & Certificats

**hardening-server.yml** - Durcissement de sécurité
```bash
ansible-playbook Playbooks/hardening-server.yml -i inventory.ini -l all
```
Tags: `security`, `hardening`

**ssl-certificate-renew.yml** - Gestion des certificats SSL
```bash
ansible-playbook Playbooks/ssl-certificate-renew.yml -i inventory.ini -l all
```
Tags: `security`, `ssl`, `certificates`

**vault-setup.yml** - HashiCorp Vault
```bash
ansible-playbook Playbooks/vault-setup.yml -i inventory.ini -l vault_servers
```
Tags: `security`, `secrets`, `vault`

### 7. Bases de Données

**postgresql-install.yml** - PostgreSQL + Replication
```bash
ansible-playbook Playbooks/postgresql-install.yml -i inventory.ini -l db_servers
```
Tags: `database`, `postgresql`

### 8. Sauvegarde & DR

**backup-setup.yml** - Infrastructure de sauvegarde
```bash
ansible-playbook Playbooks/backup-setup.yml -i inventory.ini -l all
```
Tags: `backup`, `disaster-recovery`

### 9. Web & Load Balancing

**nginx-deploy.yml** - Nginx Reverse Proxy
```bash
ansible-playbook Playbooks/nginx-deploy.yml -i inventory.ini -l web_servers
```
Tags: `web`, `reverse-proxy`

## 🧩 Utilisation des Rôles

### Inclure un Rôle dans un Playbook

```yaml
- name: Mon Playbook
  hosts: all
  become: yes
  
  roles:
    - role: docker
      tags: [docker]
    - role: nginx
      tags: [web]
    - role: postgresql
      tags: [database]
```

### Variables de Rôles

Chaque rôle a un fichier `defaults/main.yml` pour configurer le comportement :

```bash
# Dans le playbook
- role: docker
  vars:
    docker_version: "latest"
    docker_users: [ubuntu, deploy]
```

Ou dans l'inventaire :

```ini
[docker_hosts]
server1 docker_daemon_options_storage_driver=overlay2
```

## 📝 Rôles Disponibles

### Système & OS
- **system-update** - Mise à jour des paquets
- **user** - Gestion des utilisateurs
- **ssh-hardening** - Hardening SSH
- **firewall** - Configuration UFW/firewalld
- **fail2ban** - Protection contre brute-force
- **selinux** - Configuration SELinux
- **auditd** - Audit système
- **kernel-tuning** - Optimisation du noyau

### Conteneurs & Orchestration
- **docker** - Installation Docker
- **docker-registry** - Registry privé Docker
- **kubernetes-master** - Master K8s
- **kubernetes-worker** - Worker K8s
- **cni-plugin** - Plugins CNI (Calico, Flannel, etc.)

### Git & CI/CD
- **gitlab** - GitLab server
- **gitlab-runner** - GitLab Runner
- **jenkins** - Jenkins server
- **jenkins-plugins** - Plugins Jenkins
- **gitea** - Gitea (lightweight Git service)

### Observabilité
- **prometheus** - Prometheus monitoring
- **grafana** - Grafana dashboards
- **alertmanager** - Alertmanager
- **node-exporter** - Node exporter
- **elasticsearch** - Elasticsearch
- **kibana** - Kibana
- **logstash** - Logstash
- **loki** - Grafana Loki
- **promtail** - Promtail (log collector)

### Sécurité & Secrets
- **letsencrypt** - Let's Encrypt certificates
- **certbot** - Certbot ACME client
- **vault** - HashiCorp Vault
- **vault-init** - Vault initialization

### Bases de Données
- **postgresql** - PostgreSQL
- **postgresql-replication** - PostgreSQL Replication
- **mysql** - MySQL/MariaDB
- **mysql-replication** - MySQL Replication
- **mongodb** - MongoDB
- **redis** - Redis cache

### Load Balancing & Reverse Proxy
- **nginx** - Nginx
- **haproxy** - HAProxy
- **traefik** - Traefik

### Infrastructure & Réseau
- **pfsense** - pfSense firewall
- **pfsense-wan** - pfSense WAN config
- **pfsense-firewall-rules** - pfSense firewall rules
- **opnsense** - OPNsense firewall
- **opnsense-rules** - OPNsense rules
- **dns-server** - DNS server
- **openvpn** - OpenVPN
- **wireguard** - WireGuard VPN

### Sauvegarde & DR
- **backup-agent** - Backup agent
- **restic** - Restic backup

### DevOps Tools
- **ansible-tower** - Ansible Tower
- **container-proxy** - Registry proxy
- **nexus** - Nexus artifact repo
- **artifactory** - JFrog Artifactory
- **sonarqube** - SonarQube code quality
- **jenkins-plugins** - Jenkins plugins

## 🔧 Variables & Configuration

### Variables Globales (group_vars/host_vars)

```ini
# inventory.ini
[web_servers]
prod-web-1 ansible_host=192.168.1.10 nginx_port=8080
prod-web-2 ansible_host=192.168.1.11 nginx_port=8080

[db_servers]
prod-db-1 postgresql_version=14 pg_shared_buffers=512MB
prod-db-2 postgresql_version=14 pg_shared_buffers=512MB
```

### Fichiers de Variables Groupées

```bash
# Structure recommandée
group_vars/
  ├── all.yml              # Variables globales
  ├── web_servers.yml      # Variables pour web_servers
  ├── db_servers.yml       # Variables pour db_servers
  └── production.yml       # Variables par environnement

host_vars/
  ├── prod-web-1.yml
  ├── prod-db-1.yml
  └── ...
```

## 📊 Exemples d'Exécution

### 1. Déploiement Docker complet sur tous les serveurs

```bash
ansible-playbook Playbooks/docker-install.yml -i inventory.ini -l all --become
```

### 2. Mise à jour système avec reboot

```bash
ansible-playbook Playbooks/system-update.yml -i inventory.ini \
  -e "system_update_auto_reboot=true" --become
```

### 3. Déploiement GitLab sur un serveur spécifique

```bash
ansible-playbook Playbooks/gitlab-install.yml -i inventory.ini \
  -l git_servers --become
```

### 4. Installation cluster Kubernetes

```bash
# D'abord les masters
ansible-playbook Playbooks/kubernetes-setup.yml -i inventory.ini \
  -l kubernetes_masters --become

# Ensuite les workers
ansible-playbook Playbooks/kubernetes-setup.yml -i inventory.ini \
  -l kubernetes_workers --become
```

### 5. Mode dry-run (vérification)

```bash
ansible-playbook Playbooks/docker-install.yml -i inventory.ini --check
```

### 6. Mode verbeux pour déboguer

```bash
ansible-playbook Playbooks/docker-install.yml -i inventory.ini -vvv
```

## 🐛 Dépannage

### Erreurs Courantes

#### 1. Connectivité SSH
```bash
# Vérifier la connexion SSH
ansible all -i inventory.ini -m ping

# Avec clé SSH explicite
ansible all -i inventory.ini -m ping --private-key=~/.ssh/id_rsa
```

#### 2. Permissions sudo
```bash
# Exécuter avec --become-ask-pass pour demander mot de passe
ansible-playbook Playbooks/system-update.yml -i inventory.ini --become --ask-become-pass
```

#### 3. Modules manquants
```bash
# Installer les requirements Python
pip install paramiko jinja2 pyyaml
```

#### 4. Vérifier les variables
```bash
# Afficher toutes les variables d'un hôte
ansible-inventory -i inventory.ini --host prod-web-1
```

## 📈 Bonnes Pratiques

### 1. Toujours tester d'abord
```bash
ansible-playbook Playbooks/xxx.yml -i inventory.ini --check
```

### 2. Utiliser des tags
```bash
# Exécuter uniquement certaines tâches
ansible-playbook Playbooks/docker-install.yml -i inventory.ini --tags docker-install
```

### 3. Limiter à un groupe
```bash
# Safer que de lancer sur 'all'
ansible-playbook Playbooks/xxx.yml -i inventory.ini -l staging
```

### 4. Documenter les variables
```bash
# Dans defaults/main.yml de chaque rôle
# Bien commenter les variables utilisées
```

### 5. Versioning et CI/CD
```bash
# Intégrer dans GitLab CI
ansible-playbook check: Playbooks/*.yml -i inventory.ini --syntax-check
```

## 🔐 Sécurité

### Utiliser Vault pour les Secrets

```bash
# Créer un fichier chiffré
ansible-vault create group_vars/all/vault.yml

# Éditer le fichier chiffré
ansible-vault edit group_vars/all/vault.yml

# Exécuter un playbook avec vault
ansible-playbook Playbooks/xxx.yml -i inventory.ini --ask-vault-pass
```

### Variables Sensibles

```yaml
# Dans vault.yml
vault_pg_password: "secure_password_here"
vault_gitlab_token: "token_here"
vault_docker_registry_password: "password_here"
```

## 📚 Ressources

- [Documentation Ansible Officielle](https://docs.ansible.com/)
- [Ansible Galaxy](https://galaxy.ansible.com/)
- [Best Practices](https://docs.ansible.com/ansible/latest/user_guide/playbooks_best_practices.html)

## ✅ Checklist de Déploiement

- [ ] Inventaire configuré correctement
- [ ] SSH Keys configurées
- [ ] Test de connectivité (ansible all -m ping)
- [ ] Variables vérifiées
- [ ] Mode --check exécuté
- [ ] Logs vérifiés
- [ ] Health checks effectués après déploiement

## 📞 Support

Pour toute question ou amélioration, consultez la documentation officielle ou les repos GitHub des projets correspondants.

---

**Version**: 1.0  
**Dernière mise à jour**: 2024
