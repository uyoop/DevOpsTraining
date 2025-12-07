# TP 8 : Docker Swarm

## 🎯 Objectifs

- Comprendre Docker Swarm et l'orchestration
- Initialiser un cluster Swarm
- Déployer des services et stacks
- Gérer la haute disponibilité et le scaling

## 📋 Prérequis

- Docker installé sur plusieurs machines (ou VMs)
- Ports ouverts : 2377 (cluster), 7946 (communication), 4789 (overlay network)

## 🐝 Qu'est-ce que Docker Swarm ?

Docker Swarm est l'outil d'orchestration natif de Docker pour :
- Gérer un cluster de Docker Engines
- Déployer des services distribués
- Load balancing automatique
- Auto-healing (redémarrage automatique)
- Scaling horizontal
- Rolling updates

## 🚀 Initialiser un Swarm

### Sur le manager

```bash
# Initialiser le Swarm
docker swarm init --advertise-addr <MANAGER-IP>

# Récupérer le token pour joindre des workers
docker swarm join-token worker

# Récupérer le token pour joindre des managers
docker swarm join-token manager
```

### Sur les workers

```bash
docker swarm join --token <TOKEN> <MANAGER-IP>:2377
```

### Gérer le cluster

```bash
# Lister les nœuds
docker node ls

# Inspecter un nœud
docker node inspect <NODE-ID>

# Promouvoir un worker en manager
docker node promote <NODE-ID>

# Rétrograder un manager en worker
docker node demote <NODE-ID>

# Supprimer un nœud
docker node rm <NODE-ID>
```

## 📦 Déployer des Services

### Service simple

```bash
# Créer un service
docker service create \
  --name web \
  --replicas 3 \
  --publish 8080:80 \
  nginx:alpine

# Lister les services
docker service ls

# Inspecter un service
docker service inspect web

# Voir les tâches (conteneurs) d'un service
docker service ps web

# Logs du service
docker service logs web
```

### Scaling

```bash
# Augmenter le nombre de réplicas
docker service scale web=5

# Diminuer
docker service scale web=2

# Auto-scaling (avec ressources)
docker service update \
  --replicas 10 \
  --update-parallelism 2 \
  --update-delay 10s \
  web
```

### Mise à jour (Rolling Update)

```bash
# Mettre à jour l'image
docker service update --image nginx:1.25 web

# Rollback
docker service rollback web

# Update avec paramètres
docker service update \
  --image nginx:1.25 \
  --update-parallelism 2 \
  --update-delay 10s \
  --update-failure-action rollback \
  web
```

## 🗂️ Docker Stack

### docker-compose.yml pour Swarm

```yaml
version: '3.8'

services:
  web:
    image: nginx:alpine
    ports:
      - "80:80"
    deploy:
      replicas: 3
      update_config:
        parallelism: 1
        delay: 10s
      restart_policy:
        condition: on-failure
        max_attempts: 3
      placement:
        constraints:
          - node.role == worker
    networks:
      - webnet

  visualizer:
    image: dockersamples/visualizer:latest
    ports:
      - "8080:8080"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    deploy:
      placement:
        constraints:
          - node.role == manager
    networks:
      - webnet

networks:
  webnet:
    driver: overlay
```

### Déployer une stack

```bash
# Déployer
docker stack deploy -c docker-compose.yml mystack

# Lister les stacks
docker stack ls

# Services de la stack
docker stack services mystack

# Tâches de la stack
docker stack ps mystack

# Supprimer la stack
docker stack rm mystack
```

## 🌐 Réseaux Overlay

### Créer un réseau overlay

```bash
docker network create \
  --driver overlay \
  --attachable \
  my-overlay
```

### Utiliser dans un service

```bash
docker service create \
  --name app \
  --network my-overlay \
  --replicas 3 \
  myapp:latest
```

## 🔒 Secrets

### Créer un secret

```bash
# Depuis un fichier
echo "my-secret-password" | docker secret create db_password -

# Depuis stdin
docker secret create db_password /path/to/secret.txt

# Lister les secrets
docker secret ls

# Inspecter
docker secret inspect db_password
```

### Utiliser dans un service

```bash
docker service create \
  --name db \
  --secret db_password \
  --env POSTGRES_PASSWORD_FILE=/run/secrets/db_password \
  postgres:15
```

### Avec docker-compose

```yaml
version: '3.8'

services:
  db:
    image: postgres:15
    secrets:
      - db_password
    environment:
      POSTGRES_PASSWORD_FILE: /run/secrets/db_password

secrets:
  db_password:
    external: true
```

## 📊 Exemple : Stack WordPress

### docker-compose-swarm.yml

