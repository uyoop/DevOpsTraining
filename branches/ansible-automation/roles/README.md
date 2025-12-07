# Roles Ansible - Briques Réutilisables DevOps

Ensemble de rôles Ansible conçus pour être réutilisables, maintenables et conformes aux bonnes pratiques (structure Ansible Galaxy, variables bien documentées, tests de compatibilité).

Chaque rôle respecte la structure officielle Ansible et inclut : `tasks/`, `defaults/`, `templates/`, `handlers/`, `files/`, `meta/`.

---

## 📋 Liste des Rôles

### Système & OS

#### `system-update`
- **Description** : Mise à jour sécurisée des paquets système, noyau, configurations.
- **Tâches clés** :
  - Mise à jour des repos + dépôts distants
  - Upgrade des paquets (apt/yum)
  - Gestion des redémarrages (contrôlé)
  - Rollback en cas d'erreur critique
- **Variables** :
  - `system_update_auto_reboot`: true/false (redémarrage auto après update)
  - `system_update_reboot_delay`: délai avant redémarrage
- **Compatibilité** : CentOS, Ubuntu, Debian
- **Utilisé par** : `Playbooks/system-update.yml`

#### `user`
- **Description** : Gestion centralisée des utilisateurs, groupes, clés SSH.
- **Tâches clés** :
  - Créer/modifier/supprimer utilisateurs
  - Gérer les clés SSH (déploiement, rotation)
  - Configurer sudoers (privilèges)
  - Gestion des répertoires home
  - Audit des permissions
- **Variables** :
  - `users`: liste des users (name, uid, groups, ssh_keys)
  - `user_shell_default`: /bin/bash (par défaut)
- **Compatibilité** : Tous les Unix/Linux
- **Utilisé par** : `Playbooks/user-management.yml`

#### `ssh-hardening`
- **Description** : Durcissement de la configuration SSH (sshd_config).
- **Tâches clés** :
  - Désactiver l'authentification par mot de passe root
  - Désactiver SSH v1, configurer ciphers forts
  - Limiter les tentatives de connexion
  - Configurer des timeouts de session
  - Logger tous les accès SSH
- **Variables** :
  - `ssh_permit_root_login`: false
  - `ssh_password_auth`: false
  - `ssh_pubkey_auth`: true
- **Utilisé par** : `Playbooks/hardening-server.yml`, `Playbooks/user-management.yml`

#### `firewall`
- **Description** : Configuration du pare-feu (UFW sur Ubuntu, firewalld sur CentOS).
- **Tâches clés** :
  - Activer le pare-feu
  - Ajouter des règles (allow/deny ports)
  - Gérer les zones (public, trusted, etc.)
  - Logging des rejets
  - Gestion des chaînes iptables avancées
- **Variables** :
  - `firewall_allowed_ports`: [22, 80, 443]
  - `firewall_rules`: liste de règles custom
  - `firewall_enable_logging`: true/false
- **Compatibilité** : Ubuntu/Debian (UFW), CentOS/RHEL (firewalld)
- **Utilisé par** : `Playbooks/firewall-configure.yml`

#### `fail2ban`
- **Description** : Installation et configuration de Fail2ban (blocage IP après tentatives).
- **Tâches clés** :
  - Installer fail2ban
  - Configurer les jails (SSH, HTTP, etc.)
  - Définir les seuils (nbr tentatives, durée ban)
  - Intégration avec firewall
  - Actions (iptables, sendmail, webhook)
- **Variables** :
  - `fail2ban_bantime`: 3600 (1h par défaut)
  - `fail2ban_maxretry`: 5
  - `fail2ban_jails`: [sshd, recidive]
- **Utilisé par** : `Playbooks/hardening-server.yml`

#### `selinux`
- **Description** : Configuration de SELinux (enforcing, policies).
- **Tâches clés** :
  - Installer SELinux
  - Configurer mode (enforcing/permissive/disabled)
  - Charger des policies custom
  - Gérer les contextes de fichiers
- **Variables** :
  - `selinux_policy`: targeted
  - `selinux_state`: enforcing
- **Compatibilité** : CentOS, RHEL, Fedora
- **Utilisé par** : `Playbooks/hardening-server.yml`

