# README - Déploiement de l'application Covoiturage

## Description
Ce projet Ansible déploie l'application Covoiturage (PHP/MySQL) avec Apache2 sur des serveurs Ubuntu.

## Architecture
- **Serveur Web**: Apache2 avec PHP-FPM
- **Application**: PHP (Covoiturage)
- **Base de données**: MySQL

## Structure des rôles
- `common`: Dépendances communes et configuration de base
- `database`: Installation et configuration MySQL
- `appserver`: Installation PHP et déploiement de l'application
- `webserver`: Configuration Apache2

## Prérequis
- Ansible 2.9+
- Vagrant (pour les VMs de test)
- Python 3

## Configuration

### Variables
Les variables sont définies dans `group_vars/appservers.yml`.
Les données sensibles sont dans `group_vars/vault.yml` (chiffré avec Ansible Vault).

### Ansible Vault
Pour chiffrer le fichier vault :
```bash
ansible-vault encrypt group_vars/vault.yml
```

Pour éditer le fichier vault :
```bash
ansible-vault edit group_vars/vault.yml
```

## Déploiement

### 1. Démarrer les VMs Vagrant
```bash
vagrant up
```

### 2. Vérifier la connectivité
```bash
ansible appservers -m ping
```

### 3. Déployer l'application
Avec vault password prompt :
```bash
ansible-playbook webapp_deploy.yml --ask-vault-pass
```

Ou avec un fichier de mot de passe :
```bash
ansible-playbook webapp_deploy.yml --vault-password-file .vault_pass
```

### 4. Déploiement avec tags
Deploy uniquement la base de données :
```bash
ansible-playbook webapp_deploy.yml --tags database --ask-vault-pass
```

Deploy uniquement le serveur web :
```bash
ansible-playbook webapp_deploy.yml --tags webserver --ask-vault-pass
```

## Tags disponibles
- `common`: Tâches communes
- `database`: MySQL
- `appserver`: PHP et application
- `webserver`: Apache
- `install`: Tâches d'installation
- `config`: Tâches de configuration
- `deploy`: Déploiement de l'application
- `service`: Gestion des services
- `verify`: Vérification du déploiement
- `security`: Tâches de sécurité

## Accès à l'application
Après le déploiement, l'application est accessible sur :
- http://192.168.56.111 (app1)
- http://192.168.56.112 (app2)

Pour un accès via nom de domaine, ajoutez à `/etc/hosts` :
```
192.168.56.111 covoiturage.test
```

## Maintenance

### Vérifier les services
```bash
ansible appservers -m systemd -a "name=apache2 state=started" -b
ansible appservers -m systemd -a "name=mysql state=started" -b
ansible appservers -m systemd -a "name=php8.3-fpm state=started" -b
```

### Logs
- Apache: `/var/log/apache2/covoiturage_*.log`
- MySQL: `/var/log/mysql/error.log`
- PHP-FPM: `/var/log/php8.3-fpm.log`

## Bonnes pratiques implémentées
✅ Playbook léger et lisible
✅ Rôles clairs et modulaires
✅ Tâches bien organisées et documentées
✅ Tags fonctionnels pour déploiement sélectif
✅ Ansible Vault pour données sensibles
✅ Idempotence des tâches
✅ Handlers pour redémarrage des services
✅ Post-tasks de vérification
✅ Gestion des permissions et sécurité
