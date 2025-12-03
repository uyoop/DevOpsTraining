# UyoopApp

Application minimale (PHP + JS + CSS) pour le recueil de besoins et la génération automatique d'un cahier des charges.

## 🚀 Démarrage rapide avec Docker

```bash
# Installation en une commande
make install

# Ou manuellement
./deploy.sh
```

Application accessible sur : **http://localhost:8080**

## 📋 Table des matières

- [Structure](#structure)
- [Déploiement Docker](#déploiement-docker)
- [Déploiement traditionnel](#déploiement-traditionnel)
- [Commandes utiles](#commandes-utiles)
- [Déploiement avec Ansible](#déploiement-avec-ansible)
- [Tests](#tests)
- [Fonctionnalités](#fonctionnalités)

## Structure

```
UyoopAppDocker/
├── 📱 APPLICATION
│   ├── public/          # Racine web publique
│   │   ├── index.php    # Page principale + routeur
│   │   ├── admin.php    # Administration
│   │   └── assets/      # CSS, JS, images
│   └── src/             # Backend PHP
│       ├── db.php       # Connexion SQLite
│       ├── api_save.php # API sauvegarde
│       └── generate.php # Génération cahier charges
│
├── 🐳 DOCKER
│   ├── Dockerfile                # Image PHP avec SQLite
│   ├── docker-compose.yml        # Configuration développement
│   ├── docker-compose.prod.yml   # Configuration production
│   ├── nginx.conf                # Configuration Nginx
│   └── healthcheck.sh           # Script de santé
│
├── 🚀 SCRIPTS
│   ├── deploy.sh                # Déploiement automatique
│   ├── test.sh                  # Suite de tests
│   ├── install-docker.sh        # Installation Docker
│   └── show-structure.sh        # Affichage structure
│
├── 📚 DOCUMENTATION
│   ├── QUICKSTART.md            # Démarrage rapide
│   ├── DOCKER.md                # Guide Docker complet
│   ├── ARCHITECTURE.md          # Architecture technique
│   ├── COMMANDS.md              # Référence commandes
│   ├── PREREQUISITES.md         # Installation pré-requis
│   ├── SUMMARY.md               # Résumé complet
│   └── CHANGELOG.md             # Historique versions
│
├── 🤖 ANSIBLE
│   ├── deploy.yml               # Playbook déploiement
│   ├── inventory.ini            # Inventaire serveurs
│   ├── ansible.cfg              # Configuration
│   └── README.md                # Guide Ansible
│
├── 💾 DATA
│   └── data/                    # Base de données SQLite
│
└── 🔧 CONFIGURATION
    ├── Makefile                 # Commandes simplifiées
    ├── .env.example             # Variables d'environnement
    ├── .dockerignore            # Exclusions Docker
    ├── .gitignore               # Exclusions Git
    └── README.md                # Ce fichier
```

## Pré-requis
- PHP 8.4+
- Extension PHP : `php-sqlite3`

### Installation de l'extension SQLite
```bash
sudo apt install -y php8.4-sqlite3
```

## Lancer en local

```bash
cd public
php -S localhost:8080
```

Ouvrir :
- **Formulaire** : `http://localhost:8080`
- **Administration** : `http://localhost:8080/admin.php`

## Déploiement

### Déploiement avec Docker (recommandé)

L'application est entièrement conteneurisée avec Docker et Docker Compose pour un déploiement simple et reproductible.

#### Pré-requis Docker
- Docker 20.10+
- Docker Compose V2

#### Installation complète
```bash
# Méthode 1 : Avec Make (recommandé)
make install

# Méthode 2 : Script automatique
./scripts/deploy.sh

# Méthode 3 : Commandes manuelles
docker compose -f docker/docker-compose.yml up -d --build
```

L'application sera accessible sur `http://localhost:8080`

#### Commandes Docker utiles
```bash
# Démarrer
make up              # ou: docker compose -f docker/docker-compose.yml up -d

# Arrêter
make down            # ou: docker compose -f docker/docker-compose.yml down

# Voir les logs
make logs            # ou: docker compose -f docker/docker-compose.yml logs -f

# Redémarrer
make restart         # ou: docker compose -f docker/docker-compose.yml restart

# Rebuild complet
make redeploy        # ou: docker compose -f docker/docker-compose.yml up -d --build

# Statut
make status          # ou: docker compose -f docker/docker-compose.yml ps

# Backup base de données
make backup

# Tests
make test            # ou: ./scripts/test.sh
```

Pour plus de commandes, tapez `make` ou `make help`

#### Architecture Docker
- **nginx** : Serveur web (Alpine Linux)
- **php** : PHP 8.4-FPM avec extension SQLite
- **volumes** : Persistance des données dans `./data/`
- **network** : Réseau isolé pour la communication inter-conteneurs

#### Configuration
- Port HTTP : `8080` (modifiable dans `.env` ou `docker-compose.yml`)
- Base de données : SQLite dans `./data/uyoop.db`
- PHP Memory Limit : 256M (dev) / 512M (prod)
- Upload Max Size : 10M (dev) / 20M (prod)

#### Fichiers Docker
- `docker/Dockerfile` - Image PHP avec extensions
- `docker/docker-compose.yml` - Configuration développement
- `docker/docker-compose.prod.yml` - Configuration production
- `docker/nginx.conf` - Configuration Nginx
- `.env.example` - Variables d'environnement
- `docs/DOCKER.md` - Documentation détaillée Docker

## Déploiement avec Ansible

Pour un déploiement automatisé sur serveur distant :

```bash
# Éditer l'inventaire
nano ansible/inventory.ini

# Tester la connexion
ansible all -m ping

# Déployer
ansible-playbook deploy.yml
```

Voir `ansible/README.md` pour plus de détails.

## Commandes utiles

### Avec Make
```bash
make help          # Afficher toutes les commandes
make install       # Installation première fois
make deploy        # Déployer l'application
make logs          # Voir les logs
make status        # Statut des conteneurs
make backup        # Backup de la base de données
make test          # Lancer les tests
make clean         # Nettoyer
```

### Docker manuellement
```bash
docker compose -f docker/docker-compose.yml up -d               # Démarrer
docker compose -f docker/docker-compose.yml down                # Arrêter
docker compose -f docker/docker-compose.yml logs -f             # Logs en temps réel
docker compose -f docker/docker-compose.yml ps                  # Statut
docker compose -f docker/docker-compose.yml exec php sh         # Shell PHP
docker compose -f docker/docker-compose.yml restart             # Redémarrer
```

### Tests
```bash
./scripts/test.sh                          # Tests automatiques
curl http://localhost:8080         # Test manuel
```

### Déploiement traditionnel (sans Docker)
- Nginx/Apache: pointer le root sur `public/`.
- PHP-FPM recommandé.
- S'assurer que le dossier `data/` est accessible en écriture par le serveur web.

## Fonctionnalités
- Formulaire intelligent : sections conditionnelles selon le type de projet
- Génération automatique d'un cahier des charges en HTML
- Enregistrement des données en base SQLite
- Page d'administration pour consulter tous les formulaires complétés
- Styles modernes, responsive, branding Uyoop

## Notes
- Le formulaire affiche des champs selon `Type de projet`.
- Le bouton "Prévisualiser" rend le cahier des charges en HTML.
- Le bouton "Enregistrer & Générer" tente d'insérer en base et fournit un lien de téléchargement `/generate?id=...`.