#### `auditd`
- **Description** : Configuration d'Auditd (audit du système, compliance).
- **Tâches clés** :
  - Installer auditd
  - Configurer des règles d'audit (fichiers, syscalls, users)
  - Centraliser les logs d'audit
  - Alertes sur événements critiques
- **Variables** :
  - `audit_rules`: liste de règles custom
  - `audit_log_retention`: 365
- **Utilisé par** : `Playbooks/compliance-audit.yml`

---

### Conteneurisation

#### `docker`
- **Description** : Installation et configuration de Docker + Docker Compose.
- **Tâches clés** :
  - Installer Docker engine
  - Configurer le daemon (storage driver, registries, logging)
  - Installer Docker Compose
  - Configurer le service systemd
  - Gérer les droits utilisateur
- **Variables** :
  - `docker_version`: latest (par défaut)
  - `docker_storage_driver`: overlay2
  - `docker_insecure_registries`: []
  - `docker_users`: [ubuntu, jenkins]
- **Compatibilité** : Ubuntu, Debian, CentOS
- **Utilisé par** : `Playbooks/docker-install.yml`, `Playbooks/docker-registry-deploy.yml`

#### `docker-registry`
- **Description** : Déploiement d'un registry Docker privé (TLS, authentification).
- **Tâches clés** :
  - Créer les volumes de stockage
  - Générer les certificats TLS
  - Configurer l'authentification (htpasswd)
  - Déployer via docker-compose ou conteneur
  - Garbage collection, réplication
- **Variables** :
  - `registry_port`: 5000
  - `registry_storage_path`: /data/registry
  - `registry_tls_cert`: /certs/cert.crt
  - `registry_htpasswd_users`: [{user: admin, pass: xxxx}]
- **Utilisé par** : `Playbooks/docker-registry-deploy.yml`

#### `kubernetes-master`
- **Description** : Installation et configuration du master Kubernetes.
- **Tâches clés** :
  - Installer kubeadm, kubelet, kubectl
  - Initialiser le cluster (kubeadm init)
  - Configurer kubeconfig
  - Installer CNI (Flannel, Calico)
  - Configurer RBAC, namespaces
- **Variables** :
  - `kubernetes_version`: 1.28
  - `kubernetes_pod_network_cidr`: 10.244.0.0/16
  - `kubernetes_apiserver_advertise_address`: 10.0.0.1
- **Utilisé par** : `Playbooks/kubernetes-setup.yml`

#### `kubernetes-worker`
- **Description** : Installation du worker node Kubernetes.
- **Tâches clés** :
  - Installer kubeadm, kubelet
  - Joindre le cluster (kubeadm join avec token)
  - Configurer kubelet
  - Labels et taints
- **Variables** :
  - `kubernetes_join_command`: Token + cert CA
  - `kubernetes_node_labels`: {role: worker}
- **Utilisé par** : `Playbooks/kubernetes-setup.yml`

#### `cni-plugin`
- **Description** : Installation des plugins réseau Kubernetes (Flannel, Calico, Weave).
- **Tâches clés** :
  - Déployer le manifest CNI
  - Configurer les paramètres réseau
  - Vérifier les pods réseau
- **Variables** :
  - `cni_plugin`: flannel (ou calico, weave)
- **Utilisé par** : `Playbooks/kubernetes-setup.yml`

---

### Git & CI/CD

#### `gitlab`
- **Description** : Installation complète de GitLab (server, PostgreSQL, Redis, Minio).
- **Tâches clés** :
  - Installer GitLab package
  - Configurer PostgreSQL + Redis
  - Configurer SSL/TLS
  - Initialiser les secrets
  - Configuration email/integrations
  - Backups automatiques
- **Variables** :
  - `gitlab_version`: 15.0
  - `gitlab_external_url`: https://gitlab.example.com
  - `gitlab_db_password`: xxxx
  - `gitlab_smtp_enabled`: true
- **Utilisé par** : `Playbooks/gitlab-install.yml`

#### `gitlab-runner`
- **Description** : Installation et configuration du runner GitLab CI/CD.
- **Tâches clés** :
  - Installer le runner
  - Enregistrer auprès du serveur GitLab
  - Configurer les exécuteurs (shell, docker, k8s)
  - Caching, artifacts
  - Tokens de registration sécurisés
