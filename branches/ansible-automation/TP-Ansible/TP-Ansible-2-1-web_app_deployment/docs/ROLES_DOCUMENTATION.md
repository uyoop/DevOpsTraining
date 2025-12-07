# Documentation des Rôles Ansible

## Vue d'ensemble

Ce projet utilise 4 rôles Ansible pour déployer l'application Covoiturage :

1. **common** - Configuration de base commune
2. **database** - Installation et configuration MySQL
3. **appserver** - Installation PHP et déploiement application
4. **webserver** - Configuration Apache

## Rôle : common

### Description
Configure les dépendances système communes et les paramètres de base sur tous les serveurs.

### Responsabilités
- Mise à jour du cache APT
- Installation des outils de base (git, curl, wget)
- Configuration du timezone

### Variables utilisées
Aucune variable spécifique

### Tags disponibles
- `common` - Toutes les tâches du rôle
- `install` - Installation des paquets
- `config` - Configuration système

### Fichiers
```
common/
├── tasks/
│   └── main.yml          # Tâches principales
├── handlers/
│   └── main.yml          # Handlers (reload systemd)
└── meta/
    └── main.yml          # Métadonnées du rôle
```

### Dépendances
Aucune

---

## Rôle : database

### Description
Installe et configure MySQL Server, crée la base de données et importe le schéma.

### Responsabilités
- Installation MySQL Server et python3-pymysql
- Démarrage et activation du service MySQL
- Création de la base de données `covoit`
- Création de l'utilisateur MySQL
- Import du schéma SQL (tables trips et reservations)

### Variables utilisées
Définies dans `group_vars/appservers.yml` et `group_vars/vault.yml` :
```yaml
db:
  host: localhost
  name: covoit
  user: covoit_user
  password: "{{ vault_db_password }}"  # Depuis vault.yml
```

### Tags disponibles
- `database` - Toutes les tâches du rôle
- `install` - Installation de MySQL
- `service` - Gestion du service
- `config` - Configuration de la base
- `schema` - Import du schéma
- `security` - Création utilisateur (sensible)
- `cleanup` - Nettoyage fichiers temporaires

### Fichiers
```
database/
├── tasks/
│   └── main.yml          # Installation MySQL et import schéma
├── handlers/
│   └── main.yml          # Restart MySQL
├── templates/
│   └── (vide pour l'instant)
└── meta/
    └── main.yml          # Métadonnées du rôle
```

### Fichiers sources requis
- `Covoiturage/schema.sql` - Schéma de la base de données

### Sécurité
- Le mot de passe DB est stocké dans Ansible Vault
- Connexion MySQL via socket Unix
- Option `no_log` pour les opérations sensibles

### Dépendances
Aucune

---

## Rôle : appserver

### Description
Installe PHP et déploie l'application Covoiturage.

### Responsabilités
- Installation de PHP 8.3 et modules requis
- Configuration PHP-FPM
- Création de l'utilisateur application
- Déploiement des fichiers de l'application
- Configuration de la connexion base de données

### Variables utilisées
```yaml
app:
  name: covoiturage
  user: webappuser
  install_path: /var/www/covoiturage

db:
  host: localhost
  name: covoit
  user: covoit_user
  password: "{{ vault_db_password }}"
```

### Tags disponibles
- `appserver` - Toutes les tâches du rôle
- `install` - Installation PHP et modules
- `php` - Spécifique à PHP
- `service` - Gestion PHP-FPM
- `config` - Configuration application
- `deploy` - Déploiement des fichiers
- `security` - Permissions et config DB

### Fichiers
```
appserver/
├── tasks/
│   └── main.yml          # Installation PHP et déploiement app
├── handlers/
│   └── main.yml          # Restart PHP-FPM
├── templates/
│   └── db.php.j2         # Template configuration DB
└── meta/
    └── main.yml          # Métadonnées du rôle
```

