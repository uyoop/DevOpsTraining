# Commandes Docker utiles pour les TPs

## 🚀 Gestion de base

### Démarrer/Arrêter la VM
```bash
vagrant up                    # Démarrer la VM
vagrant halt                  # Arrêter la VM
vagrant reload                # Redémarrer la VM
vagrant ssh                   # Se connecter à la VM
vagrant destroy               # Détruire la VM
```

### État et informations
```bash
vagrant status                # État de la VM
vagrant ssh-config            # Config SSH
docker info                   # Info Docker (depuis la VM)
docker version                # Versions Docker
```

## 🐳 Commandes Docker essentielles

### Images
```bash
# Lister les images
docker images
docker image ls

# Télécharger une image
docker pull nginx
docker pull ubuntu:22.04
docker pull postgres:15

# Supprimer une image
docker rmi nginx
docker rmi <image_id>

# Supprimer les images non utilisées
docker image prune -a

# Construire une image
docker build -t mon-image:v1 .
docker build -t mon-image:v1 -f Dockerfile.custom .

# Inspecter une image
docker image inspect nginx
docker history nginx
```

### Conteneurs
```bash
# Lister les conteneurs
docker ps                     # Actifs uniquement
docker ps -a                  # Tous les conteneurs
docker ps -q                  # IDs uniquement

# Lancer un conteneur
docker run nginx
docker run -d nginx           # En arrière-plan (detached)
docker run -d -p 80:80 nginx  # Avec port forwarding
docker run -d --name web nginx  # Avec nom personnalisé
docker run -it ubuntu bash    # Interactif avec terminal

# Arrêter/Démarrer un conteneur
docker stop <container_id>
docker start <container_id>
docker restart <container_id>

# Supprimer un conteneur
docker rm <container_id>
docker rm -f <container_id>   # Force (même si actif)

# Supprimer tous les conteneurs arrêtés
docker container prune

# Voir les logs
docker logs <container_id>
docker logs -f <container_id>  # En continu (follow)
docker logs --tail 100 <container_id>

# Exécuter une commande dans un conteneur
docker exec <container_id> ls -la
docker exec -it <container_id> bash

# Inspecter un conteneur
docker inspect <container_id>
docker stats <container_id>   # Statistiques en temps réel
docker top <container_id>     # Processus
```

### Volumes
```bash
# Lister les volumes
docker volume ls

# Créer un volume
docker volume create mon-volume

# Inspecter un volume
docker volume inspect mon-volume

# Supprimer un volume
docker volume rm mon-volume

# Supprimer les volumes non utilisés
docker volume prune

# Utiliser un volume
docker run -d -v mon-volume:/data nginx
docker run -d -v /chemin/host:/chemin/container nginx
docker run -d -v /chemin/host:/chemin/container:ro nginx  # Read-only
```

### Réseaux
```bash
# Lister les réseaux
docker network ls

# Créer un réseau
docker network create mon-reseau
docker network create --driver bridge mon-reseau

# Inspecter un réseau
docker network inspect mon-reseau

# Connecter un conteneur à un réseau
docker network connect mon-reseau <container_id>
docker network disconnect mon-reseau <container_id>

# Supprimer un réseau
docker network rm mon-reseau

# Supprimer les réseaux non utilisés
docker network prune
```

## 🎼 Docker Compose

### Commandes de base
```bash
# Démarrer les services
docker compose up
docker compose up -d           # En arrière-plan
docker compose up --build      # Reconstruire les images

# Arrêter les services
docker compose down
docker compose down -v         # + supprimer les volumes
docker compose down --rmi all  # + supprimer les images

# Voir l'état
docker compose ps
docker compose ps -a

# Voir les logs
docker compose logs
docker compose logs -f         # En continu
docker compose logs web        # D'un service spécifique

# Redémarrer les services
docker compose restart
docker compose restart web     # Un service spécifique

# Exécuter une commande
docker compose exec web bash
docker compose exec postgres psql -U user

# Construire/Reconstruire
docker compose build
docker compose build --no-cache

# Voir la configuration
docker compose config
```

### Exemples de fichiers docker-compose.yml
```bash
# Utiliser le fichier d'exemple fourni
cp docker-compose.example.yml docker-compose.yml
docker compose up -d

# Ou créer votre propre configuration
nano docker-compose.yml
```

## 🧹 Nettoyage

```bash
# Tout nettoyer (⚠️ ATTENTION)
docker system prune -a --volumes

# Nettoyer par type
docker container prune        # Conteneurs arrêtés
docker image prune -a         # Images non utilisées
docker volume prune           # Volumes non utilisés
docker network prune          # Réseaux non utilisés

# Voir l'espace utilisé
docker system df
```

## 📦 Construire ses propres images

### Dockerfile simple
```dockerfile
FROM ubuntu:22.04
RUN apt-get update && apt-get install -y nginx
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

### Construire et tester
```bash
# Créer un Dockerfile
cat > Dockerfile << 'EOF'
FROM nginx:alpine
COPY ./html /usr/share/nginx/html
EOF

# Créer le contenu
mkdir html
echo "<h1>Mon TP Docker</h1>" > html/index.html

# Construire l'image
docker build -t mon-nginx .

# Lancer le conteneur
docker run -d -p 8080:80 mon-nginx

# Tester
curl localhost:8080
```

## 🔍 Debugging

```bash
# Voir les processus dans un conteneur
docker top <container_id>

# Statistiques en temps réel
docker stats

# Événements Docker
docker events

# Inspecter en détail
docker inspect <container_id>

# Copier des fichiers
docker cp <container_id>:/chemin/fichier ./fichier
docker cp ./fichier <container_id>:/chemin/fichier

# Voir les changements dans le filesystem
docker diff <container_id>
```

## 💡 Exemples pratiques pour TPs

### TP 1: Serveur web simple
```bash
docker run -d -p 8080:80 --name mon-web nginx:alpine
curl localhost:8080
docker logs mon-web
docker exec -it mon-web sh
docker stop mon-web
docker rm mon-web
```

### TP 2: Base de données avec persistance
```bash
docker volume create pg-data
docker run -d \
  --name postgres \
  -e POSTGRES_PASSWORD=secret \
  -v pg-data:/var/lib/postgresql/data \
  -p 5432:5432 \
  postgres:15-alpine

# Se connecter
docker exec -it postgres psql -U postgres
```

### TP 3: Application multi-conteneurs
```bash
# Créer le réseau
docker network create app-network

# Base de données
docker run -d \
  --name db \
  --network app-network \
  -e POSTGRES_PASSWORD=secret \
  postgres:15-alpine

# Application web
docker run -d \
  --name web \
  --network app-network \
  -p 80:80 \
  -e DATABASE_HOST=db \
  nginx:alpine
```

### TP 4: Stack complète avec Docker Compose
```bash
# Utiliser l'exemple fourni
cp docker-compose.example.yml docker-compose.yml

# Démarrer la stack
docker compose up -d

# Vérifier
docker compose ps

# Accéder à Adminer (interface web)
# http://localhost:8080

# Logs
docker compose logs -f

# Arrêter
docker compose down
```

## 🎓 Ressources

- [Docker Documentation](https://docs.docker.com/)
- [Docker Hub](https://hub.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Dockerfile Reference](https://docs.docker.com/engine/reference/builder/)

## 🆘 Dépannage rapide

```bash
# Docker ne répond pas
sudo systemctl restart docker

# Permissions denied
sudo usermod -aG docker $USER
# Puis se reconnecter

# Nettoyer tout et recommencer
docker system prune -a --volumes
```
