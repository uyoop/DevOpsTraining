# 🌐 TP12 - NetBox Professionnel (Production-Ready)

Déploiement complet et sécurisé de NetBox avec toutes les couches d'infrastructure.

## 📊 Architecture

```
Internet
    ↓
[Traefik - Reverse Proxy + SSL]
    ↓
[NetBox Application (8 replicas possibles)]
    ├─ PostgreSQL (DB)
    ├─ Redis (Cache)
    ├─ Worker (Async tasks)
    ├─ Housekeeping (Maintenance)
    └─ API REST/GraphQL
    ↓
[Monitoring Stack]
├─ Prometheus (Metrics)
└─ Grafana (Dashboards)
```

## 🚀 Déploiement

### 1. Configuration Initiale

```bash
cp .env.example .env

# Générer les secrets
python3 -c "import secrets; print(secrets.token_urlsafe(50))" > secret.key

# Éditer .env
nano .env
```

Variables critiques :
```bash
DOMAIN=netbox.example.com
LETSENCRYPT_EMAIL=admin@example.com
DB_PASSWORD=<secure_password>
REDIS_PASSWORD=<secure_password>
SECRET_KEY=<from_secret.key>
```

### 2. Lancer la Stack

```bash
docker compose pull
docker compose up -d

# Attendre ~60 secondes
docker compose logs -f netbox

# Vérifier le statut
docker compose ps
```

### 3. Initialiser les Données

```bash
# Créer un superuser
docker compose exec netbox python /opt/netbox/netbox/manage.py createsuperuser

# Migrations
docker compose exec netbox python /opt/netbox/netbox/manage.py migrate

# Collecter les fichiers statiques
docker compose exec netbox python /opt/netbox/netbox/manage.py collectstatic --no-input
```

## 🔐 Sécurité

### Features Activées
- ✅ HTTPS/TLS avec Let's Encrypt
- ✅ Security headers (HSTS, CSP, etc.)
- ✅ Rate limiting (100 req/min)
- ✅ Sessions sécurisées (1h expiration)
- ✅ CSRF protection
- ✅ Redis password protected
- ✅ PostgreSQL isolated
- ✅ API authentication required

### Bonnes Pratiques
- Changer les mots de passe par défaut
- Configurer les tokens d'API avec expiration
- Activer 2FA si disponible
- Audit logs activés automatiquement
- Backups réguliers (voir scripts/)

## 📊 Accès aux Services

| Service | URL | Auth |
|---------|-----|------|
| NetBox | https://netbox.DOMAIN | Admin password |
| API | https://netbox.DOMAIN/api/ | Token |
| GraphQL | https://netbox.DOMAIN/graphql/ | Token |
| Prometheus | https://prometheus.DOMAIN | - |
| Grafana | https://grafana.DOMAIN | Admin password |
| Traefik | https://DOMAIN | - |

## 📱 API & Automation

### Générer un Token API

1. Connexion: `https://netbox.DOMAIN`
2. Utilisateur → Profil
3. API Tokens → Add Token
4. Copier le token

### Exemples de Requêtes

```bash
API_TOKEN="your_token_here"
DOMAIN="netbox.example.com"

# Lister tous les sites
curl -H "Authorization: Token $API_TOKEN" \
  https://$DOMAIN/api/dcim/sites/

# Lister tous les appareils
curl -H "Authorization: Token $API_TOKEN" \
  https://$DOMAIN/api/dcim/devices/

# Créer un site
curl -X POST https://$DOMAIN/api/dcim/sites/ \
  -H "Authorization: Token $API_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "DC Paris",
    "slug": "dc-paris",
    "region": 1
  }'

# Requête GraphQL
curl -X POST https://$DOMAIN/graphql/ \
  -H "Authorization: Token $API_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "query": "{ sites { id name slug } }"
  }'
```

## 🔄 Importer des Données

### Utiliser le Import Script Officiel

```bash
# À côté du dossier 12-netbox-professionnel
git clone https://github.com/netbox-community/Device-Type-Library-Import.git
cd Device-Type-Library-Import

python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

cp .env.example .env
# Éditer .env:
# NETBOX_URL=https://netbox.example.com
# NETBOX_API_TOKEN=your_api_token
# LIBRARY_PATH=../devicetype-library

./nb-dt-import.py --limit Cisco,Dell,HP
```

### Import de YAML/JSON

```bash
# Préparateur JSON pour les appareils
cat > devices.json << 'EOF'
{
  "devices": [
    {
      "name": "switch-core-1",
      "device_type": 1,
      "site": 1,
      "status": "active",
      "serial": "ABC123456"
    }
  ]
}
EOF

# Script d'import
curl -X POST https://netbox.example.com/api/dcim/devices/ \
  -H "Authorization: Token $API_TOKEN" \
  -H "Content-Type: application/json" \
  -d @devices.json
```

