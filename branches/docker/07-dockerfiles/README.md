# TP 7 : Création de Dockerfiles

## 🎯 Objectifs

- Comprendre la structure d'un Dockerfile
- Créer des images Docker personnalisées
- Optimiser la taille et les performances des images
- Maîtriser les best practices

## 📋 Prérequis

- Docker installé
- Connaissance des commandes Docker de base

## 📝 Structure d'un Dockerfile

### Syntaxe de base

```dockerfile
# Commentaire
INSTRUCTION arguments
```

### Instructions principales

| Instruction | Description |
|-------------|-------------|
| `FROM` | Image de base |
| `RUN` | Exécuter des commandes |
| `COPY` | Copier des fichiers |
| `ADD` | Copier avec extraction |
| `WORKDIR` | Définir le répertoire de travail |
| `ENV` | Variables d'environnement |
| `EXPOSE` | Déclarer un port |
| `CMD` | Commande par défaut |
| `ENTRYPOINT` | Point d'entrée |
| `USER` | Utilisateur d'exécution |
| `VOLUME` | Point de montage |
| `LABEL` | Métadonnées |
| `ARG` | Arguments de build |

## 🐍 Exemple 1 : Application Python Simple

### Dockerfile

```dockerfile
# Image de base
FROM python:3.11-slim

# Métadonnées
LABEL maintainer="dev@example.com"
LABEL version="1.0"

# Variables d'environnement
ENV PYTHONUNBUFFERED=1
ENV APP_HOME=/app

# Créer le répertoire de travail
WORKDIR $APP_HOME

# Copier les dépendances
COPY requirements.txt .

# Installer les dépendances
RUN pip install --no-cache-dir -r requirements.txt

# Copier le code de l'application
COPY . .

# Exposer le port
EXPOSE 8000

# Utilisateur non-root
RUN useradd -m appuser && chown -R appuser:appuser $APP_HOME
USER appuser

# Commande de démarrage
CMD ["python", "app.py"]
```

### requirements.txt

```txt
flask==3.0.0
gunicorn==21.2.0
```

### app.py

```python
from flask import Flask

app = Flask(__name__)

@app.route('/')
def hello():
    return 'Hello from Docker!'

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8000)
```

### Build et run

```bash
docker build -t python-app:1.0 .
docker run -d -p 8000:8000 python-app:1.0
curl http://localhost:8000
```

## 🌐 Exemple 2 : Application Node.js

### Dockerfile

```dockerfile
FROM node:18-alpine

WORKDIR /app

# Copier package.json et package-lock.json
COPY package*.json ./

# Installer les dépendances
RUN npm ci --only=production

# Copier le code source
COPY . .

# Build l'application (si nécessaire)
RUN npm run build

# Exposer le port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node healthcheck.js

# Démarrage
CMD ["node", "dist/index.js"]
```

### .dockerignore

```
node_modules
npm-debug.log
Dockerfile
.dockerignore
.git
.gitignore
README.md
.env
.vscode
dist
coverage
```

## 🔨 Exemple 3 : Build Multi-stage

### Dockerfile (application Go)

```dockerfile
# Stage 1: Build
FROM golang:1.21-alpine AS builder

WORKDIR /build

# Copier les fichiers de dépendances
COPY go.mod go.sum ./
RUN go mod download

# Copier le code source
COPY . .

# Build l'application
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o app .

# Stage 2: Runtime
FROM alpine:latest

# Installer ca-certificates pour HTTPS
RUN apk --no-cache add ca-certificates

WORKDIR /root/

# Copier le binaire depuis le stage de build
COPY --from=builder /build/app .

# Exposer le port
EXPOSE 8080

# Exécuter l'application
CMD ["./app"]
```

**Avantages** :
- Image finale très légère (binaire Go seul)
- Pas d'outils de build dans l'image de production
- Sécurité améliorée

## 🎨 Exemple 4 : Application web statique avec Nginx

### Dockerfile

```dockerfile
# Stage 1: Build
FROM node:18-alpine AS build

WORKDIR /app

COPY package*.json ./
RUN npm ci

COPY . .
RUN npm run build

# Stage 2: Production
FROM nginx:alpine

# Copier la configuration Nginx personnalisée
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copier les fichiers buildés
COPY --from=build /app/dist /usr/share/nginx/html

# Exposer le port
EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=3s \
  CMD wget -q --spider http://localhost || exit 1

# Nginx démarre automatiquement
```

