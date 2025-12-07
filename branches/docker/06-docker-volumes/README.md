# TP 6 : Volumes Docker

## 🎯 Objectifs

- Comprendre les types de stockage Docker
- Gérer les volumes Docker
- Utiliser les bind mounts
- Persister les données des conteneurs

## 📋 Prérequis

- Docker installé
- Connaissance des commandes Docker de base

## 💾 Types de Stockage Docker

### 1. Volumes (Recommandé)

Gérés par Docker, indépendants du système de fichiers hôte.

```bash
docker volume create my-volume
docker run -v my-volume:/data alpine
```

### 2. Bind Mounts

Montage direct d'un chemin hôte dans le conteneur.

```bash
docker run -v /host/path:/container/path alpine
docker run -v $(pwd):/app node:18
```

### 3. tmpfs (mémoire)

Stockage temporaire en RAM.

```bash
docker run --tmpfs /tmp alpine
```

## 🔧 Gestion des Volumes

### Créer un volume

```bash
docker volume create my-data
docker volume create --driver local \
  --opt type=none \
  --opt device=/mnt/storage \
  --opt o=bind \
  custom-volume
```

### Lister les volumes

```bash
docker volume ls
docker volume ls --filter "dangling=true"
```

### Inspecter un volume

```bash
docker volume inspect my-data
```

### Supprimer un volume

```bash
docker volume rm my-data
docker volume prune  # Supprimer les volumes non utilisés
```

## 📦 Utilisation des Volumes

### Avec docker run

```bash
# Volume nommé
docker run -d \
  --name postgres \
  -v pgdata:/var/lib/postgresql/data \
  postgres:15

# Volume anonyme
docker run -d \
  -v /var/lib/postgresql/data \
  postgres:15

# Bind mount
docker run -d \
  -v /home/user/data:/var/lib/postgresql/data \
  postgres:15

# Read-only
docker run -d \
  -v my-volume:/data:ro \
  alpine
```

### Avec Docker Compose

```yaml
version: '3.8'

services:
  db:
    image: postgres:15
    volumes:
      # Volume nommé
      - postgres_data:/var/lib/postgresql/data
      # Bind mount
      - ./init.sql:/docker-entrypoint-initdb.d/init.sql:ro
      # Volume anonyme
      - /var/log/postgresql

  app:
    image: node:18
    volumes:
      # Bind mount pour le développement
      - ./src:/app/src
      # Volume nommé pour node_modules
      - node_modules:/app/node_modules

volumes:
  postgres_data:
    driver: local
  node_modules:
```

## 🗄️ Exercice 1 : Base de données persistante

### PostgreSQL avec volume

```bash
# Créer le volume
docker volume create postgres_data

# Lancer PostgreSQL
docker run -d \
  --name postgres \
  -e POSTGRES_PASSWORD=secret \
  -v postgres_data:/var/lib/postgresql/data \
  -p 5432:5432 \
  postgres:15

# Se connecter et créer des données
docker exec -it postgres psql -U postgres
CREATE DATABASE testdb;
\c testdb
CREATE TABLE users (id SERIAL PRIMARY KEY, name VARCHAR(100));
INSERT INTO users (name) VALUES ('Alice'), ('Bob');
SELECT * FROM users;
\q

# Arrêter et supprimer le conteneur
docker stop postgres
docker rm postgres

# Relancer avec le même volume
docker run -d \
  --name postgres \
  -e POSTGRES_PASSWORD=secret \
  -v postgres_data:/var/lib/postgresql/data \
  -p 5432:5432 \
  postgres:15

# Vérifier que les données sont toujours là
docker exec -it postgres psql -U postgres -d testdb -c "SELECT * FROM users;"
```

## 📁 Exercice 2 : Application Web avec code live

### docker-compose.yml

```yaml
version: '3.8'

services:
  nginx:
    image: nginx:alpine
    ports:
      - "8080:80"
    volumes:
      - ./html:/usr/share/nginx/html:ro
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
      - nginx_logs:/var/log/nginx

  php:
    image: php:8.2-fpm
    volumes:
      - ./app:/var/www/html

volumes:
  nginx_logs:
```

### Tester

```bash
# Créer des fichiers
mkdir -p html app
echo "<h1>Hello Docker!</h1>" > html/index.html

# Démarrer
docker compose up -d

# Modifier le fichier (changements visibles immédiatement)
echo "<h1>Updated!</h1>" > html/index.html

# Voir les logs
docker compose exec nginx cat /var/log/nginx/access.log
```

