# RÉSUMÉ DES MODIFICATIONS - Application Covoiturage

## Objectif
Transformer le projet d'un déploiement Flask/Nginx vers un déploiement PHP/Apache avec MySQL pour l'application Covoiturage.

## Modifications effectuées

### 1. Structure des rôles créée/modifiée

#### ✅ Rôle `common` (amélioré)
- Ajout de dépendances système supplémentaires
- Configuration du timezone Europe/Paris
- Tags ajoutés pour granularité

#### ✅ Rôle `database` (nouveau)
**Créé de zéro**
- `tasks/main.yml` - Installation MySQL, création DB, import schéma
- `handlers/main.yml` - Restart MySQL
- `meta/main.yml` - Métadonnées
- Tags : database, install, service, config, schema, security, cleanup

#### ✅ Rôle `appserver` (nouveau)
**Créé de zéro**
- `tasks/main.yml` - Installation PHP 8.3, déploiement application
- `handlers/main.yml` - Restart PHP-FPM
- `templates/db.php.j2` - Configuration DB depuis template
- `meta/main.yml` - Métadonnées
- Tags : appserver, install, php, service, config, deploy, security

#### ✅ Rôle `webserver` (transformé)
**Remplacé complètement Nginx/Flask par Apache/PHP**
- `tasks/main.yml` - Installation Apache, configuration virtual host
- `handlers/main.yml` - Restart/Reload Apache
- `templates/apache_site.j2` - Virtual host Apache (remplace nginx_site.j2)
- `templates/flask_service.j2` - **SUPPRIMÉ** (non utilisé)
- `meta/main.yml` - Métadonnées
- Tags : webserver, install, config, service

### 2. Configuration et variables

#### ✅ `group_vars/appservers.yml` (modifié)
**Avant** :
```yaml
app:
  user: flask
  repo_url: "https://github.com/..."
  service_name: "flask_covoiturage"
```

**Après** :
```yaml
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
```

#### ✅ `group_vars/vault.yml` (créé)
**Nouveau fichier** pour sécuriser les credentials :
```yaml
vault_db_password: "SecurePassword123!"
```
À chiffrer avec : `ansible-vault encrypt group_vars/vault.yml`

### 3. Playbooks

#### ✅ `webapp_deploy.yml` (réécrit)
**Modifications majeures** :
- Nom du play mis à jour (PHP au lieu de Flask)
- Ordre des rôles : common → database → appserver → webserver
- Tags ajoutés sur chaque rôle
- Post-tasks modifiés : vérifie Apache, MySQL, PHP-FPM (au lieu de Flask/Nginx)
- Message de succès final

#### ✅ `test_connectivity.yml` (créé)
**Nouveau playbook** pour tester la connectivité Ansible
- Ping test
- Affichage informations serveur

#### ✅ `verify_deployment.yml` (créé)
**Nouveau playbook** pour vérifier le déploiement
- Vérification statut services (Apache, MySQL, PHP-FPM)
- Vérification présence fichiers application
- Vérification base de données
- Test HTTP
- Résumé final

### 4. Fichiers de support

#### ✅ `Makefile` (créé)
Commandes pratiques :
- `make setup` - Démarrer VMs
- `make test` - Test connectivité
- `make deploy` - Déploiement complet
- `make deploy-db/app/web` - Déploiement sélectif
- `make verify` - Vérification
- `make vault-encrypt/edit` - Gestion vault
- `make clean` - Nettoyage

#### ✅ `setup_vault.sh` (créé)
Script interactif pour configurer Ansible Vault

#### ✅ `README.md` (créé)
Documentation générale du projet avec :
- Description architecture
- Structure rôles
- Instructions déploiement
- Tags disponibles
- Bonnes pratiques implémentées

#### ✅ `GUIDE_DEPLOIEMENT.md` (créé)
Guide pas à pas détaillé avec :
- Étapes de préparation
- Configuration sécurité (Vault)
- Déploiement complet
- Vérification
- Maintenance
- Dépannage

#### ✅ `ROLES_DOCUMENTATION.md` (créé)
Documentation technique complète des rôles avec :
- Description détaillée de chaque rôle
- Variables utilisées
- Tags disponibles
- Structure fichiers
- Ordre d'exécution
- Handlers
- Bonnes pratiques

### 5. Fichiers non modifiés

