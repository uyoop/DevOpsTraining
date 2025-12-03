# Guide de Déploiement - Application Covoiturage

## Vue d'ensemble

Ce guide vous accompagne dans le déploiement de l'application Covoiturage utilisant :
- **Apache2** comme serveur web
- **PHP 8.3** avec PHP-FPM pour l'application
- **MySQL** pour la base de données

## Prérequis

### Logiciels nécessaires
- Ansible 2.9 ou supérieur
- Vagrant
- VirtualBox
- Python 3

### Vérification des installations
```bash
ansible --version
vagrant --version
```

## Étape 1 : Préparation de l'environnement

### 1.1 Cloner/Accéder au projet
```bash
cd /home/cj/gitdata/TP-Ansible/TP-Ansible-2-1-web_app_deployment
```

### 1.2 Vérifier la structure
```bash
tree -L 2
```

Structure attendue :
```
├── ansible.cfg
├── inventory.ini
├── Vagrantfile
├── webapp_deploy.yml
├── group_vars/
│   ├── appservers.yml
│   └── vault.yml
├── roles/
│   ├── common/
│   ├── database/
│   ├── appserver/
│   └── webserver/
└── Covoiturage/
    ├── index.php
    ├── db.php
    ├── schema.sql
    └── style.css
```

## Étape 2 : Configuration de la sécurité

### 2.1 Chiffrer les données sensibles avec Ansible Vault

Le fichier `group_vars/vault.yml` contient le mot de passe de la base de données.

**Option 1 : Utiliser le script fourni**
```bash
./setup_vault.sh
```

**Option 2 : Manuellement**
```bash
# Chiffrer le fichier vault
ansible-vault encrypt group_vars/vault.yml

# Vous serez invité à créer un mot de passe vault
# CONSERVEZ CE MOT DE PASSE EN LIEU SÛR !
```

### 2.2 Modifier les variables (optionnel)
```bash
# Éditer le vault pour changer le mot de passe DB
ansible-vault edit group_vars/vault.yml

# Éditer les autres variables
nano group_vars/appservers.yml
```

## Étape 3 : Déploiement des VMs

### 3.1 Démarrer les machines virtuelles
```bash
vagrant up
```

Cela va créer deux VMs :
- **app1** : 192.168.56.111
- **app2** : 192.168.56.112

### 3.2 Vérifier le statut des VMs
```bash
vagrant status
```

### 3.3 Tester la connectivité SSH
```bash
vagrant ssh app1  # Test manuel
exit
vagrant ssh app2
exit
```

## Étape 4 : Test de connectivité Ansible

### 4.1 Ping test
```bash
ansible appservers -m ping
```

Résultat attendu :
```
app1 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
app2 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```

### 4.2 Test complet de connectivité
```bash
# Avec Makefile
make test

# Ou directement
ansible-playbook test_connectivity.yml
```

## Étape 5 : Déploiement de l'application

### 5.1 Déploiement complet
```bash
# Avec Makefile
make deploy

# Ou directement
ansible-playbook webapp_deploy.yml --ask-vault-pass
```

Vous serez invité à entrer le mot de passe du vault.

### 5.2 Déploiement par composant (optionnel)

**Base de données uniquement :**
```bash
make deploy-db
# ou
ansible-playbook webapp_deploy.yml --tags database --ask-vault-pass
```

**Application uniquement :**
```bash
make deploy-app
# ou
ansible-playbook webapp_deploy.yml --tags appserver --ask-vault-pass
```

**Serveur web uniquement :**
```bash
make deploy-web
# ou
ansible-playbook webapp_deploy.yml --tags webserver --ask-vault-pass
```

### 5.3 Mode verbeux (pour debug)
```bash
ansible-playbook webapp_deploy.yml --ask-vault-pass -vvv
```

## Étape 6 : Vérification du déploiement

### 6.1 Vérification automatique
```bash
# Avec Makefile
make verify

# Ou directement
ansible-playbook verify_deployment.yml --ask-vault-pass
```

### 6.2 Vérification manuelle des services
```bash
ansible appservers -m systemd -a "name=apache2 state=started" -b
ansible appservers -m systemd -a "name=mysql state=started" -b
ansible appservers -m systemd -a "name=php8.3-fpm state=started" -b
```

### 6.3 Test HTTP
```bash
curl http://192.168.56.111
curl http://192.168.56.112
```

## Étape 7 : Accès à l'application

### 7.1 Configuration du fichier hosts (optionnel)
```bash
sudo nano /etc/hosts
```

Ajouter :
```
192.168.56.111 covoiturage.test
192.168.56.112 covoiturage2.test
```

### 7.2 Accès via navigateur
Ouvrir dans votre navigateur :
- http://192.168.56.111
- http://covoiturage.test (si configuré)

## Étape 8 : Maintenance

### 8.1 Consulter les logs

