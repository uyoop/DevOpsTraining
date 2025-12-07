# 🚀 Démarrage rapide - UyoopApp

## ⚠️ Pré-requis : Docker

### Docker pas encore installé ?

```bash
# Installation automatique (Ubuntu/Debian)
sudo ./install-docker.sh

# Puis se déconnecter/reconnecter ou exécuter :
newgrp docker
```

---

## En 3 commandes

```bash
# 1. Vérifier que Docker est installé
docker --version && docker compose version

# 2. Déployer l'application
make install

# 3. Ouvrir dans le navigateur
# http://localhost:8080
```

C'est tout ! L'application est prête. 🎉

---

## Commandes essentielles

```bash
make help       # Voir toutes les commandes disponibles
make logs       # Voir les logs en temps réel
make status     # Vérifier l'état des conteneurs
make backup     # Sauvegarder la base de données
make test       # Lancer les tests
make down       # Arrêter l'application
```

---

## Accès

- **Formulaire** : http://localhost:8080
- **Admin** : http://localhost:8080/admin.php

---

## Si vous n'avez pas Make

```bash
# Installation
./deploy.sh

# Voir les logs
docker compose logs -f

# Arrêter
docker compose down

# Tests
./test.sh
```

---

## Dépannage rapide

### L'application ne démarre pas
```bash
docker compose down
docker compose up -d --build
```

### Port 8080 déjà utilisé
Modifiez dans `docker-compose.yml` :
```yaml
ports:
  - "9090:80"  # Utiliser le port 9090 au lieu de 8080
```

### Problème de permissions
```bash
sudo chown -R $(whoami):$(whoami) data/
```

---

## Documentation complète

- **README.md** - Vue d'ensemble et guide complet
- **DOCKER.md** - Documentation détaillée Docker
- **ARCHITECTURE.md** - Architecture technique
- **ansible/README.md** - Déploiement avec Ansible

---

## Support

Besoin d'aide ? Consultez les logs :
```bash
docker compose logs -f
```