### Fichiers sources déployés
Depuis `Covoiturage/` :
- `index.php` - Interface principale
- `db.php` - Configuration DB (généré depuis template)
- `schema.sql` - Schéma (copié mais utilisé par database)
- `style.css` - Styles CSS

### Permissions
- Propriétaire : `{{ app.user }}` (webappuser)
- Groupe : `www-data`
- Répertoire app : `0755`
- Fichier db.php : `0640` (sensible)

### Sécurité
- Configuration DB générée depuis template (pas de credentials en dur)
- Permissions restrictives sur db.php
- Utilisateur système dédié

### Dépendances
- Rôle `database` (doit être exécuté avant)

---

## Rôle : webserver

### Description
Configure Apache2 comme serveur web avec support PHP-FPM.

### Responsabilités
- Installation Apache2
- Activation des modules Apache (rewrite, proxy_fcgi, ssl, headers)
- Configuration du virtual host
- Intégration avec PHP-FPM
- Gestion du site par défaut

### Variables utilisées
```yaml
app:
  name: covoiturage
  domain: covoiturage.test
  install_path: /var/www/covoiturage
```

### Tags disponibles
- `webserver` - Toutes les tâches du rôle
- `install` - Installation Apache
- `config` - Configuration Apache
- `service` - Gestion du service Apache

### Fichiers
```
webserver/
├── tasks/
│   └── main.yml          # Installation et configuration Apache
├── handlers/
│   └── main.yml          # Restart/Reload Apache
├── templates/
│   └── apache_site.j2    # Template virtual host Apache
└── meta/
    └── main.yml          # Métadonnées du rôle
```

### Configuration Apache
Le virtual host configuré :
- Port : 80
- DocumentRoot : `{{ app.install_path }}`
- ServerName : `{{ app.domain }}`
- DirectoryIndex : index.php
- PHP-FPM : Via socket Unix `/run/php/php8.3-fpm.sock`

### Modules Apache activés
- `rewrite` - Réécriture d'URL
- `proxy` - Support proxy
- `proxy_fcgi` - Proxy FastCGI pour PHP
- `ssl` - Support SSL (pour futur)
- `headers` - Manipulation headers HTTP

### Sites Apache
- Site par défaut : **désactivé**
- Site covoiturage : **activé**

### Sécurité
- AllowOverride All (pour .htaccess si nécessaire)
- Logs séparés par application

### Dépendances
- Rôle `appserver` (pour PHP-FPM)

---

## Ordre d'exécution des rôles

Le playbook `webapp_deploy.yml` exécute les rôles dans cet ordre :

```
1. pre_tasks
   └── Update apt cache

2. common
   └── Configuration système de base

3. database
   └── MySQL + création DB + import schéma

4. appserver
   └── PHP + déploiement application

5. webserver
   └── Apache + virtual host

6. post_tasks
   └── Vérifications (Apache, MySQL, PHP-FPM)
```

Cet ordre est **important** car :
- `database` doit être prêt avant `appserver` (pour la config DB)
- `appserver` (PHP-FPM) doit être prêt avant `webserver` (pour la config Apache)

## Handlers

### common
- `Reload systemd` - Recharge la configuration systemd

### database
- `Restart MySQL` - Redémarre le service MySQL

### appserver
- `Restart PHP-FPM` - Redémarre PHP-FPM

### webserver
- `Restart Apache` - Redémarre Apache2
- `Reload Apache` - Recharge la config Apache
- `Reload systemd` - Recharge systemd

## Variables globales

### Emplacement
- `group_vars/appservers.yml` - Variables non sensibles
- `group_vars/vault.yml` - Variables sensibles (chiffré)

### Structure
```yaml
# appservers.yml
app:
  name: covoiturage
  user: webappuser
  domain: covoiturage.test
  install_path: /var/www/covoiturage

db:
  host: localhost
  name: covoit
  user: covoit_user
  password: "{{ vault_db_password }}"

# vault.yml (chiffré)
vault_db_password: "SecurePassword123!"
```

## Utilisation des tags