**Sur les VMs via SSH :**
```bash
vagrant ssh app1
sudo tail -f /var/log/apache2/covoiturage_error.log
sudo tail -f /var/log/mysql/error.log
sudo tail -f /var/log/php8.3-fpm.log
```

**Via Ansible :**
```bash
ansible appservers -m shell -a "tail -n 20 /var/log/apache2/covoiturage_access.log" -b
```

### 8.2 Redémarrer les services
```bash
ansible appservers -m systemd -a "name=apache2 state=restarted" -b
ansible appservers -m systemd -a "name=mysql state=restarted" -b
```

### 8.3 Re-déployer après modification
```bash
# Tout re-déployer
ansible-playbook webapp_deploy.yml --ask-vault-pass

# Juste l'application
ansible-playbook webapp_deploy.yml --tags appserver --ask-vault-pass
```

## Étape 9 : Nettoyage

### 9.1 Arrêter les VMs
```bash
vagrant halt
```

### 9.2 Détruire les VMs
```bash
# Avec Makefile
make clean

# Ou directement
vagrant destroy -f
```

## Dépannage

### Problème : Ansible ne peut pas se connecter aux VMs
```bash
# Vérifier que les VMs sont démarrées
vagrant status

# Vérifier la clé SSH
ls -la ~/.vagrant.d/insecure_private_key

# Tester SSH manuellement
ssh -i ~/.vagrant.d/insecure_private_key vagrant@192.168.56.111
```

### Problème : Erreur de mot de passe vault
```bash
# Vérifier que le vault est chiffré
head group_vars/vault.yml
# Devrait afficher : $ANSIBLE_VAULT;1.1;AES256

# Si pas chiffré
ansible-vault encrypt group_vars/vault.yml
```

### Problème : PHP 8.3 non trouvé
Le playbook utilise PHP 8.3 (disponible sur Ubuntu 24.04). Si vous utilisez une version plus ancienne d'Ubuntu, modifiez les références à `php8.3-fpm` par la version disponible.

### Problème : Apache ne démarre pas
```bash
# Se connecter à la VM
vagrant ssh app1

# Vérifier les erreurs Apache
sudo systemctl status apache2
sudo apache2ctl configtest
sudo journalctl -xeu apache2
```

## Commandes utiles

### Makefile (recommandé)
```bash
make help        # Liste toutes les commandes
make setup       # Démarrer les VMs
make test        # Tester la connectivité
make deploy      # Déployer l'application
make verify      # Vérifier le déploiement
make clean       # Détruire les VMs
```

### Ansible Vault
```bash
ansible-vault encrypt <file>           # Chiffrer un fichier
ansible-vault decrypt <file>           # Déchiffrer un fichier
ansible-vault edit <file>              # Éditer un fichier chiffré
ansible-vault rekey <file>             # Changer le mot de passe
ansible-vault view <file>              # Voir le contenu sans éditer
```

### Vagrant
```bash
vagrant up                # Démarrer les VMs
vagrant halt              # Arrêter les VMs
vagrant reload            # Redémarrer les VMs
vagrant ssh <vm>          # Se connecter à une VM
vagrant destroy -f        # Détruire les VMs
vagrant status            # Voir le statut
```

## Architecture finale

Après le déploiement, chaque VM dispose de :

1. **Services système (common)**
   - Git, curl, wget
   - Timezone configurée
   
2. **Base de données (database)**
   - MySQL Server
   - Database `covoit` créée
   - User `covoit_user` configuré
   - Schéma importé (tables trips, reservations)

3. **Application (appserver)**
   - PHP 8.3 + PHP-FPM
   - Modules PHP (mysql, mbstring, xml, curl)
   - Application Covoiturage déployée dans `/var/www/covoiturage`
   - Configuration DB sécurisée

4. **Serveur web (webserver)**
   - Apache2
   - Virtual host configuré
   - Modules activés (rewrite, proxy_fcgi, ssl)
   - Integration PHP-FPM

## Bonnes pratiques implémentées

✅ **Playbook**
- Structure claire et lisible
- Rôles modulaires et réutilisables
- Pre-tasks et post-tasks pour validation

✅ **Rôles**
- Séparation claire des responsabilités
- Handlers pour redémarrage des services
- Meta-data complètes

✅ **Tâches**
- Nommage explicite
- Tags fonctionnels
- Idempotence respectée

✅ **Sécurité**
- Ansible Vault pour données sensibles
- Permissions correctes (0640 pour db.php)
- Pas de mots de passe en clair

✅ **Tags**
- Par composant : common, database, appserver, webserver
- Par action : install, config, deploy, service
- Par fonction : verify, security

✅ **Documentation**
- README complet
- Guide de déploiement détaillé
- Commentaires dans le code

## Support

Pour toute question ou problème, consulter :
- Les logs sur les VMs
- La documentation Ansible : https://docs.ansible.com
- Les erreurs dans les playbooks avec `-vvv`