#### ⚪ `ansible.cfg`
Conservé tel quel - Configuration correcte

#### ⚪ `inventory.ini`
Conservé tel quel - Inventory correct

#### ⚪ `Vagrantfile`
Conservé tel quel - Configuration VMs correcte (Ubuntu 24.04)

#### ⚪ `Covoiturage/*`
Fichiers sources application conservés :
- `index.php` - Interface principale
- `db.php` - Configuration DB (remplacé par template)
- `schema.sql` - Schéma base de données
- `style.css` - Feuille de style

## Stack technique

### Avant (initial)
- **Web Server** : Nginx
- **Application** : Flask (Python)
- **Framework** : Gunicorn + WSGI
- **Déploiement** : Via Git clone

### Après (modifié)
- **Web Server** : Apache2
- **Application** : PHP 8.3 (Covoiturage)
- **Runtime** : PHP-FPM via socket Unix
- **Base de données** : MySQL
- **Déploiement** : Copie directe depuis dossier Covoiturage

## Bonnes pratiques Ansible implémentées

### ✅ Playbook léger et lisible
- Structure claire avec pre_tasks, roles, post_tasks
- Commentaires explicites
- Tags fonctionnels
- Séparation rôles/playbook

### ✅ Rôles clairs et lisibles
- Séparation responsabilités : common, database, appserver, webserver
- Structure standard : tasks, handlers, templates, meta
- Nommage explicite des tâches
- Documentation intégrée

### ✅ Tâches fonctionnelles et lisibles
- Une tâche = une action claire
- Utilisation modules Ansible (apt, systemd, mysql_db, etc.)
- Éviter shell/command quand module existe
- Register pour capture résultats
- changed_when et failed_when pour contrôle

### ✅ Tags utiles et fonctionnels
**Par composant** : common, database, appserver, webserver
**Par action** : install, config, deploy, service
**Par fonction** : verify, security, cleanup
**Spéciaux** : always (pre_tasks)

### ✅ Ansible Vault pour sécurité
- Fichier `group_vars/vault.yml` pour credentials
- Variable `vault_db_password` protégée
- Script `setup_vault.sh` pour faciliter usage
- Fichier db.php avec permissions 0640
- Option no_log sur opérations sensibles

### ✅ Autres bonnes pratiques
- **Idempotence** : Toutes les tâches sont idempotentes
- **Handlers** : Redémarrages via handlers (pas inline)
- **Variables** : Centralisées dans group_vars
- **Templates** : Configuration dynamique (db.php.j2, apache_site.j2)
- **Vérifications** : Post-tasks vérifient déploiement
- **Documentation** : README, guides, commentaires
- **Tests** : Playbooks de test et vérification

## Commandes principales

### Préparation
```bash
# Démarrer VMs
vagrant up

# Chiffrer vault
ansible-vault encrypt group_vars/vault.yml
```

### Déploiement
```bash
# Complet
ansible-playbook webapp_deploy.yml --ask-vault-pass

# Par composant
ansible-playbook webapp_deploy.yml --tags database --ask-vault-pass
ansible-playbook webapp_deploy.yml --tags appserver --ask-vault-pass
ansible-playbook webapp_deploy.yml --tags webserver --ask-vault-pass
```

### Vérification
```bash
# Test connectivité
ansible-playbook test_connectivity.yml

# Vérification déploiement
ansible-playbook verify_deployment.yml --ask-vault-pass
```

### Avec Makefile
```bash
make setup    # Démarrer VMs
make test     # Test connectivité
make deploy   # Déploiement complet
make verify   # Vérification
make clean    # Nettoyage
```

## Structure finale du projet

