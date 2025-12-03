# Environnement Vagrant/Ansible pour Docker

Environnement de développement Docker simple avec Vagrant et Ansible pour une application PHP/MySQL.

## Prérequis

- VirtualBox
- Vagrant
- Ansible

## Structure du projet

```
.
├── Vagrantfile              # Configuration VM
├── playbook.yml             # Provisioning Ansible
├── ansible.cfg              # Config Ansible
├── docker-compose.yml       # Orchestration des conteneurs
└── sources/
    ├── Dockerfile           # Image PHP Apache personnalisée
    ├── articles.sql         # Script d'initialisation MySQL
    └── app/
        ├── index.php        # Application PHP
        ├── db-config.php    # Configuration base de données
        └── validation.php   # Traitement formulaire
```

## Installation

```bash
# 1. Lancer la VM et le provisioning
vagrant up

# 2. Se connecter à la VM
vagrant ssh

# 3. Aller dans le dossier partagé
cd /vagrant

# 4. Lancer les conteneurs
docker compose up -d

# 5. Accéder à l'application
# Depuis votre navigateur : http://localhost:8080
```


## Architecture Docker Compose

### Services déployés

1. **web** (PHP Apache)
   - Image : Construite depuis `sources/Dockerfile`
   - Base : `php:7-apache`
   - Extensions : PDO, PDO_MySQL
   - Port : `8080:80`
   - Volume : `./sources/app` → `/var/www/html`

2. **db** (MySQL)
   - Image : `mysql:5.7`
   - Base de données : `test`
   - Utilisateur : `test` / `test`
   - Initialisation : `articles.sql` auto-importé
   - Volume persistant : `mysql-data`

### Réseau
- Network bridge `app-network` pour la communication inter-conteneurs
- Le service web accède à MySQL via le hostname `mysql_c`

## Commandes utiles

### Vagrant
```bash
# Redémarrer la VM
vagrant reload

# Reprovisioner (réexécuter Ansible)
vagrant provision

# Arrêter la VM
vagrant halt

# Détruire la VM
vagrant destroy

# SSH dans la VM
vagrant ssh
```

### Docker Compose (depuis la VM)
```bash
# Lancer les conteneurs
docker compose up -d

# Voir les logs
docker compose logs -f

# Arrêter les conteneurs
docker compose down

# Reconstruire les images
docker compose build

# Redémarrer un service
docker compose restart web

# Voir l'état des conteneurs
docker compose ps
```

## Workflow de développement

1. **Modifier le code** : Éditez les fichiers dans `sources/app/`
2. **Voir les changements** : Rafraîchissez le navigateur (volume monté en temps réel)
3. **Reconstruire l'image** : Si vous modifiez le Dockerfile → `docker compose build`
4. **Redémarrer** : `docker compose restart web`

## Contenu installé dans la VM

- Docker Engine (dernière version)
- Docker Compose Plugin
- Docker Compose standalone
- Python docker modules

L'utilisateur `vagrant` est ajouté au groupe docker, donc pas besoin de `sudo` pour les commandes docker.

## Dossier partagé

Le dossier actuel est monté dans `/vagrant` sur la VM.