### Déploiement complet
```bash
ansible-playbook webapp_deploy.yml --ask-vault-pass
```

### Par rôle
```bash
ansible-playbook webapp_deploy.yml --tags common --ask-vault-pass
ansible-playbook webapp_deploy.yml --tags database --ask-vault-pass
ansible-playbook webapp_deploy.yml --tags appserver --ask-vault-pass
ansible-playbook webapp_deploy.yml --tags webserver --ask-vault-pass
```

### Par action
```bash
ansible-playbook webapp_deploy.yml --tags install --ask-vault-pass
ansible-playbook webapp_deploy.yml --tags config --ask-vault-pass
ansible-playbook webapp_deploy.yml --tags deploy --ask-vault-pass
ansible-playbook webapp_deploy.yml --tags service --ask-vault-pass
```

### Vérification uniquement
```bash
ansible-playbook webapp_deploy.yml --tags verify --ask-vault-pass
```

### Combinaison de tags
```bash
# Déployer seulement DB et app (pas le web)
ansible-playbook webapp_deploy.yml --tags database,appserver --ask-vault-pass

# Configuration uniquement (pas d'installation)
ansible-playbook webapp_deploy.yml --tags config --ask-vault-pass
```

## Extension et personnalisation

### Ajouter un nouveau rôle

1. Créer la structure :
```bash
mkdir -p roles/nouveau_role/{tasks,handlers,templates,meta}
```

2. Créer les fichiers minimums :
```bash
touch roles/nouveau_role/tasks/main.yml
touch roles/nouveau_role/handlers/main.yml
touch roles/nouveau_role/meta/main.yml
```

3. Ajouter au playbook :
```yaml
roles:
  - role: nouveau_role
    tags: nouveau_role
```

### Modifier une configuration

1. **Variables** : Éditer `group_vars/appservers.yml`
2. **Secrets** : `ansible-vault edit group_vars/vault.yml`
3. **Templates** : Modifier les fichiers `.j2` dans `roles/*/templates/`
4. **Tâches** : Éditer `roles/*/tasks/main.yml`

### Bonnes pratiques

✅ **Faire**
- Utiliser des tags sur chaque tâche
- Nommer clairement chaque tâche
- Utiliser Ansible Vault pour les secrets
- Tester l'idempotence des tâches
- Documenter les variables requises
- Utiliser des handlers pour les redémarrages

❌ **Ne pas faire**
- Mettre des mots de passe en clair
- Utiliser `shell` quand un module existe
- Oublier les tags
- Négliger la documentation
- Ignorer les erreurs avec `ignore_errors` sans raison
- Hardcoder des valeurs configurables

## Troubleshooting

### Un rôle échoue

1. Vérifier avec mode verbeux :
```bash
ansible-playbook webapp_deploy.yml --tags problematic_role -vvv --ask-vault-pass
```

2. Vérifier les variables :
```bash
ansible appservers -m debug -a "var=app"
ansible appservers -m debug -a "var=db"
```

3. Exécuter une tâche manuellement :
```bash
ansible appservers -m apt -a "name=apache2 state=present" -b
```

### Handler ne se déclenche pas

- Les handlers s'exécutent à la fin du play
- Utilisez `meta: flush_handlers` pour forcer l'exécution immédiate
- Vérifiez que le nom du handler correspond exactement

### Problème de permissions

```bash
# Vérifier sur la VM
ansible appservers -m shell -a "ls -la /var/www/covoiturage" -b
ansible appservers -m shell -a "id webappuser" -b
```

## Ressources

- [Ansible Best Practices](https://docs.ansible.com/ansible/latest/user_guide/playbooks_best_practices.html)
- [Ansible Vault](https://docs.ansible.com/ansible/latest/user_guide/vault.html)
- [Ansible Roles](https://docs.ansible.com/ansible/latest/user_guide/playbooks_reuse_roles.html)
- [Ansible Tags](https://docs.ansible.com/ansible/latest/user_guide/playbooks_tags.html)