```
TP-Ansible-2-1-web_app_deployment/
├── ansible.cfg                    # Configuration Ansible
├── inventory.ini                  # Inventory des serveurs
├── Vagrantfile                    # Configuration VMs
├── webapp_deploy.yml              # Playbook principal ⭐
├── test_connectivity.yml          # Test connectivité ⭐
├── verify_deployment.yml          # Vérification déploiement ⭐
├── Makefile                       # Commandes utiles ⭐
├── setup_vault.sh                 # Script Vault ⭐
├── README.md                      # Documentation générale ⭐
├── GUIDE_DEPLOIEMENT.md           # Guide pas à pas ⭐
├── ROLES_DOCUMENTATION.md         # Doc technique rôles ⭐
│
├── group_vars/
│   ├── appservers.yml             # Variables application/DB
│   └── vault.yml                  # Credentials (à chiffrer) ⭐
│
├── Covoiturage/                   # Application PHP
│   ├── index.php
│   ├── db.php
│   ├── schema.sql
│   └── style.css
│
└── roles/
    ├── common/                    # Rôle configuration base
    │   ├── tasks/main.yml
    │   ├── handlers/main.yml
    │   └── meta/main.yml
    │
    ├── database/                  # Rôle MySQL ⭐
    │   ├── tasks/main.yml
    │   ├── handlers/main.yml
    │   ├── templates/
    │   └── meta/main.yml
    │
    ├── appserver/                 # Rôle PHP/Application ⭐
    │   ├── tasks/main.yml
    │   ├── handlers/main.yml
    │   ├── templates/db.php.j2    ⭐
    │   └── meta/main.yml
    │
    └── webserver/                 # Rôle Apache ⭐
        ├── tasks/main.yml         # Modifié complètement
        ├── handlers/main.yml      # Modifié
        ├── templates/
        │   └── apache_site.j2     ⭐ (remplace nginx_site.j2)
        └── meta/main.yml

⭐ = Nouveau ou modifié significativement
```

## Tags disponibles - Résumé

| Tag | Portée | Usage |
|-----|--------|-------|
| `common` | Rôle common | `--tags common` |
| `database` | Rôle database | `--tags database` |
| `appserver` | Rôle appserver | `--tags appserver` |
| `webserver` | Rôle webserver | `--tags webserver` |
| `install` | Installation paquets | `--tags install` |
| `config` | Configuration | `--tags config` |
| `deploy` | Déploiement app | `--tags deploy` |
| `service` | Gestion services | `--tags service` |
| `verify` | Vérifications | `--tags verify` |
| `security` | Opérations sensibles | `--tags security` |
| `schema` | Import schéma DB | `--tags schema` |
| `cleanup` | Nettoyage | `--tags cleanup` |
| `php` | Spécifique PHP | `--tags php` |

## Résultat final

Après déploiement, chaque VM dispose de :
- ✅ MySQL avec base `covoit` et tables `trips`, `reservations`
- ✅ PHP 8.3 + PHP-FPM configuré
- ✅ Application Covoiturage déployée dans `/var/www/covoiturage`
- ✅ Apache2 avec virtual host configuré
- ✅ Services démarrés et activés au boot
- ✅ Application accessible sur http://192.168.56.111 et http://192.168.56.112

## Prochaines étapes (optionnel)

### Améliorations possibles
1. **SSL/HTTPS** : Ajouter certificats Let's Encrypt
2. **Load Balancer** : Ajouter HAProxy devant les 2 VMs
3. **Monitoring** : Ajouter role pour Prometheus/Grafana
4. **Backup** : Script backup automatique MySQL
5. **CI/CD** : Pipeline GitLab/GitHub Actions
6. **Firewall** : Configuration UFW
7. **Logs** : Centralisation avec ELK stack

### Tests avancés
1. **Molecule** : Tests automatisés des rôles
2. **Ansible Lint** : Vérification qualité code
3. **ServerSpec** : Tests infrastructure
4. **Load Testing** : Tests performance avec Apache Bench

## Validation finale

### Checklist
- [x] Rôles créés et configurés
- [x] Variables définies et sécurisées (Vault)
- [x] Playbooks fonctionnels et testés (syntax-check)
- [x] Tags implémentés et cohérents
- [x] Handlers configurés
- [x] Templates créés (db.php.j2, apache_site.j2)
- [x] Documentation complète (README, guides)
- [x] Scripts utilitaires (Makefile, setup_vault.sh)
- [x] Bonnes pratiques Ansible respectées
- [x] Sécurité implémentée (Vault, permissions)

### Pour tester
```bash
# 1. Démarrer VMs
make setup

# 2. Tester connectivité
make test

# 3. Chiffrer vault
ansible-vault encrypt group_vars/vault.yml

# 4. Déployer
make deploy

# 5. Vérifier
make verify

# 6. Accéder
curl http://192.168.56.111
```

---

**Date de création** : 27 novembre 2025
**Statut** : ✅ Complet et prêt à déployer
**Conformité** : Bonnes pratiques Ansible respectées
