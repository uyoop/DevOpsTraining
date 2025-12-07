# Machine Vagrant Docker pour exercice réseau

Machine Vagrant Ubuntu 20.04 avec Docker, Docker Compose et Alpine pré-installés.

## Démarrage

Pour démarrer la machine :

```bash
vagrant up
```

Pour vous connecter :

```bash
vagrant ssh
```

## Arrêt et suppression

Pour arrêter la machine :

```bash
vagrant halt
```

Pour supprimer la machine :

```bash
vagrant destroy
```

## Vérification

Une fois connecté, vérifiez que Docker fonctionne :

```bash
docker --version
docker ps
```

## Exercice

Vous êtes maintenant prêt à faire l'exercice de manipulation des réseaux Docker.

## Exercice : Registry Docker privé (TLS + auth)

Objectif : déployer et tester un registry privé sécurisé à l'intérieur de la VM.

### 1) Démarrer et provisionner la VM
```bash
vagrant up         # crée la VM, installe Docker, compose, registry TLS+auth
```
Si besoin de repartir de zéro :
```bash
vagrant destroy -f
vagrant up
```

### 2) Se connecter et vérifier
```bash
vagrant ssh
docker ps          # doit montrer mon-registry exposé en 443
```

### 3) Authentification sur le registry (dans la VM)
```bash
docker login https://localhost:443
# Username: testuser
# Password: testpassword
```

### 4) Push d'une image de test
```bash
docker pull alpine:latest
docker tag alpine:latest localhost:443/alpine
docker push localhost:443/alpine
```

### 5) Consulter le catalogue
```bash
curl -k -u testuser:testpassword https://localhost:443/v2/_catalog
```

### 6) Fichiers/chemins utiles (dans la VM)
- Registry et données : `/opt/registry-secure` (data, certs, auth, docker-compose.yml)
- Certificat autosigné : `/opt/registry-secure/certs/localhost.crt`
- htpasswd : `/opt/registry-secure/auth/htpasswd`
- Service : `docker compose -f /opt/registry-secure/docker-compose.yml ps|logs`

### 7) Accès depuis l'hôte (facultatif)
Le port 443 de la VM est forwardé sur l'hôte en 5443. Si Docker est installé sur l'hôte :
```bash
vagrant ssh -- sudo cat /opt/registry-secure/certs/localhost.crt > /tmp/ca.crt
sudo mkdir -p /etc/docker/certs.d/localhost:5443
sudo cp /tmp/ca.crt /etc/docker/certs.d/localhost:5443/ca.crt
sudo systemctl restart docker
docker login https://localhost:5443
docker push localhost:5443/alpine
```
