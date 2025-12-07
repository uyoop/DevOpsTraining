# Guide de déploiement Ansible pour UyoopApp

## Pré-requis

### Sur la machine de contrôle (votre machine)
```bash
# Installer Ansible
sudo apt install ansible -y

# Vérifier l'installation
ansible --version
```

### Sur le(s) serveur(s) cible(s)
- SSH activé
- Utilisateur avec privilèges sudo
- Python 3 installé

## Configuration

### 1. Éditer l'inventaire

Modifiez `inventory.ini` pour ajouter vos serveurs :

```ini
[uyoop_servers]
production ansible_host=VOTRE_IP_SERVEUR ansible_user=VOTRE_USER ansible_ssh_private_key_file=~/.ssh/id_rsa
```

### 2. Tester la connexion

```bash
cd ansible
ansible all -m ping
```

## Déploiement

### Déploiement complet

```bash
cd ansible
ansible-playbook deploy.yml
```

### Déploiement sur un serveur spécifique

```bash
ansible-playbook deploy.yml --limit production
```

### Vérifier sans exécuter (dry-run)

```bash
ansible-playbook deploy.yml --check
```

### Avec prompt pour le mot de passe sudo

```bash
ansible-playbook deploy.yml --ask-become-pass
```

## Variables personnalisables

Dans `deploy.yml`, vous pouvez modifier :

- `app_dir`: Répertoire d'installation (défaut: `/opt/uyoop`)
- `app_port`: Port d'écoute (défaut: `8080`)
- `docker_compose_version`: Version de Docker Compose

## Commandes utiles

### Vérifier le statut sur les serveurs
```bash
ansible uyoop_servers -m shell -a "docker compose -f /opt/uyoop/docker-compose.yml ps"
```

### Voir les logs
```bash
ansible uyoop_servers -m shell -a "docker compose -f /opt/uyoop/docker-compose.yml logs --tail=50"
```

### Redémarrer l'application
```bash
ansible uyoop_servers -m shell -a "docker compose -f /opt/uyoop/docker-compose.yml restart"
```

### Arrêter l'application
```bash
ansible uyoop_servers -m shell -a "docker compose -f /opt/uyoop/docker-compose.yml down"
```

## Dépannage

### Erreur de connexion SSH
- Vérifiez que votre clé SSH est ajoutée : `ssh-add ~/.ssh/id_rsa`
- Testez la connexion directe : `ssh utilisateur@ip_serveur`

### Erreur de permissions
- Assurez-vous que l'utilisateur a les droits sudo
- Utilisez `--ask-become-pass` si nécessaire

### Docker non trouvé
- Le playbook installe automatiquement Docker
- Si problème, vérifiez les logs : `ansible-playbook deploy.yml -v`
