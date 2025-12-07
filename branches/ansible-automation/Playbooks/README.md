# Playbooks Ansible - Scénarios DevOps Production

Ensemble de playbooks réutilisables couvrant les workflows DevOps courants en production : infrastructure, CI/CD, monitoring, sécurité, backup et orchestration.

## 📋 Liste des Playbooks

### Infrastructure & Système

#### `system-update.yml`
- **Description** : Mise à jour sécurisée du système (paquets, noyau, configurations).
- **Usage** : Déploiement sur parc de serveurs Linux (CentOS/Ubuntu/Debian).
- **Points clés** : Gestion des redémarrages, rollback des mises à jour critiques.
- **Rôles appelés** : `system-update`, `kernel-tuning`

#### `user-management.yml`
- **Description** : Gestion centralisée des utilisateurs, groupes, clés SSH, sudoers.
- **Usage** : Synchroniser les accès sur un parc, ajouter/retirer des devs.
- **Points clés** : Audit, rotation des clés, homogénéité des permissions.
- **Rôles appelés** : `user`, `ssh-hardening`

#### `firewall-configure.yml`
- **Description** : Configuration UFW/firewalld + règles réseau, ports d'écoute.
- **Usage** : Sécuriser les accès réseau, bloquer les ports non nécessaires.
- **Points clés** : Whitelisting, gestion des zones, logging des rejets.
- **Rôles appelés** : `firewall`

---

### Infrastructure Réseau & Services

#### `pfsense-install.yml`
- **Description** : Installation et configuration initiale de pfSense (routeur/pare-feu).
- **Usage** : Déployer un pare-feu réseau de production avec VPN, NAT, DHCP.
- **Points clés** : WAN/LAN, VPN (IPSec/OpenVPN), VLAN, high-availability.
- **Rôles appelés** : `pfsense`, `pfsense-wan`, `pfsense-firewall-rules`

#### `opnsense-install.yml`
- **Description** : Installation et configuration d'OPNsense (fork sécurisé de pfSense).
- **Usage** : Alternative moderne à pfSense pour prod, moins anciennes deps.
- **Points clés** : Mêmes features que pfSense + mises à jour plus fréquentes.
- **Rôles appelés** : `opnsense`, `opnsense-rules`

#### `dns-configure.yml`
- **Description** : Configuration d'un serveur DNS (bind9, PowerDNS) avec zones et records.
- **Usage** : Gérer l'infrastructure DNS en production.
- **Points clés** : DNSSEC, zones slaves, forwarders, logging.
- **Rôles appelés** : `dns-server`

#### `vpn-setup.yml`
- **Description** : Déploiement d'un serveur VPN (OpenVPN, WireGuard).
- **Usage** : Connecter les devs/bureaux distants au parc infra.
- **Points clés** : Certificats, gestion des clients, audit des connexions.
- **Rôles appelés** : `openvpn`, `wireguard`

---

### Conteneurisation & Orchestration

#### `docker-install.yml`
- **Description** : Installation de Docker + Docker Compose, configuration du daemon.
- **Usage** : Préparer un host pour les conteneurs.
- **Points clés** : Stockage des images, réseau bridge/overlay, privileges.
- **Rôles appelés** : `docker`

#### `docker-registry-deploy.yml`
- **Description** : Déploiement d'un registry Docker privé (TLS, authentification).
- **Usage** : Héberger les images d'entreprise en local, cache des images publiques.
- **Points clés** : Stockage persistant, garbage collection, réplication.
- **Rôles appelés** : `docker-registry`

#### `kubernetes-setup.yml`
- **Description** : Installation d'un cluster Kubernetes (kubeadm, kubelet, apiserver).
- **Usage** : Déployer une plateforme d'orchestration pour apps scalables.
- **Points clés** : Init master, join workers, CNI, RBAC, etcd backup.
- **Rôles appelés** : `kubernetes-master`, `kubernetes-worker`, `cni-plugin`

---

### Git & CI/CD

#### `gitlab-install.yml`
- **Description** : Installation complète de GitLab (server, PostgreSQL, Redis, Minio).
- **Usage** : Déployer un serveur Git/CI-CD privé en production.
- **Points clés** : SSL/TLS, sauvegardes, runners, intégrations.
- **Rôles appelés** : `gitlab`, `gitlab-runner`, `postgresql`, `redis`, `letsencrypt`

#### `gitlab-runner-install.yml`
- **Description** : Installation et configuration d'un runner GitLab CI/CD.
- **Usage** : Ajouter des exécuteurs de jobs CI (shell, docker, k8s).
- **Points clés** : Types d'exécuteurs, caching, artifacts, tags.
- **Rôles appelés** : `gitlab-runner`

