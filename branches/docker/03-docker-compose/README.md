# TP 3 : Docker Compose

## 🎯 Objectifs

- Comprendre Docker Compose et son utilité
- Créer des fichiers docker-compose.yml
- Orchestrer des applications multi-conteneurs
- Gérer les réseaux et volumes avec Compose

## 📋 Prérequis

- Docker et Docker Compose installés
- Connaissance des commandes Docker de base

## 🚀 Introduction à Docker Compose

Docker Compose permet de définir et gérer des applications multi-conteneurs avec un fichier YAML.

### Installation (si nécessaire)

```bash
# Vérifier la version
docker compose version

# Docker Compose v2 est inclus avec Docker Desktop
# ou comme plugin Docker Engine
```

## 📝 Structure d'un fichier docker-compose.yml

```yaml
version: '3.8'

services:
  service_name:
    image: image:tag
    ports:
      - "host:container"
    environment:
      - KEY=VALUE
    volumes:
      - ./local:/container
    networks:
      - network_name

networks:
  network_name:
    driver: bridge

volumes:
  volume_name:
    driver: local
```

## 🌐 Exemple 1 : Application Web Simple

`docker-compose.yml`

```yaml
version: '3.8'

services:
  web:
    image: nginx:alpine
    ports:
      - "8080:80"
    volumes:
      - ./html:/usr/share/nginx/html
    restart: unless-stopped

  app:
    image: php:8.2-fpm-alpine
    volumes:
      - ./app:/var/www/html
    restart: unless-stopped
```

```bash
# Démarrer
docker compose up -d

# Voir les logs
docker compose logs -f

# Arrêter
docker compose down
```

## 🗄️ Exemple 2 : Stack WordPress

`docker-compose.yml`

```yaml
version: '3.8'

services:
  db:
    image: mysql:8.0
    volumes:
      - db_data:/var/lib/mysql
    environment:
      MYSQL_ROOT_PASSWORD: rootpassword
      MYSQL_DATABASE: wordpress
      MYSQL_USER: wpuser
      MYSQL_PASSWORD: wppassword
    restart: always
    networks:
      - wordpress-network

  wordpress:
    image: wordpress:latest
    depends_on:
      - db
    ports:
      - "8000:80"
    environment:
      WORDPRESS_DB_HOST: db:3306
      WORDPRESS_DB_USER: wpuser
      WORDPRESS_DB_PASSWORD: wppassword
      WORDPRESS_DB_NAME: wordpress
    volumes:
      - wordpress_data:/var/www/html
    restart: always
    networks:
      - wordpress-network

volumes:
  db_data:
  wordpress_data:

networks:
  wordpress-network:
    driver: bridge
```

## 📊 Exemple 3 : Stack de Monitoring

`docker-compose.yml`

```yaml
version: '3.8'

services:
  prometheus:
    image: prom/prometheus:latest
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus_data:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
    networks:
      - monitoring

  grafana:
    image: grafana/grafana:latest
    ports:
      - "3000:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
    volumes:
      - grafana_data:/var/lib/grafana
    depends_on:
      - prometheus
    networks:
      - monitoring

  node-exporter:
    image: prom/node-exporter:latest
    ports:
      - "9100:9100"
    networks:
      - monitoring

volumes:
  prometheus_data:
  grafana_data:

networks:
  monitoring:
    driver: bridge
```

## 🎮 Commandes Docker Compose

### Gestion du cycle de vie

```bash
# Démarrer les services
docker compose up
docker compose up -d  # Mode détaché
docker compose up --build  # Rebuild les images

# Arrêter les services
docker compose stop
docker compose down  # Arrête et supprime les conteneurs
docker compose down -v  # + supprime les volumes

# Redémarrer
docker compose restart
docker compose restart service_name
```

### Visualisation

```bash
# Voir les services en cours
docker compose ps

# Logs
docker compose logs
docker compose logs -f service_name
docker compose logs --tail=100

# Voir la configuration
docker compose config
```

### Gestion des services

```bash
# Scaler un service
docker compose up -d --scale web=3

# Exécuter une commande
docker compose exec service_name bash
docker compose exec db mysql -u root -p

# Build
docker compose build
docker compose build --no-cache
```

## 🏗️ Exemple 4 : Application avec Build

`docker-compose.yml`

```yaml
version: '3.8'

services:
  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile
    ports:
      - "3000:3000"
    volumes:
      - ./frontend/src:/app/src
    environment:
      - NODE_ENV=development

  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile
    ports:
      - "5000:5000"
    environment:
      - DATABASE_URL=postgresql://user:pass@db:5432/mydb
    depends_on:
      - db

  db:
    image: postgres:15
    environment:
      POSTGRES_USER: user
      POSTGRES_PASSWORD: pass
      POSTGRES_DB: mydb
    volumes:
      - postgres_data:/var/lib/postgresql/data

volumes:
  postgres_data:
```

## 🔧 Variables d'Environnement

### Fichier .env

```env
# .env
POSTGRES_USER=myuser
POSTGRES_PASSWORD=mypassword
POSTGRES_DB=mydb
APP_PORT=8080
```

### Utilisation dans docker-compose.yml

```yaml
version: '3.8'

services:
  db:
    image: postgres:15
    environment:
      POSTGRES_USER: ${POSTGRES_USER}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
      POSTGRES_DB: ${POSTGRES_DB}
    ports:
      - "${APP_PORT}:5432"
```

## 📚 Exercices Pratiques

### Exercice 1 : Stack LAMP

Créez une stack LAMP (Linux, Apache, MySQL, PHP) complète.

### Exercice 2 : Application Node.js + MongoDB

Créez une API Node.js connectée à MongoDB avec Docker Compose.

### Exercice 3 : Reverse Proxy Nginx

Configurez Nginx comme reverse proxy devant plusieurs services web.

## 🎓 Best Practices

1. **Utilisez des versions spécifiques** : `nginx:1.25` plutôt que `nginx:latest`
2. **Nommez vos réseaux et volumes**
3. **Utilisez des fichiers .env** pour les secrets
4. **Utilisez depends_on** pour gérer les dépendances
5. **Définissez des health checks**
6. **Utilisez restart policies** appropriées

## 🔗 Ressources

- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Compose File Reference](https://docs.docker.com/compose/compose-file/)
- [Awesome Compose](https://github.com/docker/awesome-compose)
