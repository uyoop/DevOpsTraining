# TP13 - Prometheus Docker 📊

Stack de monitoring complet avec Prometheus, Node Exporter, cAdvisor et Alertmanager pour surveiller vos systèmes et conteneurs Docker.

## 📋 Table des Matières

- [Vue d'ensemble](#vue-densemble)
- [Architecture](#architecture)
- [Prérequis](#prérequis)
- [Installation](#installation)
- [Configuration](#configuration)
- [Utilisation](#utilisation)
- [Queries PromQL Utiles](#queries-promql-utiles)
- [Alertes](#alertes)
- [Dépannage](#dépannage)
- [Ressources](#ressources)

## 🎯 Vue d'ensemble

Ce TP déploie un stack de monitoring complet basé sur Prometheus pour :
- **Collecter** des métriques système (CPU, RAM, disque, réseau)
- **Surveiller** les conteneurs Docker en temps réel
- **Alerter** sur les anomalies et seuils dépassés
- **Visualiser** les métriques via l'interface Prometheus

### Composants

| Service | Port | Description |
|---------|------|-------------|
| **Prometheus** | 9090 | Serveur de monitoring et TSDB |
| **Node Exporter** | 9100 | Métriques système (CPU, RAM, disque) |
| **cAdvisor** | 8080 | Métriques des conteneurs Docker |
| **Alertmanager** | 9093 | Gestion et routage des alertes |

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Docker Host                              │
│                                                              │
│  ┌──────────────┐      ┌─────────────┐     ┌─────────────┐ │
│  │ Prometheus   │◄─────┤Node Exporter│     │  cAdvisor   │ │
│  │   :9090      │      │   :9100     │     │   :8080     │ │
│  └──────┬───────┘      └─────────────┘     └──────▲──────┘ │
│         │                                           │        │
│         │              System Metrics           Container   │
│         │                   ▲                    Metrics    │
│         │                   │                       │       │
│         ▼                   │                       │       │
│  ┌──────────────┐           │                       │       │
│  │ Alertmanager │           │                       │       │
│  │   :9093      │           └───────────────────────┘       │
│  └──────────────┘                                           │
│         │                                                    │
│         ▼                                                    │
│    Email/Slack                                              │
└─────────────────────────────────────────────────────────────┘
```

## ✅ Prérequis

- Docker Engine 19.03.0+
- Docker Compose 1.27.0+
- 2+ CPU cores
- 4GB+ RAM
- 20GB+ espace disque libre
- Ports disponibles : 9090, 9100, 8080, 9093

## 🚀 Installation

### 1. Cloner le projet

```bash
cd 13-prometheus-docker
```

### 2. Configurer l'environnement

```bash
cp .env.example .env
nano .env
```

Configurez vos paramètres SMTP pour les alertes :

```env
ALERT_SMTP_HOST=smtp.gmail.com:587
ALERT_SMTP_FROM=alerts@votredomaine.com
ALERT_SMTP_TO=votre-email@example.com
ALERT_SMTP_USERNAME=votre-username
ALERT_SMTP_PASSWORD=votre-app-password
```

### 3. Personnaliser Alertmanager (optionnel)

Éditez `alertmanager/config.yml` pour configurer vos notifications :

```bash
nano alertmanager/config.yml
```

### 4. Démarrer le stack

```bash
docker compose up -d
```

### 5. Vérifier le déploiement

```bash
docker compose ps
docker compose logs -f
```

## ⚙️ Configuration

### Prometheus Configuration

Le fichier `prometheus/prometheus.yml` définit :
- **Scrape interval** : 15s (intervalle de collecte)
- **Evaluation interval** : 15s (évaluation des règles)
- **Targets** : Node Exporter, cAdvisor, Prometheus, Alertmanager

### Alert Rules

Trois types de règles sont configurées :

#### 1. Node Alerts (`prometheus/rules/node_alerts.yml`)

- ✅ `HighCPULoad` : CPU > 80% pendant 5 min
- 🚨 `CriticalCPULoad` : CPU > 95% pendant 2 min
- ✅ `HighMemoryUsage` : RAM > 80% pendant 5 min
- 🚨 `CriticalMemoryUsage` : RAM > 95% pendant 2 min
- ✅ `HighDiskUsage` : Disque > 85% pendant 5 min
- 🚨 `CriticalDiskUsage` : Disque > 95% pendant 2 min
- ⚠️ `UnusualMemoryGrowth` : Croissance anormale de RAM
- ⚠️ `HighLoadAverage` : Load average > 1.5x CPU count
- 🚨 `InstanceDown` : Node Exporter inaccessible

#### 2. Container Alerts (`prometheus/rules/container_alerts.yml`)

- ⚠️ `ContainerRestarting` : Redémarrages fréquents
- ⚠️ `ContainerHighMemoryUsage` : RAM conteneur > 80%
- 🚨 `ContainerMemoryOOMRisk` : RAM conteneur > 95% (risque OOM)
- ⚠️ `ContainerCPUThrottling` : Throttling CPU > 25%
- ⚠️ `ContainerHighCPUUsage` : CPU conteneur > 80%
- 🚨 `ContainerAbsent` : Conteneur critique manquant
- ℹ️ `ContainerHighDiskIO` : I/O disque élevé
- ℹ️ `ContainerHighNetworkReceive` : Réception réseau élevée
- ℹ️ `ContainerHighNetworkTransmit` : Transmission réseau élevée

#### 3. Recording Rules (`prometheus/rules/recording_rules.yml`)

Métriques pré-calculées pour améliorer les performances :

- `node:cpu_usage:avg5m` : Usage CPU moyen sur 5min
- `node:memory_usage:percent` : Pourcentage RAM utilisée
- `node:disk_usage:percent` : Pourcentage disque utilisé
- `container:cpu_usage:avg5m` : Usage CPU conteneur
- `container:memory_usage:percent` : Pourcentage RAM conteneur
- `container:count:total` : Nombre total de conteneurs
- `container:count:running` : Nombre de conteneurs actifs

### Alertmanager Routing

Les alertes sont routées selon leur sévérité :

| Sévérité | Destination | Intervalle répétition |
|----------|-------------|----------------------|
| 🚨 **Critical** | oncall@example.com | 1 heure |
| ⚠️ **Warning** | team@example.com | 4 heures |
| ℹ️ **Info** | monitoring@example.com | 24 heures |

## 📊 Utilisation

### Accéder aux interfaces

- **Prometheus** : http://localhost:9090
- **cAdvisor** : http://localhost:8080
- **Alertmanager** : http://localhost:9093
- **Node Exporter** (metrics) : http://localhost:9100/metrics

### Vérifier les targets

1. Ouvrir Prometheus : http://localhost:9090
2. Aller dans **Status > Targets**
3. Vérifier que tous les targets sont **UP**

### Vérifier les règles

1. Dans Prometheus : **Status > Rules**
2. Vérifier les règles d'alerte et recording rules

### Voir les alertes actives

1. Dans Prometheus : **Alerts**
2. Dans Alertmanager : http://localhost:9093

## 🔍 Queries PromQL Utiles

### Métriques Système

```promql
# CPU usage (using recording rule)
node:cpu_usage:avg5m

# Memory usage percentage (using recording rule)
node:memory_usage:percent

# Disk usage percentage
node:disk_usage:percent

# Load average normalized
node:load_normalized:load5

# Network receive rate
rate(node_network_receive_bytes_total[5m])

# Network transmit rate
rate(node_network_transmit_bytes_total[5m])

# Disk I/O read rate
rate(node_disk_read_bytes_total[5m])

# Disk I/O write rate
rate(node_disk_written_bytes_total[5m])
```

### Métriques Conteneurs

```promql
# Container CPU usage (using recording rule)
container:cpu_usage:avg5m

# Container memory usage percentage
container:memory_usage:percent

# Top 5 containers by CPU
topk(5, rate(container_cpu_usage_seconds_total{name!=""}[5m]) * 100)

# Top 5 containers by memory
topk(5, container_memory_usage_bytes{name!=""})

# Container restart count
changes(container_last_seen{name!=""}[1h])

# Container network receive rate
container:network_receive:rate5m

# Container network transmit rate
container:network_transmit:rate5m

# Containers at risk of OOM
container_memory_usage_bytes{name!=""} / container_spec_memory_limit_bytes{name!=""} > 0.9
```

### Métriques Agrégées

```promql
# Total containers running
container:count:running

# Total CPU usage across all containers
sum(rate(container_cpu_usage_seconds_total{name!=""}[5m]))

# Total memory used by containers
sum(container_memory_usage_bytes{name!=""})

# Total network traffic (receive)
sum(rate(container_network_receive_bytes_total[5m]))

# Total network traffic (transmit)
sum(rate(container_network_transmit_bytes_total[5m]))
```

## 🚨 Alertes

### Tester les alertes

#### 1. Simuler une charge CPU élevée

```bash
# Installer stress (si nécessaire)
sudo apt-get install stress

# Générer une charge CPU pendant 5 minutes
stress --cpu 8 --timeout 300s
```

Alerte attendue : `HighCPULoad` après 5 minutes

#### 2. Simuler une charge mémoire élevée

```bash
# Générer une charge mémoire de 1GB
stress --vm 1 --vm-bytes 1G --timeout 300s
```

Alerte attendue : `HighMemoryUsage`

#### 3. Simuler un redémarrage de conteneur

```bash
# Redémarrer un conteneur plusieurs fois
docker restart node-exporter
sleep 30
docker restart node-exporter
```

Alerte attendue : `ContainerRestarting`

### Silence des alertes

Dans Alertmanager (http://localhost:9093) :
1. Cliquer sur **Silence**
2. Créer un nouveau silence avec des matchers (ex: `alertname="HighCPULoad"`)
3. Définir la durée du silence

## 🔧 Dépannage

### Aucune donnée dans Prometheus

```bash
# Vérifier les logs
docker compose logs prometheus

# Vérifier la configuration
docker compose exec prometheus promtool check config /etc/prometheus/prometheus.yml

# Recharger la configuration
curl -X POST http://localhost:9090/-/reload
```

### Les alertes ne se déclenchent pas

```bash
# Vérifier les règles d'alerte
docker compose exec prometheus promtool check rules /etc/prometheus/rules/*.yml

# Vérifier Alertmanager
docker compose logs alertmanager

# Tester une alerte manuellement
curl -H 'Content-Type: application/json' -d '[{"labels":{"alertname":"test"}}]' http://localhost:9093/api/v1/alerts
```

### Conteneur ne s'affiche pas dans les métriques

```bash
# Vérifier que cAdvisor peut accéder au socket Docker
docker compose exec cadvisor ls -la /var/run/docker.sock

# Redémarrer cAdvisor
docker compose restart cadvisor
```

### Problèmes de performance

```bash
# Vérifier l'utilisation des ressources
docker stats

# Augmenter la rétention des données (dans docker-compose.yml)
# Modifier : --storage.tsdb.retention.time=15d

# Utiliser les recording rules pour les queries fréquentes
# (Déjà configurées dans prometheus/rules/recording_rules.yml)
```

## 📚 Ressources

### Documentation Officielle

- [Prometheus Documentation](https://prometheus.io/docs/)
- [PromQL Basics](https://prometheus.io/docs/prometheus/latest/querying/basics/)
- [Alerting Rules](https://prometheus.io/docs/prometheus/latest/configuration/alerting_rules/)
- [Node Exporter](https://github.com/prometheus/node_exporter)
- [cAdvisor](https://github.com/google/cadvisor)
- [Alertmanager](https://prometheus.io/docs/alerting/latest/alertmanager/)

### Queries PromQL

- [PromQL Cheat Sheet](https://promlabs.com/promql-cheat-sheet/)
- [Query Examples](https://prometheus.io/docs/prometheus/latest/querying/examples/)

### Best Practices

- [Prometheus Best Practices](https://prometheus.io/docs/practices/)
- [Monitoring Best Practices](https://prometheus.io/docs/practices/naming/)
- [Alert Rule Best Practices](https://prometheus.io/docs/practices/alerting/)

### Tutoriels et Articles

- [Article de référence Last9](https://last9.io/blog/prometheus-with-docker-compose/)
- [Getting Started with Prometheus](https://prometheus.io/docs/prometheus/latest/getting_started/)
- [Monitoring Docker Containers](https://prometheus.io/docs/guides/cadvisor/)

## 🎓 Objectifs Pédagogiques

Après avoir complété ce TP, vous serez capable de :

✅ Déployer un stack Prometheus complet avec Docker Compose  
✅ Configurer les scrape configs et targets  
✅ Créer et gérer des règles d'alerte  
✅ Utiliser PromQL pour interroger les métriques  
✅ Configurer Alertmanager pour router les notifications  
✅ Monitorer les systèmes et conteneurs Docker  
✅ Optimiser les performances avec recording rules  
✅ Débugger les problèmes de monitoring  

## 🚀 Prochaines Étapes

Après avoir maîtrisé ce TP, vous pouvez :

1. **TP14 - Prometheus+Grafana Pro** : Stack production avec Grafana, Traefik, Loki
2. Ajouter d'autres exporters (MySQL, PostgreSQL, Redis, etc.)
3. Intégrer avec des outils externes (PagerDuty, OpsGenie)
4. Créer des dashboards Grafana personnalisés
5. Implémenter le High Availability (HA) avec Thanos

## 📝 Licence

Ce projet fait partie du repository CJ-DEVOPS - Portfolio DevOps.

---

**Auteur** : CJenkins-AFPA  
**Dernière mise à jour** : Décembre 2024  
**Version Prometheus** : 2.50.1