## 📊 Monitoring

### Prometheus Queries

```promql
# CPU usage netbox container
docker_container_cpu_usage_percent{name="netbox-app"}

# Memory usage
docker_container_memory_usage_bytes{name="netbox-app"}

# PostgreSQL connections
pg_stat_activity_count{datname="netbox"}

# Redis used memory
redis_memory_used_bytes

# HTTP requests rate
rate(http_requests_total[5m])
```

### Grafana Dashboards

Pré-importées:
- Docker Containers (ID: 893)
- PostgreSQL (ID: 9628)
- Redis (ID: 11835)

Ajouter custom:
1. Data Sources → Prometheus
2. Dashboards → New Dashboard
3. Add Panel → Prometheus Query

## 🔧 Maintenance

### Backups

```bash
# Dump PostgreSQL
docker compose exec postgres pg_dump -U netbox netbox > backup.sql.bz2

# Sauvegarde volumes
docker run --rm -v netbox_media:/data \
  -v ./backups:/backup \
  ubuntu tar czf /backup/media_$(date +%Y%m%d).tar.gz -C /data .

# Script de backup automatisé
bash scripts/backup.sh
```

### Upgrades

```bash
# Avant upgrade
docker compose down
tar -czf backup_$(date +%Y%m%d).tar.gz .

# Mise à jour
docker compose pull
docker compose up -d
docker compose exec netbox python /opt/netbox/netbox/manage.py migrate

# Vérifier
docker compose logs -f netbox
```

## 🆘 Troubleshooting

### Problème de Certificat SSL

```bash
# Vérifier le fichier
ls -la letsencrypt/acme.json

# Réinitialiser
rm letsencrypt/acme.json
docker compose restart traefik
```

### Base de données en erreur

```bash
# Vérifier la connexion
docker compose logs postgres

# Réinitialiser
docker compose down -v
docker compose up -d
```

### Pas d'accès à l'API

```bash
# Vérifier le token
curl -H "Authorization: Token INVALID" \
  https://netbox.example.com/api/dcim/

# Régénérer le token via UI
```

## 📚 Ressources

- [NetBox Documentation](https://docs.netbox.dev/)
- [NetBox API Reference](https://docs.netbox.dev/en/stable/api/overview/)
- [Device Type Library](https://github.com/netbox-community/devicetype-library)
- [NetBox Community](https://github.com/netbox-community/)
- [Plugins Registry](https://netbox.dev/plugins/)

## 📈 Performance Tuning

### PostgreSQL
- `shared_buffers`: 25% de la RAM
- `effective_cache_size`: 50-75% de la RAM
- `work_mem`: Total RAM / (num_workers * 2)

### Redis
- `maxmemory`: 512MB par défaut
- `maxmemory-policy`: allkeys-lru

### NetBox
- Augmenter `WORKERS` dans gunicorn
- Configurer `RATE_LIMIT`
- Paginer les API responses

## 🎯 Cas d'Usage

### IPAM - Gestion IP
- Réservation d'adresses IP
- Gestion des réseaux VLAN
- Suivi des routes
- Documentation des underlay/overlay

### DCIM - Infrastructure DC
- Inventaire des salles
- Racks et équipements
- Câblage physique
- Power tracking

### Circuits
- Gestion des connexions
- Fournisseurs
- Interface de circuit
- SLA tracking

### Contacts & Organisatio ns
- Gestion des équipes
- Adresses
- Contacts techniques

## 🔄 Intégration Automation

### Ansible + NetBox

```yaml
- name: Get devices from NetBox
  netbox_netbox:
    url: "{{ netbox_url }}"
    token: "{{ netbox_token }}"
    query: "dcim/devices"
  register: devices

- name: Configure devices
  template:
    src: config.j2
    dest: "/etc/devices/{{ item.name }}.conf"
  loop: "{{ devices.json.results }}"
```

### Python Script

```python
import pynetbox

netbox = pynetbox.api(
  'https://netbox.example.com',
  token='your_api_token'
)

# Créer un site
sites = netbox.dcim.sites.create(
  name='Paris DC',
  slug='paris-dc'
)

# Lister les appareils
devices = netbox.dcim.devices.all()
for device in devices:
    print(f"{device.name}: {device.device_type}")
```

---

**Niveau** : Avancé
**Durée** : 3-4h
**Portfolio** : ⭐⭐⭐⭐⭐