#### `jenkins-install.yml`
- **Description** : Installation de Jenkins + configuration plugins/jobs.
- **Usage** : Déployer un serveur CI/CD alternatif à GitLab (flexibilité, pipelines).
- **Points clés** : Master/agents, plugins, sécurité, backups.
- **Rôles appelés** : `jenkins`, `jenkins-plugins`

#### `gitea-install.yml`
- **Description** : Installation légère de Gitea (Git simple, minimaliste).
- **Usage** : Self-host Git lightweight, idéal pour petits équipes/labs.
- **Points clés** : SQLite ou PostgreSQL, webhooks, migrations depuis GitHub.
- **Rôles appelés** : `gitea`, `postgresql`

---

### Monitoring & Observabilité

#### `monitoring-stack-deploy.yml`
- **Description** : Déploiement d'une stack monitoring : Prometheus + Grafana + Alertmanager.
- **Usage** : Superviser les métriques système et applicatives, alertes temps réel.
- **Points clés** : Scrape configs, dashboards, rules d'alerte, notifications (mail/Slack).
- **Rôles appelés** : `prometheus`, `grafana`, `alertmanager`

#### `logging-stack-deploy.yml`
- **Description** : Déploiement d'une stack logs : Elasticsearch + Kibana ou ELK minimal.
- **Usage** : Centraliser et analyser les logs d'infra et apps.
- **Points clés** : Logstash/Filebeat, indices, retention, alertes sur patterns.
- **Rôles appelés** : `elasticsearch`, `kibana`, `logstash`

#### `node-exporter-install.yml`
- **Description** : Installation de Prometheus Node Exporter sur les hosts.
- **Usage** : Exporter les métriques système pour Prometheus.
- **Points clés** : Collectors, service systemd, firewall ouvert côté Prometheus.
- **Rôles appelés** : `node-exporter`

#### `loki-install.yml`
- **Description** : Installation de Loki (logs lightweight, alternative ELK).
- **Usage** : Ingérer les logs avec Promtail, requêtes via Grafana.
- **Points clés** : Labels, retention, performance, intégration Grafana.
- **Rôles appelés** : `loki`, `promtail`

---

### Sécurité & Compliance

