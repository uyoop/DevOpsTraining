# Déploiement Docker avec Vagrant et Ansible

## Prérequis

- Vagrant installé
- VirtualBox installé
- Ansible installé sur votre machine hôte

## Installation des collections Ansible nécessaires

Avant de lancer Vagrant, installez la collection Docker pour Ansible :

```bash
ansible-galaxy collection install community.docker
```

## Démarrage

Pour déployer l'application :

```bash
vagrant up
```

Cette commande va :
1. Créer une VM Ubuntu 22.04
2. Installer Docker
3. Construire l'image Docker
4. Lancer le conteneur avec l'application

## Accès à l'application

Une fois le déploiement terminé, accédez à l'application via :

```
http://localhost:8000
```

## Commandes utiles

- `vagrant ssh` : Se connecter à la VM
- `vagrant halt` : Arrêter la VM
- `vagrant destroy` : Détruire la VM
- `vagrant provision` : Re-provisionner (relancer Ansible)
- `vagrant reload --provision` : Redémarrer et re-provisionner

## Structure du projet

```
.
├── Vagrantfile              # Configuration de la VM
├── ansible/
│   ├── playbook.yml        # Playbook Ansible principal
│   ├── inventory           # Inventaire des hôtes
│   └── ansible.cfg         # Configuration Ansible
├── Dockerfile              # Image Docker de l'application
├── app/                    # Code source de l'application
└── db/                     # Scripts SQL
```

## Dépannage

Si vous rencontrez des problèmes :

1. Vérifiez que la collection Docker est installée :
   ```bash
   ansible-galaxy collection list | grep community.docker
   ```

2. Vérifiez les logs Vagrant :
   ```bash
   vagrant up --debug
   ```

3. Reconnectez-vous et vérifiez l'état Docker :
   ```bash
   vagrant ssh
   sudo docker ps
   sudo docker logs mon-app-container
   ```
