# TP 2 : Commandes Docker de Base

## 🎯 Objectifs

- Maîtriser les commandes Docker essentielles
- Comprendre le cycle de vie d'un conteneur
- Gérer les images et conteneurs
- Manipuler les logs et l'inspection

## 📋 Prérequis

- Docker installé (voir TP 01-docker-install)
- Accès terminal

## 🐳 Gestion des Images

### Rechercher une image

```bash
docker search nginx
docker search ubuntu
```

### Télécharger une image

```bash
docker pull nginx:latest
docker pull ubuntu:22.04
docker pull alpine:3.18
```

### Lister les images

```bash
docker images
docker images -a
docker images --filter "dangling=true"
```

### Supprimer des images

```bash
docker rmi nginx:latest
docker rmi $(docker images -q)  # Supprimer toutes les images
docker image prune  # Supprimer les images non utilisées
```

## 📦 Gestion des Conteneurs

### Créer et démarrer un conteneur

```bash
# Mode détaché (background)
docker run -d --name webserver nginx:latest

# Mode interactif
docker run -it ubuntu:22.04 /bin/bash

# Avec port mapping
docker run -d -p 8080:80 --name web nginx:latest

# Avec variables d'environnement
docker run -d -e MYSQL_ROOT_PASSWORD=secret mysql:8.0

# Avec volume
docker run -d -v /host/path:/container/path nginx:latest
```

### Lister les conteneurs

```bash
docker ps               # Conteneurs en cours d'exécution
docker ps -a            # Tous les conteneurs
docker ps -q            # Seulement les IDs
docker ps --filter "status=exited"
```

### Contrôler les conteneurs

```bash
# Démarrer/Arrêter
docker start webserver
docker stop webserver
docker restart webserver

# Pause/Unpause
docker pause webserver
docker unpause webserver

# Tuer un conteneur
docker kill webserver
```

### Supprimer des conteneurs

```bash
docker rm webserver
docker rm -f webserver  # Force la suppression
docker container prune  # Supprimer les conteneurs arrêtés
```

## 🔍 Inspection et Logs

### Logs

```bash
docker logs webserver
docker logs -f webserver  # Suivre les logs en temps réel
docker logs --tail 100 webserver
docker logs --since 1h webserver
```

### Inspection

```bash
docker inspect webserver
docker inspect nginx:latest
docker stats  # Statistiques en temps réel
docker top webserver  # Processus du conteneur
```

### Exécuter des commandes dans un conteneur

```bash
docker exec webserver ls -la
docker exec -it webserver /bin/bash
docker exec -u root webserver apt update
```

## 📊 Exercices Pratiques

### Exercice 1 : Serveur Web Nginx

```bash
# 1. Lancer Nginx
docker run -d -p 8080:80 --name mynginx nginx:alpine

# 2. Vérifier qu'il tourne
curl http://localhost:8080

# 3. Voir les logs
docker logs mynginx

# 4. Accéder au shell
docker exec -it mynginx /bin/sh

# 5. Arrêter et supprimer
docker stop mynginx
docker rm mynginx
```

### Exercice 2 : Base de données PostgreSQL

```bash
# 1. Lancer PostgreSQL
docker run -d \
  --name postgres \
  -e POSTGRES_PASSWORD=mysecret \
  -p 5432:5432 \
  postgres:15

# 2. Se connecter
docker exec -it postgres psql -U postgres

# 3. Créer une base
CREATE DATABASE testdb;
\l
\q

# 4. Cleanup
docker stop postgres
docker rm postgres
```

### Exercice 3 : Container interactif Python

```bash
# 1. Lancer Python interactif
docker run -it --rm python:3.11 python

# 2. Tester du code
>>> print("Hello Docker!")
>>> import sys
>>> sys.version
>>> exit()
```

## 🎓 Commandes Avancées

### Copier des fichiers

```bash
# Hôte → Conteneur
docker cp /local/file.txt mynginx:/usr/share/nginx/html/

# Conteneur → Hôte
docker cp mynginx:/etc/nginx/nginx.conf ./nginx.conf
```

### Créer une image depuis un conteneur

```bash
docker commit mynginx mynginx-custom:v1
```

### Exporter/Importer

```bash
# Exporter un conteneur
docker export mynginx > mynginx.tar

# Sauvegarder une image
docker save nginx:alpine > nginx-alpine.tar

# Charger une image
docker load < nginx-alpine.tar
```

## 📚 Mémo des Commandes

| Commande | Description |
|----------|-------------|
| `docker run` | Créer et démarrer un conteneur |
| `docker ps` | Lister les conteneurs |
| `docker images` | Lister les images |
| `docker pull` | Télécharger une image |
| `docker exec` | Exécuter une commande dans un conteneur |
| `docker logs` | Voir les logs |
| `docker inspect` | Inspecter un objet Docker |
| `docker stop` | Arrêter un conteneur |
| `docker rm` | Supprimer un conteneur |
| `docker rmi` | Supprimer une image |

## 🔗 Ressources

- [Docker CLI Reference](https://docs.docker.com/engine/reference/commandline/cli/)
- [Docker Run Reference](https://docs.docker.com/engine/reference/run/)