- **Variables** :
  - `gitlab_runner_version`: latest
  - `gitlab_runner_executors`: [shell, docker]
  - `gitlab_runner_docker_image`: ubuntu:22.04
- **Utilisé par** : `Playbooks/gitlab-runner-install.yml`

#### `jenkins`
- **Description** : Installation de Jenkins + plugins essentiels.
- **Tâches clés** :
  - Installer Jenkins (WAR)
  - Configurer Java, service systemd
  - Installer plugins (Git, Pipeline, Docker)
  - Configurer sécurité, utilisateurs
  - Backups de configuration
- **Variables** :
  - `jenkins_version`: latest
  - `jenkins_plugins`: [workflow-aggregator, git, docker]
  - `jenkins_admin_user`: admin
- **Utilisé par** : `Playbooks/jenkins-install.yml`

#### `jenkins-plugins`
- **Description** : Gestion avancée des plugins Jenkins.
- **Tâches clés** :
  - Installer/mettre à jour plugins
  - Configurer les plugins
  - Reload Jenkins si besoin
- **Variables** :
  - `jenkins_plugins_list`: [{name: git, version: latest}]
- **Utilisé par** : `Playbooks/jenkins-install.yml`

#### `gitea`
- **Description** : Installation de Gitea (Git lightweight).
- **Tâches clés** :
  - Installer Gitea
  - Configurer la DB (SQLite ou PostgreSQL)
  - Configuration SSL/TLS
  - Webhooks, intégrations
  - Migrations depuis GitHub
- **Variables** :
  - `gitea_version`: latest
  - `gitea_db_type`: postgres (ou sqlite3)
  - `gitea_domain`: gitea.example.com
- **Utilisé par** : `Playbooks/gitea-install.yml`

---

### Monitoring & Observabilité

#### `prometheus`
- **Description** : Installation de Prometheus (collecteur de métriques).
- **Tâches clés** :
  - Installer Prometheus
  - Configurer scrape configs (targets)
  - Configurer les règles d'alerte
  - Configurer Alertmanager
  - Retention des données
- **Variables** :
  - `prometheus_version`: latest
  - `prometheus_retention`: 15d
  - `prometheus_scrape_interval`: 15s
- **Utilisé par** : `Playbooks/monitoring-stack-deploy.yml`

#### `grafana`
- **Description** : Installation de Grafana (dashboards et visualisation).
- **Tâches clés** :
  - Installer Grafana
  - Configurer les datasources (Prometheus, Elasticsearch)
  - Importer des dashboards préexistants
  - Configurer les alertes
  - Authentification (LDAP, OAuth)