```yaml
version: '3.8'

services:
  db:
    image: mysql:8.0
    volumes:
      - db_data:/var/lib/mysql
    environment:
      MYSQL_ROOT_PASSWORD_FILE: /run/secrets/db_root_password
      MYSQL_DATABASE: wordpress
      MYSQL_USER: wpuser
      MYSQL_PASSWORD_FILE: /run/secrets/db_password
    secrets:
      - db_root_password
      - db_password
    networks:
      - backend
    deploy:
      replicas: 1
      placement:
        constraints:
          - node.labels.type == database

  wordpress:
    image: wordpress:latest
    ports:
      - "80:80"
    environment:
      WORDPRESS_DB_HOST: db:3306
      WORDPRESS_DB_USER: wpuser
      WORDPRESS_DB_PASSWORD_FILE: /run/secrets/db_password
      WORDPRESS_DB_NAME: wordpress
    secrets:
      - db_password
    networks:
      - frontend
      - backend
    deploy:
      replicas: 3
      update_config:
        parallelism: 1
        delay: 10s
      restart_policy:
        condition: on-failure
      placement:
        constraints:
          - node.role == worker

  nginx:
    image: nginx:alpine
    ports:
      - "8080:80"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
    networks:
      - frontend
    deploy:
      replicas: 2
      placement:
        constraints:
          - node.role == worker

volumes:
  db_data:

networks:
  frontend:
    driver: overlay
  backend:
    driver: overlay

secrets:
  db_root_password:
    external: true
  db_password:
    external: true
```

### Déployer

```bash
# Créer les secrets
echo "root-secret-password" | docker secret create db_root_password -
echo "wp-secret-password" | docker secret create db_password -

# Labelliser un nœud pour la database
docker node update --label-add type=database <NODE-ID>

# Déployer la stack
docker stack deploy -c docker-compose-swarm.yml wordpress

# Monitorer
watch docker stack ps wordpress
```

## 🏷️ Labels et Constraints

### Ajouter des labels aux nœuds

```bash
docker node update --label-add environment=production node1
docker node update --label-add datacenter=paris node2
docker node update --label-add ssd=true node3
```

### Utiliser dans les contraintes

```yaml
deploy:
  placement:
    constraints:
      - node.labels.environment == production
      - node.labels.ssd == true
    preferences:
      - spread: node.labels.datacenter
```

## 🔍 Monitoring et Observabilité

### Stack de monitoring

```yaml
version: '3.8'

services:
  prometheus:
    image: prom/prometheus:latest
    ports:
      - "9090:9090"
    volumes:
      - prometheus_data:/prometheus
      - ./prometheus.yml:/etc/prometheus/prometheus.yml:ro
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
    networks:
      - monitoring
    deploy:
      placement:
        constraints:
          - node.role == manager

  grafana:
    image: grafana/grafana:latest
    ports:
      - "3000:3000"
    volumes:
      - grafana_data:/var/lib/grafana
    networks:
      - monitoring
    deploy:
      replicas: 1

  cadvisor:
    image: gcr.io/cadvisor/cadvisor:latest
    ports:
      - "8080:8080"
    volumes:
      - /:/rootfs:ro
      - /var/run:/var/run:ro
      - /sys:/sys:ro
      - /var/lib/docker/:/var/lib/docker:ro
    networks:
      - monitoring
    deploy:
      mode: global

volumes:
  prometheus_data:
  grafana_data:

networks:
  monitoring:
    driver: overlay
```

## 💪 Haute Disponibilité

### Configuration recommandée

- **Production** : 3 ou 5 managers (nombre impair)
- **Quorum** : Majorité des managers doit être disponible
- **Workers** : Autant que nécessaire

### Drain d'un nœud

```bash
# Mettre en maintenance (ne reçoit plus de nouvelles tâches)
docker node update --availability drain node1

# Remettre en service
docker node update --availability active node1
```

## 🎯 Best Practices

1. **Managers** : Nombre impair (3, 5, 7) pour le quorum
2. **Secrets** : Utilisez Docker secrets, jamais d'env variables pour les mots de passe
3. **Ressources** : Définissez des limites CPU/RAM
4. **Health Checks** : Toujours définir des health checks
5. **Rolling Updates** : Configurez `update_delay` et `update_parallelism`
6. **Monitoring** : Utilisez Prometheus + Grafana
7. **Backup** : Sauvegardez `/var/lib/docker/swarm` sur les managers

## 🧹 Nettoyage

```bash
# Quitter le swarm (worker)
docker swarm leave

# Quitter le swarm (manager)
docker swarm leave --force

# Supprimer un service
docker service rm web

# Supprimer une stack
docker stack rm mystack
```

## 🆚 Swarm vs Kubernetes

| Feature | Docker Swarm | Kubernetes |
|---------|--------------|------------|
| Installation | Simple | Complexe |
| Courbe d'apprentissage | Facile | Difficile |
| Écosystème | Limité | Très large |
| Scaling | Bon | Excellent |
| Use case | PME, simpl | Enterprise |

## 🔗 Ressources

- [Swarm Documentation](https://docs.docker.com/engine/swarm/)
- [Swarm Tutorial](https://docs.docker.com/engine/swarm/swarm-tutorial/)
- [Stack Deploy Reference](https://docs.docker.com/engine/reference/commandline/stack_deploy/)
