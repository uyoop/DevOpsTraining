# TP 5 : Réseaux Docker

## 🎯 Objectifs

- Comprendre les types de réseaux Docker
- Créer et gérer des réseaux personnalisés
- Connecter des conteneurs entre eux
- Isoler les services avec des réseaux

## 📋 Prérequis

- Docker installé
- Connaissance des commandes Docker de base

## 🌐 Types de Réseaux Docker

### 1. Bridge (par défaut)

Réseau privé isolé sur l'hôte.

```bash
# Créer un réseau bridge
docker network create my-bridge-network

# Inspecter
docker network inspect my-bridge-network
```

### 2. Host

Partage la stack réseau de l'hôte.

```bash
docker run --network host nginx
```

### 3. None

Aucune connectivité réseau.

```bash
docker run --network none alpine
```

### 4. Overlay

Pour Docker Swarm (multi-hôtes).

## 🔧 Commandes Réseau

### Lister les réseaux

```bash
docker network ls
```

### Créer un réseau

```bash
docker network create my-network
docker network create --driver bridge --subnet 172.20.0.0/16 custom-network
```

### Inspecter un réseau

```bash
docker network inspect bridge
docker network inspect my-network
```

### Connecter/Déconnecter un conteneur

```bash
# Connecter
docker network connect my-network container-name

# Déconnecter
docker network disconnect my-network container-name
```

### Supprimer un réseau

```bash
docker network rm my-network
docker network prune  # Supprimer les réseaux non utilisés
```

## 🏗️ Exercice 1 : Frontend + Backend + Database

### Créer les réseaux

```bash
docker network create frontend-network
docker network create backend-network
```

### Lancer la base de données

```bash
docker run -d \
  --name postgres \
  --network backend-network \
  -e POSTGRES_PASSWORD=secret \
  postgres:15
```

### Lancer l'API backend

```bash
docker run -d \
  --name api \
  --network backend-network \
  --network frontend-network \
  -e DATABASE_URL=postgresql://postgres:secret@postgres:5432/mydb \
  my-api:latest
```

### Lancer le frontend

```bash
docker run -d \
  --name webapp \
  --network frontend-network \
  -p 8080:80 \
  my-webapp:latest
```

**Architecture** :
- Frontend → peut communiquer avec API (frontend-network)
- API → peut communiquer avec Frontend et Database (2 réseaux)
- Database → isolée, accessible seulement par API

## 📡 Exercice 2 : Communication entre conteneurs

### docker-compose.yml

```yaml
version: '3.8'

services:
  web:
    image: nginx:alpine
    networks:
      - frontend
    ports:
      - "8080:80"

  app:
    image: php:8.2-fpm
    networks:
      - frontend
      - backend

  db:
    image: mariadb:10
    networks:
      - backend
    environment:
      MYSQL_ROOT_PASSWORD: rootpass

networks:
  frontend:
    driver: bridge
  backend:
    driver: bridge
    internal: true  # Pas d'accès Internet
```

## 🔍 DNS et Service Discovery

Les conteneurs sur le même réseau peuvent se communiquer par leur nom.

```bash
# Dans le conteneur "app"
docker exec app ping db
docker exec app curl http://web
```

### Tester la résolution DNS

```bash
docker run --rm --network my-network alpine nslookup container-name
```

## 🔒 Isolation et Sécurité

### Créer un réseau isolé (sans Internet)

```bash
docker network create --internal secure-network
```

### Limiter l'accès réseau

```yaml
version: '3.8'

services:
  sensitive-app:
    image: my-app
    networks:
      secure:
        aliases:
          - app.secure
    cap_drop:
      - NET_RAW
      - NET_ADMIN

networks:
  secure:
    driver: bridge
    internal: true
```

## 📊 Configuration Avancée

### Subnet et IP personnalisées

```bash
docker network create \
  --driver bridge \
  --subnet 10.0.0.0/24 \
  --gateway 10.0.0.1 \
  custom-subnet
```

```yaml
version: '3.8'

services:
  app:
    image: nginx
    networks:
      custom:
        ipv4_address: 10.5.0.5

networks:
  custom:
    driver: bridge
    ipam:
      config:
        - subnet: 10.5.0.0/16
          gateway: 10.5.0.1
```

## 🎓 Exercice 3 : Reverse Proxy

### docker-compose.yml

```yaml
version: '3.8'

services:
  nginx-proxy:
    image: nginx:alpine
    ports:
      - "80:80"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
    networks:
      - proxy-network

  app1:
    image: nginx:alpine
    networks:
      - proxy-network
    volumes:
      - ./app1:/usr/share/nginx/html

  app2:
    image: nginx:alpine
    networks:
      - proxy-network
    volumes:
      - ./app2:/usr/share/nginx/html

networks:
  proxy-network:
    driver: bridge
```

### nginx.conf (proxy)

```nginx
events {}

http {
    upstream app1 {
        server app1:80;
    }

    upstream app2 {
        server app2:80;
    }

    server {
        listen 80;
        server_name app1.local;
        location / {
            proxy_pass http://app1;
        }
    }

    server {
        listen 80;
        server_name app2.local;
        location / {
            proxy_pass http://app2;
        }
    }
}
```

## 🔧 Debugging Réseau

### Inspecter les connexions

```bash
# Voir les processus réseau dans un conteneur
docker exec container-name netstat -tulpn

# Capturer le trafic
docker run --rm --net=container:my-container nicolaka/netshoot tcpdump -i any
```

### Tester la connectivité

```bash
docker run --rm --network my-network nicolaka/netshoot ping container-name
docker run --rm --network my-network nicolaka/netshoot curl http://container:port
```

## 📚 Best Practices

1. **Utilisez des réseaux personnalisés** plutôt que le bridge par défaut
2. **Isolez les services sensibles** avec des réseaux internes
3. **Nommez vos réseaux de façon descriptive**
4. **Utilisez des alias réseau** pour la flexibilité
5. **Documentez votre architecture réseau**

## 🔗 Ressources

- [Docker Network Documentation](https://docs.docker.com/network/)
- [Network Drivers](https://docs.docker.com/network/drivers/)
- [Netshoot Tool](https://github.com/nicolaka/netshoot)