#### `ssl-certificate-renew.yml`
- **Description** : Gestion et renouvellement des certificats SSL/TLS (Let's Encrypt, auto-renew).
- **Usage** : Automatiser le renouvellement des certificats avant expiration.
- **Points clés** : Cronjob, hooks de renouvellement, alertes expirations proches.
- **Rôles appelés** : `letsencrypt`, `certbot`

#### `hardening-server.yml`
- **Description** : Durcissement de sécurité serveur : sshd, sudoers, fail2ban, SELinux.
- **Usage** : Sécuriser un serveur Linux de production (CIS Benchmarks).
- **Points clés** : Désactiver root SSH, limits failed logins, auditd, AppArmor.
- **Rôles appelés** : `ssh-hardening`, `fail2ban`, `selinux`

#### `vault-setup.yml`
- **Description** : Installation de HashiCorp Vault pour gestion de secrets.
- **Usage** : Centraliser les secrets (credentials, tokens, certs) de manière sécurisée.
- **Points clés** : Unseal, auth methods, policies, audit logging.
- **Rôles appelés** : `vault`, `vault-init`

#### `compliance-audit.yml`
- **Description** : Audit compliance : logs d'accès, configuration management, changelogs.
- **Usage** : Générer des rapports de conformité (GDPR, PCI-DSS, ISO27001).
- **Points clés** : Auditd, logrotate, syslog centralisé, snapshots config.
- **Rôles appelés** : `auditd`, `compliance-check`

---

### Backup & Disaster Recovery

#### `backup-setup.yml`
- **Description** : Configuration de sauvegarde automatique (rsync, Restic, Bacula).
- **Usage** : Sauvegarder les données critiques de manière incrémentale/différentielle.
- **Points clés** : Planification, rétention, vérification d'intégrité, restauration.
- **Rôles appelés** : `backup-agent`, `restic`

#### `backup-restore.yml`
- **Description** : Procédure et automation de restauration depuis sauvegardes.
- **Usage** : Tester et executer des restaurations en cas de sinistre.
- **Points clés** : RPO/RTO, test réguliers, documentation des procédures.
- **Rôles appelés** : `backup-agent`

#### `database-backup.yml`
- **Description** : Sauvegarde spécifique des bases de données (PostgreSQL, MySQL, MongoDB).
- **Usage** : Sauvegarder les données applicatives critiques.
- **Points clés** : Full/incremental, WAL archiving, PITR, compression.
- **Rôles appelés** : `postgresql`, `mysql`, `mongodb`

---

### Base de Données

#### `postgresql-install.yml`
- **Description** : Installation et configuration de PostgreSQL (master + replicas optionnels).
- **Usage** : Déployer une DB relationnelle production avec HA.
- **Points clés** : Streaming replication, backup WAL, tuning performance, monitoring.
- **Rôles appelés** : `postgresql`, `postgresql-replication`

#### `mysql-install.yml`
- **Description** : Installation de MySQL/MariaDB avec replication et clustering.
- **Usage** : Déployer MySQL/MariaDB en production.
- **Points clés** : Master-slave replication, Galera cluster, backups.
- **Rôles appelés** : `mysql`, `mysql-replication`

#### `mongodb-install.yml`
- **Description** : Installation de MongoDB (replica set ou sharded cluster).
- **Usage** : Déployer une DB NoSQL pour apps scalables.
- **Points clés** : Replica sets, sharding, journaling, backups.
- **Rôles appelés** : `mongodb`

#### `redis-install.yml`
- **Description** : Installation de Redis (cache, session store).
- **Usage** : Déployer un cache distributé.
- **Points clés** : Persistence (RDB/AOF), replication, Sentinel, cluster.
- **Rôles appelés** : `redis`

---

### Load Balancing & Reverse Proxy

#### `nginx-deploy.yml`
- **Description** : Déploiement d'Nginx comme reverse proxy/load balancer.
- **Usage** : Router le trafic vers plusieurs backends, SSL termination.
- **Points clés** : upstream configuration, health checks, rate limiting, caching.
- **Rôles appelés** : `nginx`, `letsencrypt`

#### `haproxy-deploy.yml`
- **Description** : Déploiement de HAProxy pour load balancing avancé.
- **Usage** : Alternative performante à Nginx pour L4/L7 routing.
- **Points clés** : Stats socket, ACLs, health checks, stick tables.
- **Rôles appelés** : `haproxy`

#### `traefik-deploy.yml`
- **Description** : Installation de Traefik (reverse proxy moderne, labels-based).
- **Usage** : Routing automatique pour Docker/Kubernetes.
- **Points clés** : Providers (Docker, K8s), auto SSL, middlewares.
- **Rôles appelés** : `traefik`

---

### Outils Supplémentaires & DevOps

#### `ansible-tower-install.yml`
- **Description** : Installation d'Ansible Tower (Ansible controller, API, RBAC).
- **Usage** : Centraliser l'exécution des playbooks avec UI et audit.
- **Points clés** : RBAC, job templates, credentials management, API.
- **Rôles appelés** : `ansible-tower`, `postgresql`

#### `container-registry-proxy.yml`
- **Description** : Configuration d'un proxy pour registries Docker (nexus, artifactory).
- **Usage** : Cacher les images Docker publiques, limiter les pulls.
- **Points clés** : Cache layers, auth, rate limiting.
- **Rôles appelés** : `container-proxy`

#### `artifact-repository-deploy.yml`
- **Description** : Installation de Nexus ou Artifactory pour artefacts (jar, npm, pip, etc.).
- **Usage** : Héberger les dépendances et artefacts de build.
- **Points clés** : Repositories, proxies, cleanup policies, RBAC.
- **Rôles appelés** : `nexus` ou `artifactory`

#### `sonarqube-install.yml`
- **Description** : Installation de SonarQube pour analyses de code (quality gates, coverage).
- **Usage** : Intégration CI/CD pour code quality.
- **Points clés** : Project setup, quality gates, plugins, database.
- **Rôles appelés** : `sonarqube`, `postgresql`

---

## 🚀 Usage

```bash
# Lancer un playbook simple
ansible-playbook Playbooks/system-update.yml -i inventory.ini

# Lancer sur des hôtes spécifiques
ansible-playbook Playbooks/user-management.yml -i inventory.ini -l webservers

# Dry-run avant d'appliquer
ansible-playbook Playbooks/hardening-server.yml -i inventory.ini --check

# Avec extra variables
ansible-playbook Playbooks/gitlab-install.yml -i inventory.ini -e "gitlab_version=15.0"

# Limiter à certains tags
ansible-playbook Playbooks/monitoring-stack-deploy.yml -i inventory.ini -t "grafana,prometheus"
```

## 📁 Structure

Chaque playbook :
- Appelle des **rôles** (voir dossier `../roles/`)
- Supporte les **tags** pour granularité
- Inclut des **handlers** pour redémarrages intelligents
- Utilise des **variables** (defaults, host_vars, group_vars)
- Doté d'un petit **bloc de documentation** en en-tête

## ⚠️ Prérequis

- Ansible >= 2.9
- Inventaire configuré (`inventory.ini`)
- Accès SSH aux serveurs cibles
- Permissions sudoer (ou connexion root)

---

**Pour aller plus loin** : voir `../roles/README.md` pour les rôles individuels et leur réutilisation.
