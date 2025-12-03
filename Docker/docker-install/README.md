# Laboratoire Docker avec Vagrant et Ansible

Ce projet configure automatiquement une VM VirtualBox performante pour réaliser des TPs Docker, avec installation automatisée via Ansible.

## 📋 Prérequis

- [VirtualBox](https://www.virtualbox.org/) (6.1 ou supérieur)
- [Vagrant](https://www.vagrantup.com/) (2.2 ou supérieur)
- [Ansible](https://www.ansible.com/) (2.9 ou supérieur)

```bash
# Vérifier les versions installées
vagrant --version
VirtualBox --help | head -n 1
ansible --version
```

## 🚀 Démarrage rapide

### 1. Créer et démarrer la VM

```bash
# Depuis le répertoire du projet
vagrant up
```

Cette commande va :
- Télécharger Ubuntu 22.04 LTS (première fois uniquement)
- Créer une VM avec 4 GB RAM et 2 vCPUs
- Configurer le réseau (IP: 192.168.56.123)
- Mettre à jour le système
- Installer les outils de base (vim, git, curl, etc.)

**Temps estimé** : 5-10 minutes (première fois)

### 2. Installer Docker avec Ansible

```bash
# Installer Docker sur la VM
ansible-playbook -i inventory.ini install_docker.yml
```

Cette commande va :
- Installer Docker Engine et Docker Compose
- Configurer le service Docker
- Ajouter l'utilisateur vagrant au groupe docker

### 3. Se connecter à la VM

```bash
# Connexion SSH
vagrant ssh

# Vérifier l'installation Docker
docker --version
docker compose version

# Tester Docker
docker run hello-world
```

## 🔧 Configuration de la VM

### Ressources allouées

| Ressource | Valeur | Ajustable dans |
|-----------|--------|----------------|
| RAM | 4 GB | `Vagrantfile` ligne 57 |
| CPU | 2 vCPUs | `Vagrantfile` ligne 54 |
| Disque | 10 GB (dynamique) | Par défaut |
| OS | Ubuntu 22.04 LTS | `Vagrantfile` ligne 8 |

### Réseau

- **IP privée** : `192.168.56.123`
- **Hostname** : `docker-lab`

### Ports forwardés

| Service | Port VM | Port Hôte | Description |
|---------|---------|-----------|-------------|
| HTTP | 80 | 8080 | Applications web |
| HTTPS | 443 | 8443 | Applications web sécurisées |
| App | 3000 | 3000 | Node.js, React, etc. |
| App | 8000 | 8000 | Python, API, etc. |
| PostgreSQL | 5432 | 5432 | Base de données |
| MySQL | 3306 | 3306 | Base de données |
| MongoDB | 27017 | 27017 | Base de données |
| Redis | 6379 | 6379 | Cache |

Accédez aux services depuis l'hôte via `localhost:PORT`

## 📚 Commandes Vagrant utiles

```bash
# Démarrer la VM
vagrant up

# Arrêter la VM
vagrant halt

# Redémarrer la VM
vagrant reload

# Supprimer la VM
vagrant destroy

# État de la VM
vagrant status

# Se connecter en SSH
vagrant ssh

# Reprovisioner la VM (réexécuter les scripts)
vagrant provision

# Mettre à jour la box Ubuntu
vagrant box update
```

## 🐳 Commandes Docker de base pour les TPs

```bash
# Se connecter à la VM
vagrant ssh

# Lister les conteneurs
docker ps
docker ps -a

# Lister les images
docker images

# Lancer un conteneur
docker run -d -p 80:80 nginx

# Arrêter un conteneur
docker stop <container_id>

# Supprimer un conteneur
docker rm <container_id>

# Supprimer une image
docker rmi <image_id>

# Voir les logs
docker logs <container_id>

# Docker Compose
docker compose up -d
docker compose down
docker compose ps
```

## 🔍 Dépannage

### La VM ne démarre pas

```bash
# Vérifier VirtualBox
VBoxManage list vms

# Détruire et recréer
vagrant destroy -f
vagrant up
```

### Erreur Ansible

```bash
# Tester la connexion
ansible -i inventory.ini all -m ping

# Vérifier la clé SSH
ls -la ~/.vagrant.d/insecure_private_key
```

### Docker ne fonctionne pas

```bash
# Se reconnecter pour appliquer les groupes
vagrant ssh
exit
vagrant ssh

# Vérifier le service
sudo systemctl status docker
```

### Modifier les ressources

Éditez le `Vagrantfile` puis :

```bash
vagrant reload
```

## 📁 Structure du projet

```
.
├── Vagrantfile              # Configuration de la VM
├── ansible.cfg              # Configuration Ansible
├── inventory.ini            # Inventaire des hôtes
├── install_docker.yml       # Playbook d'installation Docker
├── README.md                # Ce fichier
└── roles/
    └── docker_install/
        ├── defaults/
        │   └── main.yml     # Variables par défaut
        └── tasks/
            └── main.yml     # Tâches d'installation
```

## 💡 Conseils pour les TPs

1. **Snapshots** : Créez des snapshots avant les TPs importants
   ```bash
   # Via VirtualBox Manager ou
   VBoxManage snapshot docker-lab-tp take "avant_tp_compose"
   ```

2. **Nettoyage Docker** : Libérez de l'espace régulièrement
   ```bash
   docker system prune -a
   ```

3. **Ressources** : Si lent, augmentez RAM/CPU dans `Vagrantfile`

4. **Backup** : Exportez vos configurations importantes
   ```bash
   # Depuis la VM
   tar -czf ~/backup-tp.tar.gz /chemin/vers/vos/fichiers
   # Puis copiez depuis l'hôte
   scp -P 2222 vagrant@127.0.0.1:~/backup-tp.tar.gz .
   ```

## 📖 Ressources

- [Documentation Docker](https://docs.docker.com/)
- [Documentation Vagrant](https://www.vagrantup.com/docs)
- [Documentation Ansible](https://docs.ansible.com/)

## 🎯 Exercices suggérés

1. Déployer un serveur web Nginx
2. Créer un stack LAMP (Linux, Apache, MySQL, PHP)
3. Utiliser Docker Compose pour une application multi-conteneurs
4. Créer vos propres images Docker
5. Explorer les volumes et le networking
6. Mettre en place un registry Docker privé

---

**Bon courage pour vos TPs Docker ! 🐳**
