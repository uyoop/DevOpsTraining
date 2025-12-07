# 🌐 TP11 - NetBox Docker (Basique)

Installation rapide de NetBox pour la gestion d'infrastructure réseau avec Docker.

## 📋 Prérequis

- Docker & Docker Compose
- 2 GB RAM minimum
- 5 GB disque disponible
- Linux/macOS ou Windows avec WSL2

## 🚀 Démarrage Rapide

### 1. Configuration

```bash
cp .env.example .env
nano .env
```

Variables essentielles :
```bash
DB_PASSWORD=votre_mot_de_passe_bd
SECRET_KEY=votre_clé_secrète  # Générer avec: python -c "import secrets; print(secrets.token_urlsafe(50))"
ALLOWED_HOSTS=votre-domaine.com
NETBOX_PORT=8000
```

### 2. Démarrage

```bash
docker compose up -d
docker compose logs -f netbox
```

Attendre que NetBox soit prêt (~30 secondes)

### 3. Accès

- URL: `http://localhost:8000`
- Username: `admin` (par défaut)
- Password: `admin` (par défaut)

⚠️ **CHANGEZ LE MOT DE PASSE IMMÉDIATEMENT !**

## 🔧 Services

| Service | Port | Rôle |
|---------|------|------|
| NetBox | 8000 | Application principale |
| PostgreSQL | 5432 | Base de données |
| Redis | 6379 | Cache |
| Worker | - | Tâches asynchrones |
| Housekeeping | - | Maintenance |

## 📊 Interface Principal

### Accueil
- Dashboard avec statistiques
- Raccourcis vers sections principales
- Status des services

### Sections Principales

#### 1. **Déclaration** (Declare)
- Sites
- Régions
- Zones
- Racks
- Appareils

#### 2. **Organisation**
- Organisations
- Équipes
- Contacts
- Adresses

#### 3. **Circuits**
- Types de circuits
- Fournisseurs
- Circuits
- Interfaces de circuit

#### 4. **Câbles & Connexions**
- Câbles
- Connexions
- Chemins
- Tracé de câbles

#### 5. **Électricité**
- Alimentations
- Prises PDU
- Circuits d'alimentation

#### 6. **Réseau**
- Interfaces
- IP/IPAM
- Adresses IP
- Réseaux
- VLAN
- Routes

#### 7. **Contrats**
- Types de contrats
- Contrats
- Services

## 📱 API REST

NetBox expose une API REST complète sur `/api/`

### Obtenir un token d'API

1. Connexion admin
2. Profil utilisateur (coin haut droit)
3. API Tokens
4. Add Token

### Exemples d'utilisation

```bash
# Obtenir tous les appareils
curl -H "Authorization: Token VOTRE_TOKEN" \
  http://localhost:8000/api/dcim/devices/

# Créer un site
curl -X POST http://localhost:8000/api/dcim/sites/ \
  -H "Authorization: Token VOTRE_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Data Center 1",
    "slug": "dc1"
  }'
```

## 🔄 Importer des Types d'Appareils

### Étape 1 : Cloner la bibliothèque

```bash
cd ..
git clone https://github.com/netbox-community/devicetype-library.git
cd devicetype-library
```

### Étape 2 : Script d'importation

```bash
git clone https://github.com/netbox-community/Device-Type-Library-Import.git
cd Device-Type-Library-Import

python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

cp .env.example .env
# Éditer .env avec:
# NETBOX_URL=http://localhost:8000
# NETBOX_API_TOKEN=votre_token_api
```

### Étape 3 : Importer

```bash
./nb-dt-import.py --library-path ../devicetype-library
```

Cela importera tous les types d'appareils disponibles (Cisco, HP, Dell, etc.)

## 🗄️ Volumes de Données

```
postgres_data    → Base de données PostgreSQL
redis_data       → Données de cache
netbox_media     → Fichiers (images, uploads)
```

## 📝 Logs

```bash
# Tous les logs
docker compose logs -f

# Logs spécifiques
docker compose logs -f netbox
docker compose logs -f netbox-worker
```

## 🔧 Commandes Utiles

```bash
# Créer un superuser supplémentaire
docker compose exec netbox python /opt/netbox/netbox/manage.py createsuperuser

# Migrations BD
docker compose exec netbox python /opt/netbox/netbox/manage.py migrate

# Collecter les fichiers statiques
docker compose exec netbox python /opt/netbox/netbox/manage.py collectstatic

# Vider le cache
docker compose exec netbox python /opt/netbox/netbox/manage.py shell
# >>> from django.core.cache import cache
# >>> cache.clear()
```

## 🆘 Troubleshooting

### NetBox ne démarre pas
```bash
# Vérifier les logs
docker compose logs netbox

# Réinitialiser
docker compose down -v
docker compose up -d
```

### Base de données en erreur
```bash
# Recréer les migrations
docker compose down -v
docker compose up -d
```

### Port déjà utilisé
```bash
# Changer dans .env
NETBOX_PORT=8001
docker compose down
docker compose up -d
```

## 📚 Ressources

- [Documentation NetBox](https://docs.netbox.dev/)
- [API Documentation](https://docs.netbox.dev/en/stable/api/overview/)
- [Device Type Library](https://github.com/netbox-community/devicetype-library)
- [Community Plugins](https://netbox.dev/plugins/)

## 🎯 Prochaine Étape

Voir **TP12 - NetBox Professionnel** pour une configuration production avec :
- Reverse proxy Traefik
- 2FA authentication
- Backup/restore
- Monitoring
- Intégration Nautobot
- API avancée

---

**Niveau** : Débutant
**Durée** : 1-2h
**Portfolio** : ⭐⭐⭐
