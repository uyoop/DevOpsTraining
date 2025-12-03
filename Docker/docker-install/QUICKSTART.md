# 🚀 Démarrage Rapide - Laboratoire Docker

## Installation automatique en une commande

```bash
./setup.sh
```

Ce script va :
1. ✅ Vérifier les prérequis (Vagrant, VirtualBox, Ansible)
2. 🚀 Créer et démarrer la VM Ubuntu 22.04 (4 GB RAM, 2 vCPUs)
3. 🐳 Installer Docker et Docker Compose
4. ✅ Vérifier que tout fonctionne

**Temps estimé : 5-10 minutes** (première fois)

---

## Installation manuelle (étape par étape)

### 1. Créer la VM
```bash
vagrant up
```

### 2. Installer Docker
```bash
ansible-playbook -i inventory.ini install_docker.yml
```

### 3. Tester l'installation
```bash
./test.sh
```

---

## Utilisation quotidienne

### Se connecter à la VM
```bash
vagrant ssh
```

### Premier test Docker
```bash
vagrant ssh -c "docker run hello-world"
```

### Arrêter la VM
```bash
vagrant halt
```

### Redémarrer la VM
```bash
vagrant up
```

---

## Accès aux services

| Service | URL depuis l'hôte | Description |
|---------|-------------------|-------------|
| HTTP | http://localhost:8080 | Applications web |
| HTTPS | https://localhost:8443 | Applications web sécurisées |
| VM SSH | `vagrant ssh` | Connexion directe |
| VM IP | 192.168.56.123 | Accès réseau privé |

---

## Exemples de TPs

### TP1 : Lancer un serveur web
```bash
vagrant ssh
docker run -d -p 80:80 --name nginx nginx:alpine
# Accès depuis l'hôte : http://localhost:8080
```

### TP2 : Stack complète avec Compose
```bash
vagrant ssh
cd /vagrant
cp docker-compose.example.yml docker-compose.yml
docker compose up -d
# Interface web : http://localhost:8080 (Adminer)
```

---

## Fichiers importants

- `README.md` - Documentation complète
- `COMMANDES.md` - Aide-mémoire Docker
- `Vagrantfile` - Configuration de la VM
- `setup.sh` - Installation automatique
- `test.sh` - Tests de vérification

---

## Commandes essentielles

```bash
# VM
vagrant up          # Démarrer
vagrant halt        # Arrêter
vagrant reload      # Redémarrer
vagrant ssh         # Se connecter
vagrant destroy     # Supprimer

# Docker (depuis la VM)
docker ps           # Conteneurs actifs
docker images       # Images disponibles
docker compose up   # Lancer une stack
```

---

## Support

En cas de problème :

1. Consultez `README.md` section Dépannage
2. Relancez `./test.sh` pour diagnostiquer
3. Vérifiez les logs : `vagrant ssh -c "sudo systemctl status docker"`

---

**Bon courage pour vos TPs Docker ! 🐳**