### nginx.conf

```nginx
server {
    listen 80;
    server_name _;
    root /usr/share/nginx/html;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }

    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    gzip on;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;
}
```

## 🐘 Exemple 5 : PHP avec Apache

### Dockerfile

```dockerfile
FROM php:8.2-apache

# Installer les extensions PHP
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    zip \
    unzip \
    git \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd pdo pdo_mysql mysqli \
    && a2enmod rewrite \
    && rm -rf /var/lib/apt/lists/*

# Installer Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Configuration Apache
ENV APACHE_DOCUMENT_ROOT=/var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

WORKDIR /var/www/html

# Copier composer files
COPY composer*.json ./
RUN composer install --no-dev --optimize-autoloader --no-scripts

# Copier l'application
COPY . .

# Permissions
RUN chown -R www-data:www-data /var/www/html

EXPOSE 80
```

## 🔧 ARG et ENV

### Dockerfile avec arguments

```dockerfile
FROM ubuntu:22.04

# Arguments de build
ARG APP_VERSION=1.0
ARG BUILD_DATE
ARG DEBIAN_FRONTEND=noninteractive

# Variables d'environnement
ENV APP_VERSION=${APP_VERSION}
ENV APP_HOME=/app
ENV PATH="$APP_HOME/bin:$PATH"

LABEL version="${APP_VERSION}"
LABEL build_date="${BUILD_DATE}"

RUN apt-get update && apt-get install -y \
    curl \
    wget \
    && rm -rf /var/lib/apt/lists/*

WORKDIR $APP_HOME

CMD ["echo", "Version: $APP_VERSION"]
```

### Build avec arguments

```bash
docker build \
  --build-arg APP_VERSION=2.0 \
  --build-arg BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ') \
  -t myapp:2.0 .
```

## 📊 Optimisation

### ❌ Mauvais exemple

```dockerfile
FROM ubuntu:22.04

RUN apt-get update
RUN apt-get install -y curl
RUN apt-get install -y wget
RUN apt-get install -y git

COPY . .
```

### ✅ Bon exemple

```dockerfile
FROM ubuntu:22.04

# Combiner les RUN et nettoyer le cache
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    && rm -rf /var/lib/apt/lists/*

# Utiliser .dockerignore
# Copier d'abord les dépendances (cache layer)
COPY requirements.txt .
RUN pip install -r requirements.txt

# Puis le code (change plus souvent)
COPY . .
```

## 🎯 Best Practices

### 1. Image de base minimale

```dockerfile
# Préférer
FROM alpine:3.18
# plutôt que
FROM ubuntu:latest
```

### 2. Utilisateur non-root

```dockerfile
RUN addgroup -g 1000 appgroup && \
    adduser -D -u 1000 -G appgroup appuser

USER appuser
```

### 3. Health checks

```dockerfile
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8080/health || exit 1
```

### 4. Multi-stage builds

Réduisez la taille finale de l'image.

### 5. .dockerignore

```
.git
.gitignore
node_modules
*.md
.env
.vscode
.idea
Dockerfile
docker-compose.yml
```

### 6. Ordre des COPY

```dockerfile
# ✅ Bon : dépendances d'abord
COPY package.json package-lock.json ./
RUN npm install
COPY . .

# ❌ Mauvais : tout d'un coup
COPY . .
RUN npm install
```

## 🔍 Debugging

### Build avec output verbeux

```bash
docker build --progress=plain --no-cache -t myapp .
```

### Inspecter les layers

```bash
docker history myapp:latest
docker inspect myapp:latest
```

### Tester un stage intermédiaire

```bash
docker build --target builder -t myapp:builder .
docker run -it myapp:builder sh
```

## 🧪 Exercices

### Exercice 1
Créez un Dockerfile pour une API Flask avec PostgreSQL.

### Exercice 2
Optimisez un Dockerfile existant (réduire la taille de moitié).

### Exercice 3
Créez une image multi-architecture (amd64/arm64).

## 🔗 Ressources

- [Dockerfile Reference](https://docs.docker.com/engine/reference/builder/)
- [Best Practices](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)
- [Multi-stage Builds](https://docs.docker.com/build/building/multi-stage/)
