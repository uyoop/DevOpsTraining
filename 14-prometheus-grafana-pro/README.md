# TP14 - Prometheus + Grafana Production 🚀

Stack de monitoring production-ready avec Prometheus, Grafana, Loki, Alertmanager, Traefik et dashboards avancés pour une observabilité complète.

## 📋 Table des Matières

- [Vue d'ensemble](#vue-densemble)
- [Architecture](#architecture)
- [Prérequis](#prérequis)
- [Installation](#installation)
- [Configuration](#configuration)
- [Dashboards Grafana](#dashboards-grafana)
- [Alerting](#alerting)
- [Logs avec Loki](#logs-avec-loki)
- [Monitoring des endpoints](#monitoring-des-endpoints)
- [Backup & Restore](#backup--restore)
- [Sécurité](#sécurité)
- [Performance](#performance)
- [Dépannage](#dépannage)
- [Ressources](#ressources)

## 🎯 Vue d'ensemble

Stack de monitoring enterprise-grade pour la production avec :
- **Prometheus** : Collecte et stockage des métriques (30 jours de rétention)
- **Grafana** : Visualisation avancée avec dashboards professionnels
- **Loki** : Agrégation et exploration des logs
- **Alertmanager** : Routing intelligent des alertes (Email, Slack, PagerDuty)
- **Traefik** : Reverse proxy avec SSL/TLS automatique
- **Blackbox Exporter** : Monitoring des endpoints HTTP/HTTPS
- **Node Exporter** : Métriques système détaillées
- **cAdvisor** : Métriques conteneurs Docker

### Composants

| Service | Port | Accès | Description |
|---------|------|-------|-------------|
| **Traefik** | 80/443 | traefik.domain.com | Reverse proxy + SSL |
| **Grafana** | 3000 | grafana.domain.com | Dashboards & visualisation |
| **Prometheus** | 9090 | prometheus.domain.com | Métriques & queries |
| **Alertmanager** | 9093 | alertmanager.domain.com | Gestion des alertes |
| **Loki** | 3100 | Backend only | Agrégateur de logs |
| **Node Exporter** | 9100 | Backend only | Métriques système |
| **cAdvisor** | 8080 | Backend only | Métriques conteneurs |
| **Blackbox** | 9115 | Backend only | Probes HTTP/TCP |

## 🏗️ Architecture

```
                    ┌─────────────────────────────────────────┐
                    │         Internet / Users                │
                    └──────────────────┬──────────────────────┘
                                       │
                                       │ HTTPS (443)
                                       │
                    ┌──────────────────▼──────────────────────┐
                    │          Traefik v3                     │
                    │  • SSL/TLS (Let's Encrypt)              │
                    │  • Rate Limiting                        │
                    │  • Security Headers                     │
                    │  • Basic Auth                           │
                    └───┬──────────┬──────────┬────────────┬──┘
                        │          │          │            │
          ┌─────────────┼──────────┼──────────┼────────────┼──────────┐
          │  Public     │          │          │            │          │
          │  Network    │          │          │            │          │
          └─────────────┼──────────┼──────────┼────────────┼──────────┘
                        │          │          │            │
             ┌──────────▼─┐  ┌─────▼────┐  ┌─▼─────────┐ ┌▼──────────┐
             │  Grafana   │  │Prometheus│  │Alertmanager│ │  Traefik  │
             │   :3000    │  │  :9090   │  │   :9093    │ │ Dashboard │
             └──────┬─────┘  └─────┬────┘  └─────┬──────┘ └───────────┘
                    │              │              │
          ┌─────────┼──────────────┼──────────────┼──────────────────────┐
          │ Backend │              │              │                      │
          │ Network │              │              │                      │
          │(Internal)              │              │                      │
          └─────────┼──────────────┼──────────────┼──────────────────────┘
                    │              │              │
       ┌────────────┼──────┬───────┼──────┬───────┼──────┬────────┐
       │            │      │       │      │       │      │        │
  ┌────▼───┐  ┌────▼───┐ ┌▼───────▼┐  ┌──▼───────▼┐  ┌─▼────┐  │
  │  Loki  │  │Promtail│ │   Node   │  │  cAdvisor │  │Black-│  │
  │ :3100  │  │ :9080  │ │ Exporter │  │   :8080   │  │ box  │  │
  └────────┘  └────────┘ │  :9100   │  └───────────┘  │ :9115│  │
                          └──────────┘                  └──────┘  │
                                                                   │
                          ┌────────────────────────────────────────┘
                          │
                    ┌─────▼─────┐
                    │   Docker  │
                    │   Host    │
                    └───────────┘

        Alerting Channels:
        ┌────────────┐  ┌─────────┐  ┌──────────┐
        │   Email    │  │  Slack  │  │PagerDuty │
        └────────────┘  └─────────┘  └──────────┘
```

## ✅ Prérequis

### Infrastructure

- Docker Engine 20.10+
- Docker Compose 2.0+
- 4+ CPU cores
- 8GB+ RAM
- 50GB+ espace disque libre
- Domaine configuré avec DNS A records

### Ports à ouvrir

```bash
# Firewall rules
sudo ufw allow 80/tcp    # HTTP
sudo ufw allow 443/tcp   # HTTPS
```

### DNS Configuration

Créer les enregistrements DNS suivants :

```
A    grafana.monitoring.example.com      → YOUR_SERVER_IP
A    prometheus.monitoring.example.com   → YOUR_SERVER_IP
A    alertmanager.monitoring.example.com → YOUR_SERVER_IP
A    traefik.monitoring.example.com      → YOUR_SERVER_IP
```

## 🚀 Installation

### 1. Cloner et configurer

```bash
cd 14-prometheus-grafana-pro
cp .env.example .env
```

### 2. Configurer les variables d'environnement

```bash
nano .env
```

**Variables critiques à configurer :**

```env
# Domain
DOMAIN=monitoring.example.com
LETSENCRYPT_EMAIL=admin@example.com

# Traefik Auth (générer avec: htpasswd -nb admin password)
TRAEFIK_AUTH=admin:$$apr1$$...

# Grafana
GRAFANA_ADMIN_USER=admin
GRAFANA_ADMIN_PASSWORD=your_secure_password

# SMTP (pour Grafana et Alertmanager)
SMTP_HOST=smtp.gmail.com:587
SMTP_USER=your-email@gmail.com
SMTP_PASSWORD=your-app-password

# Alertmanager
ALERT_SMTP_TO=oncall@example.com

# Slack (optionnel)
SLACK_WEBHOOK_URL=https://hooks.slack.com/services/YOUR/WEBHOOK/URL

# PagerDuty (optionnel)
PAGERDUTY_SERVICE_KEY=your-pagerduty-key
```

### 3. Générer les credentials

```bash
# Générer Basic Auth pour Traefik
htpasswd -nb admin your_password

# Générer mot de passe fort
openssl rand -base64 32
```

### 4. Démarrer le stack

```bash
docker compose up -d
```

### 5. Vérifier le déploiement

```bash
# Vérifier les conteneurs
docker compose ps

# Vérifier les logs
docker compose logs -f

# Attendre la génération SSL (Let's Encrypt)
# Cela peut prendre 1-2 minutes
```

### 6. Accéder aux services

- **Grafana** : https://grafana.monitoring.example.com
  - Login : admin / votre_mot_de_passe
  
- **Prometheus** : https://prometheus.monitoring.example.com
  - Basic Auth requis
  
- **Alertmanager** : https://alertmanager.monitoring.example.com
  - Basic Auth requis
  
- **Traefik Dashboard** : https://traefik.monitoring.example.com
  - Basic Auth requis

## ⚙️ Configuration

### Prometheus

**Rétention des données** : 30 jours (modifiable dans docker-compose.yml)

```yaml
command:
  - '--storage.tsdb.retention.time=30d'
```

**Targets configurés** :
- Prometheus self-monitoring
- Node Exporter (métriques système)
- cAdvisor (métriques conteneurs)
- Grafana
- Traefik
- Loki
- Alertmanager
- Blackbox Exporter (probes)

### Alertmanager

**Routing des alertes** :

```yaml
Critical → PagerDuty + Slack + Email (repeat: 1h)
Warning  → Slack + Email (repeat: 4h)
Info     → Slack (repeat: 24h)
```

**Inhibition rules** :
- Les alertes critiques inhibent les warnings
- Instance Down inhibe toutes les autres alertes sur cette instance
- Service Down inhibe les alertes pour ce service

### Grafana

**Data Sources auto-provisionnés** :
- Prometheus (default)
- Loki
- Alertmanager

**Plugins installés** :
- grafana-piechart-panel
- grafana-clock-panel

### Loki

**Configuration** :
- Rétention : 31 jours
- Stockage : Filesystem (BoltDB)
- Compression : Activée
- Rate limits : 10MB/s ingestion

## 📊 Dashboards Grafana

### Dashboards Recommandés

Importer ces dashboards depuis Grafana.com :

#### 1. Node Exporter Full
- **ID** : 1860
- **Description** : Métriques système complètes
- **Variables** : instance, job

#### 2. Docker Container & Host Metrics
- **ID** : 179
- **Description** : Métriques Docker avec cAdvisor

#### 3. Prometheus 2.0 Stats
- **ID** : 3662
- **Description** : Statistiques internes Prometheus

#### 4. Traefik 2.0
- **ID** : 11462
- **Description** : Métriques Traefik et reverse proxy

#### 5. Loki Logs
- **ID** : 13639
- **Description** : Exploration et analyse de logs

### Créer un Dashboard Custom

1. Login à Grafana
2. **Create > Dashboard**
3. **Add Panel**
4. Choisir la visualisation (Graph, Gauge, Table, etc.)
5. Configurer la query PromQL
6. Sauvegarder

**Exemple de panel CPU Usage** :

```promql
# Query
100 - (avg by(instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)

# Legend
{{ instance }} CPU Usage
```

## 🚨 Alerting

### Alertes Configurées

#### Node Alerts (système)

| Alerte | Seuil | Durée | Sévérité |
|--------|-------|-------|----------|
| ProductionCriticalCPULoad | > 95% | 2min | Critical |
| ProductionHighCPULoad | > 80% | 5min | Warning |
| ProductionCriticalMemoryUsage | > 95% | 2min | Critical |
| ProductionHighMemoryUsage | > 80% | 5min | Warning |
| ProductionCriticalDiskUsage | > 95% | 2min | Critical |
| ProductionHighDiskUsage | > 85% | 5min | Warning |
| ProductionInstanceDown | N/A | 1min | Critical |
| DiskWillFillSoon | Predict 4h | 5min | Warning |
| HighLoadAverage | > 2x CPU | 5min | Warning |
| HighNetworkErrors | > 10/sec | 5min | Warning |

#### Container Alerts (Docker)

| Alerte | Seuil | Durée | Sévérité |
|--------|-------|-------|----------|
| ProductionContainerDown | N/A | 1min | Critical |
| ContainerRestartingFrequently | > 3/15min | 5min | Warning |
| ContainerMemoryOOMRisk | > 95% | 2min | Critical |
| ContainerHighMemoryUsage | > 80% | 5min | Warning |
| ContainerCPUThrottling | > 30% | 5min | Warning |
| ContainerHighCPUUsage | > 90% | 5min | Warning |
| ContainerDiskIOSaturation | > 50MB/s | 10min | Warning |

#### Service Alerts (applications)

| Alerte | Condition | Durée | Sévérité |
|--------|-----------|-------|----------|
| ServiceDown | up == 0 | 1min | Critical |
| GrafanaDown | N/A | 2min | Critical |
| LokiDown | N/A | 2min | Critical |
| HTTPEndpointDown | probe_success == 0 | 2min | Critical |
| HTTPSlowResponse | > 5s | 5min | Warning |
| SSLCertificateExpiringSoon | < 7 days | 1h | Warning |
| SSLCertificateExpiringVerySoon | < 1 day | 1h | Critical |

### Tester les alertes

```bash
# Simuler charge CPU
stress --cpu 8 --timeout 300s

# Simuler charge mémoire
stress --vm 1 --vm-bytes 2G --timeout 300s

# Stopper un conteneur critique
docker stop grafana
# Attendre 1-2 minutes → alerte GrafanaDown

# Redémarrer
docker start grafana
```

### Silencer des alertes

1. Aller dans Alertmanager : https://alertmanager.monitoring.example.com
2. Cliquer sur **Silence**
3. Créer un silence :
   - **Matchers** : `alertname="HighCPULoad"`
   - **Duration** : 2h
   - **Comment** : "Maintenance planifiée"
4. Cliquer **Create**

## 📝 Logs avec Loki

### Explorer les logs dans Grafana

1. Aller dans **Explore** (icône boussole)
2. Sélectionner **Loki** comme data source
3. Utiliser LogQL pour requêter

**Exemples LogQL** :

```logql
# Tous les logs d'un conteneur
{container="grafana"}

# Logs avec niveau ERROR
{container="grafana"} |= "error"

# Logs du dernier 1h
{container="prometheus"} [1h]

# Compter les erreurs par conteneur
sum by(container) (count_over_time({job="docker"}[5m] |= "error"))

# Taux d'erreur sur 5 minutes
rate({container="grafana"}[5m] |= "error")

# Logs de plusieurs conteneurs
{container=~"prometheus|grafana|loki"}

# Exclure des patterns
{container="nginx"} != "GET /health"

# Parser JSON logs
{container="app"} | json | level="error"
```

### Alertes basées sur les logs

Créer une alerte Loki dans `loki/loki-config.yml` :

```yaml
ruler:
  alertmanager_url: http://alertmanager:9093
  
  # Exemple: trop d'erreurs dans les logs
  groups:
    - name: log_alerts
      rules:
        - alert: HighErrorRate
          expr: |
            sum(rate({job="docker"} |= "error" [5m])) > 10
          for: 5m
          labels:
            severity: warning
          annotations:
            summary: "High error rate in logs"
```

## 🔍 Monitoring des Endpoints

### Blackbox Exporter

Monitoring actif des endpoints HTTP/HTTPS configuré dans `prometheus/prometheus.yml` :

```yaml
- job_name: 'blackbox'
  metrics_path: /probe
  params:
    module: [http_2xx]
  static_configs:
    - targets:
      - https://grafana.monitoring.example.com
      - https://prometheus.monitoring.example.com
```

### Métriques disponibles

```promql
# Endpoint disponible (1 = UP, 0 = DOWN)
probe_success

# Durée de réponse (secondes)
probe_duration_seconds

# Code HTTP
probe_http_status_code

# Durée SSL handshake
probe_ssl_earliest_cert_expiry

# Vérifier si HTTPS fonctionne
probe_http_ssl
```

### Queries utiles

```promql
# Endpoints DOWN
probe_success == 0

# Temps de réponse > 2 secondes
probe_duration_seconds > 2

# Certificat SSL expire dans moins de 30 jours
(probe_ssl_earliest_cert_expiry - time()) / 86400 < 30
```

## 💾 Backup & Restore

### Backup Manuel

```bash
./scripts/backup.sh
```

**Le script sauvegarde** :
- Données Prometheus (TSDB)
- Données Grafana (dashboards, users, settings)
- Données Loki (logs)
- Données Alertmanager (silences, etc.)
- Toutes les configurations

**Emplacement** : `/backups/monitoring_backup_YYYYMMDD_HHMMSS.tar.gz`

**Rétention** : 7 jours (automatique)

### Backup Automatisé

**Créer un cron job** :

```bash
# Éditer crontab
crontab -e

# Ajouter backup quotidien à 2h du matin
0 2 * * * cd /path/to/14-prometheus-grafana-pro && ./scripts/backup.sh >> /var/log/monitoring-backup.log 2>&1
```

### Restore

```bash
./scripts/restore.sh /backups/monitoring_backup_20241207_153000.tar.gz
```

**Le script va** :
1. Extraire l'archive
2. Afficher le manifest
3. Demander confirmation
4. Stopper les services
5. Restaurer tous les volumes
6. Restaurer les configurations
7. Redémarrer les services

## 🔐 Sécurité

### SSL/TLS

- **Certificats automatiques** via Let's Encrypt
- **HSTS** : Strict-Transport-Security activé
- **TLS 1.2+** minimum
- **Renouvellement automatique** des certificats

### Authentification

- **Basic Auth** sur Prometheus, Alertmanager, Traefik
- **Login Grafana** avec user/password
- **API tokens** Grafana pour intégrations

### Network Segmentation

- **Public Network** : Traefik uniquement
- **Backend Network** : Services internes (isolé)

### Security Headers

```yaml
# Configuré dans traefik/dynamic/middlewares.yml
- Content-Type-Options: nosniff
- X-Frame-Options: SAMEORIGIN
- Referrer-Policy: strict-origin-when-cross-origin
- Permissions-Policy: geolocation=(), microphone=(), camera=()
```

### Rate Limiting

```yaml
# 100 requêtes/minute en moyenne
# Burst de 50 requêtes
average: 100
period: 1m
burst: 50
```

### Bonnes Pratiques

```bash
# 1. Changer TOUS les mots de passe par défaut
# 2. Utiliser des mots de passe forts (32+ caractères)
# 3. Activer 2FA sur Grafana
# 4. Limiter l'accès IP (optional)
# 5. Audit régulier des logs
# 6. Mettre à jour régulièrement les images Docker
```

## 🚀 Performance

### Optimisations Appliquées

#### Recording Rules

Métriques pré-calculées pour accélérer les queries :

```promql
# Au lieu de calculer à chaque fois:
100 - (avg by(instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)

# Utiliser la recording rule:
instance:node_cpu_usage:avg5m
```

#### Prometheus

- **WAL Compression** : Activée
- **Retention** : 30 jours (ajustable)
- **Admin API** : Activée pour maintenance

#### Grafana

- **Query caching** : Activé automatiquement
- **Dashboard variables** : Utiliser des variables pour filtrage efficace

#### Loki

- **Compression** : Activée
- **Index caching** : 24h
- **Retention** : 31 jours

### Monitoring des Performances

```promql
# Taux d'ingestion Prometheus (samples/s)
rate(prometheus_tsdb_head_samples_appended_total[5m])

# Utilisation mémoire Prometheus
process_resident_memory_bytes{job="prometheus"}

# Durée des queries Prometheus
prometheus_engine_query_duration_seconds

# Taux d'ingestion Loki (bytes/s)
sum(rate(loki_distributor_bytes_received_total[5m]))
```

## 🔧 Dépannage

### Services ne démarrent pas

```bash
# Vérifier les logs
docker compose logs -f

# Vérifier les configurations
docker compose config

# Restart complet
docker compose down
docker compose up -d
```

### Certificats SSL ne se génèrent pas

```bash
# Vérifier les logs Traefik
docker compose logs traefik

# Vérifier DNS (doit pointer vers votre serveur)
dig grafana.monitoring.example.com

# Vérifier ports 80/443 ouverts
sudo netstat -tlnp | grep :80
sudo netstat -tlnp | grep :443

# Fichier acme.json doit avoir permissions 600
chmod 600 letsencrypt/acme.json
```

### Pas de données dans Grafana

```bash
# Vérifier data source
# Grafana → Configuration → Data Sources → Prometheus → Test

# Vérifier targets Prometheus
# Prometheus → Status → Targets (tous doivent être UP)

# Vérifier connectivité
docker compose exec grafana wget -O- http://prometheus:9090/api/v1/query?query=up
```

### Alertes ne fonctionnent pas

```bash
# Vérifier configuration Alertmanager
docker compose exec alertmanager amtool check-config /etc/alertmanager/config.yml

# Vérifier règles Prometheus
docker compose exec prometheus promtool check rules /etc/prometheus/rules/*.yml

# Tester une alerte manuellement
curl -H 'Content-Type: application/json' -d '[{"labels":{"alertname":"test"}}]' \
  http://localhost:9093/api/v1/alerts
```

### Problèmes de performance

```bash
# Vérifier utilisation ressources
docker stats

# Nettoyer données anciennes Prometheus
docker compose exec prometheus curl -X POST http://localhost:9090/api/v1/admin/tsdb/delete_series?match[]={__name__=~".+"}

# Compacter données
docker compose exec prometheus curl -X POST http://localhost:9090/api/v1/admin/tsdb/compact
```

### Loki ne reçoit pas de logs

```bash
# Vérifier Promtail
docker compose logs promtail

# Vérifier connectivité Loki
docker compose exec promtail wget -O- http://loki:3100/ready

# Test query Loki
curl -G -s "http://localhost:3100/loki/api/v1/query" --data-urlencode 'query={job="docker"}'
```

## 📚 Ressources

### Documentation Officielle

- [Prometheus](https://prometheus.io/docs/)
- [Grafana](https://grafana.com/docs/)
- [Loki](https://grafana.com/docs/loki/latest/)
- [Alertmanager](https://prometheus.io/docs/alerting/latest/alertmanager/)
- [Traefik](https://doc.traefik.io/traefik/)
- [Blackbox Exporter](https://github.com/prometheus/blackbox_exporter)

### Guides et Tutoriels

- [PromQL Tutorial](https://promlabs.com/promql-cheat-sheet/)
- [LogQL Tutorial](https://grafana.com/docs/loki/latest/logql/)
- [Grafana Dashboards](https://grafana.com/grafana/dashboards/)
- [Alert Rule Examples](https://awesome-prometheus-alerts.grep.to/)

### Communautés

- [Prometheus Community](https://prometheus.io/community/)
- [Grafana Community](https://community.grafana.com/)
- [CNCF Slack](https://slack.cncf.io/)

## 🎓 Objectifs Pédagogiques

Après avoir complété ce TP, vous serez capable de :

✅ Déployer un stack monitoring production-ready complet  
✅ Configurer Prometheus avec recording rules et optimisations  
✅ Créer et gérer des dashboards Grafana avancés  
✅ Implémenter un système d'alerting multi-canal  
✅ Agréger et explorer des logs avec Loki  
✅ Monitorer des endpoints avec Blackbox Exporter  
✅ Sécuriser un stack monitoring avec SSL/TLS et auth  
✅ Automatiser backups et restore  
✅ Optimiser les performances d'un système d'observabilité  
✅ Débugger et résoudre des problèmes de monitoring  

## 🚀 Évolutions Possibles

1. **High Availability** : Déployer Prometheus et Alertmanager en HA
2. **Long-term Storage** : Intégrer Thanos pour stockage illimité
3. **Distributed Tracing** : Ajouter Tempo pour les traces
4. **Service Mesh** : Intégrer avec Istio/Linkerd
5. **Kubernetes** : Adapter pour K8s avec Prometheus Operator

## 📝 Licence

Ce projet fait partie du repository CJ-DEVOPS - Portfolio DevOps.

---

**Auteur** : CJenkins-AFPA  
**Dernière mise à jour** : Décembre 2024  
**Version Prometheus** : 2.50.1  
**Version Grafana** : 10.3.3  
**Version Loki** : 2.9.4  
**Version Traefik** : 3.0