- **Variables** :
  - `grafana_version`: latest
  - `grafana_admin_password`: xxxx
  - `grafana_datasources`: [{name: Prometheus, url: http://localhost:9090}]
- **Utilisé par** : `Playbooks/monitoring-stack-deploy.yml`

#### `alertmanager`
- **Description** : Installation d'Alertmanager (gestion des alertes).
- **Tâches clés** :
  - Installer Alertmanager
  - Configurer les routes (grouping, matching)
  - Intégrer les notificateurs (mail, Slack, PagerDuty)
  - Templates d'alertes
  - Inhibition de bruits
- **Variables** :
  - `alertmanager_version`: latest
  - `alertmanager_slack_webhook`: https://hooks.slack.com/...
  - `alertmanager_mail_smtp_smarthost`: smtp.example.com
- **Utilisé par** : `Playbooks/monitoring-stack-deploy.yml`

#### `node-exporter`
- **Description** : Installation de Prometheus Node Exporter.
- **Tâches clés** :
  - Installer node_exporter
  - Configurer les collectors actifs
  - Service systemd
  - Configuration du firewall pour Prometheus
- **Variables** :
  - `node_exporter_version`: latest
  - `node_exporter_port`: 9100
  - `node_exporter_collectors`: [diskstats, filesystem, meminfo]
- **Utilisé par** : `Playbooks/node-exporter-install.yml`

#### `elasticsearch`
- **Description** : Installation d'Elasticsearch (moteur de logs/recherche).
- **Tâches clés** :
  - Installer Elasticsearch
  - Configurer le cluster (nodes, shards, replicas)
  - Configurer la sécurité (authentification, chiffrement)
  - Snapshots/backups
- **Variables** :
  - `elasticsearch_version`: 7.10
  - `elasticsearch_cluster_name`: mycluster
  - `elasticsearch_discovery_seed_hosts`: [es1, es2, es3]
- **Utilisé par** : `Playbooks/logging-stack-deploy.yml`

#### `kibana`
- **Description** : Installation de Kibana (UI pour Elasticsearch).
- **Tâches clés** :
  - Installer Kibana
  - Configurer l'URL d'Elasticsearch
  - Paramètres d'index
  - Dashboards et visualisations
- **Variables** :
  - `kibana_version`: 7.10
  - `kibana_elasticsearch_url`: http://elasticsearch:9200
- **Utilisé par** : `Playbooks/logging-stack-deploy.yml`

#### `logstash`
- **Description** : Installation de Logstash (pipeline d'ingestion de logs).
- **Tâches clés** :
  - Installer Logstash
  - Configurer les pipelines (input, filter, output)
  - Tester les configurations
- **Variables** :
  - `logstash_version`: 7.10
  - `logstash_pipelines_config_dir`: /etc/logstash/pipelines.yml
- **Utilisé par** : `Playbooks/logging-stack-deploy.yml`

#### `loki`
- **Description** : Installation de Loki (logs lightweight).
- **Tâches clés** :
  - Installer Loki
  - Configurer storage backend
  - Configurer labels de logs
  - Intégration Promtail
- **Variables** :
  - `loki_version`: latest
  - `loki_storage_config_provider`: filesystem
- **Utilisé par** : `Playbooks/loki-install.yml`

#### `promtail`
- **Description** : Installation de Promtail (agent d'envoi de logs vers Loki).
- **Tâches clés** :
  - Installer Promtail
  - Configurer les scrape jobs
  - Labels à l'ingestion
- **Variables** :
  - `promtail_version`: latest
  - `loki_server_address`: http://loki:3100
- **Utilisé par** : `Playbooks/loki-install.yml`

---

### Sécurité & Secrets

#### `letsencrypt`
- **Description** : Installation et configuration de Certbot (Let's Encrypt).
- **Tâches clés** :
  - Installer Certbot
  - Générer les certificats (standalone, webroot, DNS)
  - Configurer auto-renew (cron)
  - Hooks de post-renew (reload services)
- **Variables** :
  - `certbot_email`: admin@example.com
  - `certbot_domains`: [example.com, www.example.com]
  - `certbot_renew_hook_cmd`: systemctl reload nginx
- **Utilisé par** : `Playbooks/ssl-certificate-renew.yml`, de nombreux playbooks web

#### `certbot`
- **Description** : Alternative/complément de letsencrypt, gestion avancée des certs.
- **Utilisé par** : `Playbooks/ssl-certificate-renew.yml`

#### `vault`
- **Description** : Installation de HashiCorp Vault (gestion des secrets).
- **Tâches clés** :
  - Installer Vault
  - Initialiser et unseal le Vault
  - Configurer les auth methods (AppRole, Kubernetes, LDAP)
  - Configurer les secrets engines (database, PKI)
  - Audit logging
- **Variables** :
  - `vault_version`: 1.14
  - `vault_storage_backend`: file (ou consul, s3)
  - `vault_unseal_keys`: [key1, key2, key3]
- **Utilisé par** : `Playbooks/vault-setup.yml`

#### `vault-init`
- **Description** : Initialisation et unseal automatisés de Vault.
- **Tâches clés** :
  - Générer les unseal keys
  - Stocker les clés de manière sécurisée
  - Unseal automatique
- **Utilisé par** : `Playbooks/vault-setup.yml`

---

### Backup & Disaster Recovery

#### `backup-agent`
- **Description** : Installation d'agents de sauvegarde (Restic, Bacula, etc.).
- **Tâches clés** :
  - Installer l'agent de backup
  - Configurer les chemins à sauvegarder
  - Planifier les sauvegardes (cron)
  - Configurer les backends (local, cloud, tape)
  - Vérifier les sauvegardes
- **Variables** :
  - `backup_agent`: restic (ou bacula, duplicity)
  - `backup_paths`: [/home, /var/www]
  - `backup_retention`: 30d
  - `backup_backend`: s3://my-bucket/backups
- **Utilisé par** : `Playbooks/backup-setup.yml`

#### `restic`
- **Description** : Déploiement de Restic (backup incrémental moderne).
- **Tâches clés** :
  - Installer Restic
  - Initialiser les repos
  - Configurer les schedules de backup
  - Vérifier l'intégrité des backups
  - Retention policies
- **Variables** :
  - `restic_version`: latest
  - `restic_repo_locations`: [/mnt/backups, s3://bucket/restic]
- **Utilisé par** : `Playbooks/backup-setup.yml`

#### `postgresql`
- **Description** : Installation et configuration de PostgreSQL.
- **Tâches clés** :
  - Installer PostgreSQL
  - Initialiser la DB
  - Configurer l'authentification (pg_hba.conf)
  - Configurer les paramètres de performance
  - WAL archiving pour PITR
  - Replication (streaming standby)
- **Variables** :
  - `postgresql_version`: 15
  - `postgresql_port`: 5432
  - `postgresql_backup_path`: /var/backups/postgres
- **Utilisé par** : `Playbooks/postgresql-install.yml`, `Playbooks/database-backup.yml`, `Playbooks/gitlab-install.yml`

#### `postgresql-replication`
- **Description** : Configuration de la replication PostgreSQL (master-replica).
- **Tâches clés** :
  - Configurer le master (WAL level, replication slots)
  - Configurer les replicas (standby mode)
  - Vérifier la synchronisation
  - Failover/switchover procedures
- **Variables** :
  - `postgresql_replica_mode`: standby
  - `postgresql_primary_conninfo`: host=master user=replicator
- **Utilisé par** : `Playbooks/postgresql-install.yml`

#### `mysql`
- **Description** : Installation et configuration de MySQL/MariaDB.
- **Tâches clés** :
  - Installer MySQL/MariaDB
  - Initialiser les données
  - Configuration my.cnf
  - Master-slave replication
  - Sauvegarde/restore
- **Variables** :
  - `mysql_version`: 8.0 (ou 5.7, MariaDB)
  - `mysql_port`: 3306
  - `mysql_root_password`: xxxx
- **Utilisé par** : `Playbooks/mysql-install.yml`

#### `mysql-replication`
- **Description** : Configuration de master-slave/master-master MySQL.
- **Utilisé par** : `Playbooks/mysql-install.yml`

#### `mongodb`
- **Description** : Installation de MongoDB (replica set ou sharded cluster).
- **Tâches clés** :
  - Installer MongoDB
  - Initialiser les replica sets
  - Configurer sharding
  - Authentification
  - Backups (mongodump, snapshots)
- **Variables** :
  - `mongodb_version`: 6.0
  - `mongodb_replication_set`: rs0
- **Utilisé par** : `Playbooks/mongodb-install.yml`

#### `redis`
- **Description** : Installation de Redis (cache, session store).
- **Tâches clés** :
  - Installer Redis
  - Configurer persistence (RDB/AOF)
  - Replication (master-slave)
  - Sentinel (haute disponibilité)
  - Cluster (distribution)
- **Variables** :
  - `redis_version`: 7.0
  - `redis_port`: 6379
  - `redis_persistence`: aof
- **Utilisé par** : `Playbooks/redis-install.yml`, `Playbooks/gitlab-install.yml`

---

### Load Balancing & Reverse Proxy

#### `nginx`
- **Description** : Installation et configuration d'Nginx (reverse proxy, load balancer).
- **Tâches clés** :
  - Installer Nginx
  - Configurer les upstream (backends)
  - Load balancing strategies (round-robin, least_conn)
  - Health checks
  - Rate limiting, caching
  - SSL/TLS termination
- **Variables** :
  - `nginx_version`: latest
  - `nginx_upstreams`: [{name: backend, servers: [app1:8000, app2:8000]}]
  - `nginx_cache_enabled`: true
- **Utilisé par** : `Playbooks/nginx-deploy.yml`

#### `haproxy`
- **Description** : Installation et configuration de HAProxy (L4/L7 load balancer).
- **Tâches clés** :
  - Installer HAProxy
  - Configurer les backends et frontends
  - Health checks avancés
  - ACLs
  - Stats socket pour monitoring
  - Stick tables
- **Variables** :
  - `haproxy_version`: latest
  - `haproxy_frontends`: [{name: web, bind: '*:80'}]
- **Utilisé par** : `Playbooks/haproxy-deploy.yml`

#### `traefik`
- **Description** : Installation de Traefik (reverse proxy moderne, labels-based).
- **Tâches clés** :
  - Installer Traefik (via Docker généralement)
  - Configurer les providers (Docker, Kubernetes, File)
  - Middleware (authentification, compression, etc.)
  - Auto-renewal SSL (Let's Encrypt)
- **Variables** :
  - `traefik_version`: v2.10
  - `traefik_providers`: [docker, kubernetes]
- **Utilisé par** : `Playbooks/traefik-deploy.yml`

---

### Outils Supplementaires

#### `ansible-tower`
- **Description** : Installation d'Ansible Tower (contrôleur centralisé).
- **Tâches clés** :
  - Installer Ansible Tower
  - Configurer la DB (PostgreSQL)
  - Configurer RBAC, utilisateurs
  - Licence
  - Inventory management
- **Variables** :
  - `tower_version`: latest
  - `tower_admin_user`: admin
  - `tower_admin_password`: xxxx
- **Utilisé par** : `Playbooks/ansible-tower-install.yml`

#### `container-proxy`
- **Description** : Proxy pour registries Docker (Nexus, Artifactory).
- **Tâches clés** :
  - Installer le proxy
  - Configurer les repos/registries à proxifier
  - Cache et retention
  - Authentification
- **Utilisé par** : `Playbooks/container-registry-proxy.yml`

#### `nexus`
- **Description** : Installation de Nexus (gestionnaire de dépôts/artefacts).
- **Tâches clés** :
  - Installer Nexus
  - Configurer les repositories (Maven, npm, Docker, etc.)
  - Proxies et groupes
  - Cleanup policies
  - RBAC
- **Variables** :
  - `nexus_version`: 3.latest
  - `nexus_port`: 8081
- **Utilisé par** : `Playbooks/artifact-repository-deploy.yml`

#### `artifactory`
- **Description** : Installation d'Artifactory (alternative JFrog).
- **Utilisé par** : `Playbooks/artifact-repository-deploy.yml`

#### `sonarqube`
- **Description** : Installation de SonarQube (code quality, security scanning).
- **Tâches clés** :
  - Installer SonarQube
  - Configurer la DB (PostgreSQL)
  - Plugins (GitHub, GitLab integration)
  - Quality gates
  - Webhooks CI/CD
- **Variables** :
  - `sonarqube_version`: latest
  - `sonarqube_db_type`: postgresql
  - `sonarqube_admin_password`: xxxx
- **Utilisé par** : `Playbooks/sonarqube-install.yml`

#### `pfsense`
- **Description** : Configuration de base pfSense (routeur/pare-feu).
- **Tâches clés** :
  - Configuration WAN/LAN
  - DHCP, DNS
  - NAT, port forwarding
  - Logging, monitoring
- **Variables** :
  - `pfsense_wan_interface`: em0
  - `pfsense_lan_subnet`: 192.168.1.0/24
- **Utilisé par** : `Playbooks/pfsense-install.yml`

#### `pfsense-wan`
- **Description** : Configuration WAN avancée pfSense (PPPoE, 4G, failover).
- **Utilisé par** : `Playbooks/pfsense-install.yml`

#### `pfsense-firewall-rules`
- **Description** : Gestion des règles de pare-feu pfSense.
- **Tâches clés** :
  - Créer/modifier les règles
  - Groupes de règles
  - Logging des rejets
- **Utilisé par** : `Playbooks/pfsense-install.yml`

#### `opnsense`
- **Description** : Configuration d'OPNsense (alternative moderne à pfSense).
- **Tâches clés** :
  - WAN/LAN setup
  - Firewall rules
  - VPN, VLAN
  - High-availability
- **Variables** :
  - `opnsense_version`: 23.latest
- **Utilisé par** : `Playbooks/opnsense-install.yml`

#### `opnsense-rules`
- **Description** : Gestion des règles OPNsense.
- **Utilisé par** : `Playbooks/opnsense-install.yml`

#### `dns-server`
- **Description** : Installation d'un serveur DNS (BIND9, PowerDNS).
- **Tâches clés** :
  - Installer le serveur DNS
  - Configurer les zones
  - Records (A, AAAA, CNAME, MX, etc.)
  - Forwarders, recursion
  - DNSSEC
- **Variables** :
  - `dns_server_type`: bind9 (ou powerdns)
  - `dns_zones`: [{name: example.com, file: ...}]
- **Utilisé par** : `Playbooks/dns-configure.yml`

#### `openvpn`
- **Description** : Installation et configuration d'OpenVPN.
- **Tâches clés** :
  - Installer OpenVPN
  - Générer les certificats (CA, server, clients)
  - Configurer server.conf
  - Gestion des clients (CCD)
  - Firewall rules
- **Variables** :
  - `openvpn_port`: 1194
  - `openvpn_protocol`: udp
  - `openvpn_cipher`: AES-256-GCM
- **Utilisé par** : `Playbooks/vpn-setup.yml`

#### `wireguard`
- **Description** : Installation de WireGuard (VPN moderne, performant).
- **Tâches clés** :
  - Installer WireGuard
  - Générer les paires de clés
  - Configuration interface
  - Gestion des peers
  - Routes
- **Variables** :
  - `wireguard_port`: 51820
  - `wireguard_subnet`: 10.0.0.0/24
- **Utilisé par** : `Playbooks/vpn-setup.yml`

#### `compliance-check`
- **Description** : Vérification de compliance (CIS Benchmarks, GDPR, etc.).
- **Tâches clés** :
  - Vérifier les configurations système
  - Audit des utilisateurs et permissions
  - Vérification des logs
  - Génération de rapports
- **Utilisé par** : `Playbooks/compliance-audit.yml`

#### `kernel-tuning`
- **Description** : Optimization des paramètres du noyau Linux (sysctl).
- **Tâches clés** :
  - Tuning TCP/IP (buffer, timeouts)
  - Tuning mémoire
  - Tuning file descriptors
  - Tuning pour haute charge
- **Variables** :
  - `kernel_sysctl_params`: {net.ipv4.tcp_max_syn_backlog: 65535, ...}
- **Utilisé par** : `Playbooks/system-update.yml`

---

## 🚀 Usage

Appeler un rôle depuis un playbook :

```yaml
---
- hosts: all
  roles:
    - role: docker
      vars:
        docker_users: [ubuntu, jenkins]
    - role: nginx
      tags: [webserver]
    - letsencrypt
```

Ou via inclusion directe :

```yaml
- include_role:
    name: prometheus
  vars:
    prometheus_retention: 30d
```

---

## 📁 Structure standard d'un rôle

```
roles/
  docker/
    tasks/
      main.yml          # Tâches principales
    defaults/
      main.yml          # Variables par défaut
    templates/
      daemon.json.j2    # Templates Jinja2
    handlers/
      main.yml          # Handlers (redémarrage, reload)
    files/
      script.sh         # Fichiers statiques
    meta/
      main.yml          # Dépendances, description
    vars/
      main.yml          # Variables (priorité haute)
    README.md           # Documentation du rôle
```

---

## ⚠️ Prérequis

- Ansible >= 2.9
- Python 3.8+ sur les hôtes cibles
- Accès SSH/sudoer configuré
- Variables d'inventaire (host_vars, group_vars) si besoin

---

## 🔗 Relations Playbooks ↔ Rôles

| Playbook | Rôles appelés |
|----------|---------------|
| system-update.yml | system-update, kernel-tuning |
| user-management.yml | user, ssh-hardening |
| firewall-configure.yml | firewall |
| pfsense-install.yml | pfsense, pfsense-wan, pfsense-firewall-rules |
| docker-install.yml | docker |
| kubernetes-setup.yml | kubernetes-master, kubernetes-worker, cni-plugin |
| gitlab-install.yml | gitlab, gitlab-runner, postgresql, redis, letsencrypt |
| monitoring-stack-deploy.yml | prometheus, grafana, alertmanager |
| logging-stack-deploy.yml | elasticsearch, kibana, logstash |
| backup-setup.yml | backup-agent, restic |
| postgresql-install.yml | postgresql, postgresql-replication |
| nginx-deploy.yml | nginx, letsencrypt |
| vault-setup.yml | vault, vault-init |
| hardening-server.yml | ssh-hardening, fail2ban, selinux, auditd |

---

**Pour aller plus loin** : voir `../Playbooks/README.md` pour les playbooks orchestrant ces rôles.