## 🔄 Backup et Restore

### Sauvegarder un volume

```bash
# Méthode 1 : Avec tar
docker run --rm \
  -v my-volume:/data \
  -v $(pwd):/backup \
  alpine tar czf /backup/volume-backup.tar.gz -C /data .

# Méthode 2 : Avec docker cp
docker run -d --name temp -v my-volume:/data alpine sleep 3600
docker cp temp:/data ./backup
docker stop temp && docker rm temp
```

### Restaurer un volume

```bash
# Créer un nouveau volume
docker volume create restored-volume

# Restaurer depuis tar
docker run --rm \
  -v restored-volume:/data \
  -v $(pwd):/backup \
  alpine tar xzf /backup/volume-backup.tar.gz -C /data
```

## 📊 Exercice 3 : Stack WordPress complète

### docker-compose.yml

```yaml
version: '3.8'

services:
  db:
    image: mysql:8.0
    volumes:
      - db_data:/var/lib/mysql
      - ./mysql-init:/docker-entrypoint-initdb.d:ro
    environment:
      MYSQL_ROOT_PASSWORD: rootpass
      MYSQL_DATABASE: wordpress
      MYSQL_USER: wpuser
      MYSQL_PASSWORD: wppass
    restart: unless-stopped

  wordpress:
    image: wordpress:latest
    depends_on:
      - db
    ports:
      - "8000:80"
    volumes:
      - wp_data:/var/www/html
      - ./themes:/var/www/html/wp-content/themes/custom
      - ./uploads:/var/www/html/wp-content/uploads
    environment:
      WORDPRESS_DB_HOST: db:3306
      WORDPRESS_DB_USER: wpuser
      WORDPRESS_DB_PASSWORD: wppass
      WORDPRESS_DB_NAME: wordpress
    restart: unless-stopped

  backup:
    image: alpine:latest
    volumes:
      - db_data:/db:ro
      - wp_data:/wp:ro
      - ./backups:/backup
    command: sh -c "tar czf /backup/backup-$$(date +%Y%m%d-%H%M%S).tar.gz /db /wp"

volumes:
  db_data:
    driver: local
  wp_data:
    driver: local
```

## 🔍 Inspection et Debugging

### Trouver où sont stockés les volumes

```bash
docker volume inspect my-volume | grep Mountpoint
```

### Voir l'utilisation de l'espace

```bash
docker system df
docker system df -v
```

### Copier des fichiers

```bash
# Volume → Hôte
docker run --rm -v my-volume:/source -v $(pwd):/dest alpine cp /source/file.txt /dest/

# Hôte → Volume
docker run --rm -v my-volume:/dest -v $(pwd):/source alpine cp /source/file.txt /dest/
```

## 🔒 Permissions et Sécurité

### Définir les permissions

```bash
# Volume avec permissions spécifiques
docker run --rm \
  -v my-volume:/data \
  alpine sh -c "chown -R 1000:1000 /data && chmod -R 755 /data"
```

### Utiliser un user spécifique

```yaml
version: '3.8'

services:
  app:
    image: node:18
    user: "1000:1000"
    volumes:
      - ./app:/home/node/app
    working_dir: /home/node/app
```

## 📈 Volumes avancés

### Driver NFS

```yaml
volumes:
  nfs_data:
    driver: local
    driver_opts:
      type: nfs
      o: addr=10.0.0.10,rw
      device: ":/path/to/share"
```

### Driver CIFS/SMB

```bash
docker volume create \
  --driver local \
  --opt type=cifs \
  --opt device=//server/share \
  --opt o=username=user,password=pass \
  smb_volume
```

## 🎓 Best Practices

1. **Utilisez des volumes nommés** pour les données importantes
2. **Bind mounts** pour le développement uniquement
3. **Sauvegardez régulièrement** les volumes critiques
4. **Documentez** les volumes nécessaires
5. **Utilisez .dockerignore** pour éviter de monter des fichiers inutiles
6. **Read-only** quand c'est possible (`:ro`)

## 🧹 Nettoyage

```bash
# Supprimer tous les volumes non utilisés
docker volume prune

# Supprimer un volume spécifique (force)
docker volume rm -f my-volume

# Nettoyage complet
docker system prune -a --volumes
```

## 🔗 Ressources

- [Docker Volumes Documentation](https://docs.docker.com/storage/volumes/)
- [Bind Mounts](https://docs.docker.com/storage/bind-mounts/)
- [Storage Drivers](https://docs.docker.com/storage/storagedriver/)
