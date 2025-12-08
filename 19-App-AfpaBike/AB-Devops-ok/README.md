# AfpaBike - Variante DevOps (AB-Devops-ok)

Objectif : obtenir une stack Docker propre (web + MySQL) sans corriger le code applicatif. Les problèmes purement Dev sont listés mais non traités.

## ✅ Vérification DevOps approfondie effectuée

### Infrastructure Docker (✅ Validée)

**docker-compose.yml** :
- ✅ Version 3.9, services db/web avec noms de conteneurs explicites
- ✅ Healthcheck MySQL : `mysqladmin ping` (interval 10s, 5 retries, start_period 20s)
- ✅ Dépendance `service_healthy` : web attend db fonctionnelle
- ✅ Volume nommé `db-data` : persistance MySQL correcte
- ✅ Bind mounts : `./web:/var/www/html`, `./modules:/var/www/html/modules`, `./files:/var/www/html/files`
- ✅ Init SQL via `docker-entrypoint-initdb.d` : 01-schema.sql + 02-grants.sql (ordre respecté)
- ✅ Ports exposés : 1234 (web), 3306 (db)
- ✅ Env file `.env` : credentials centralisés

**Dockerfile** :
- ✅ Base image : `php:8.2-apache` (version stable)
- ✅ Extensions MySQL : `pdo_mysql` + `mysqli` installées et activées
- ✅ Apache mod_rewrite : activé pour URL rewriting
- ✅ Outils utiles : nano, vim, dos2unix, mysql-client
- ✅ Copie du code : web/, modules/, files/ dans `/var/www/html`
- ✅ Nettoyage EOL : dos2unix sur scripts .sh
- ✅ Permissions : `chown www-data:www-data` sur document root

**Fichiers SQL** :
- ✅ Crebas_AfpaBike_v1-1_with_values.sql (23KB) : schema + 20 INSERT
- ✅ grant_bdd.sql : GRANT ALL sur gestion_afpabike_db pour user afpabike
- ✅ Compatibilité : pas de CREATE DATABASE (géré par MYSQL_DATABASE)

**Configuration Apache** :
- ✅ .htaccess présent : RewriteEngine on, règles de routing vers route.php
- ✅ Mod rewrite activé dans Dockerfile : compatibilité assurée

### ⚠️ Point d'attention : Redondance COPY + Bind mounts

Le Dockerfile effectue des `COPY` du code source dans l'image :
```dockerfile
COPY ./web/ /var/www/html/
COPY ./modules/ /var/www/html/modules/
COPY ./files/ /var/www/html/files/
```

Le docker-compose.yml monte ensuite ces mêmes répertoires en bind mounts :
```yaml
volumes:
  - ./web:/var/www/html
  - ./modules:/var/www/html/modules
  - ./files:/var/www/html/files
```

**Conséquence** : Les bind mounts **écrasent** le contenu copié dans l'image au démarrage du conteneur. Les `COPY` sont donc inutiles mais **sans impact négatif** (le code est bien présent via les bind mounts).

**Avantage** : Modification du code en temps réel sans rebuild (développement).
**Inconvénient** : L'image seule ne contient pas le code fonctionnel (dépendance au bind mount).

**Recommandation pour production** : Supprimer les bind mounts et garder uniquement les `COPY` dans le Dockerfile pour une image autonome.

## Contenu
- `docker-compose.yml` : stack complète avec healthcheck, dépendances, init SQL
- `Dockerfile` : PHP 8.2 Apache optimisé avec extensions MySQL
- `.env` : credentials MySQL (dev)
- Code applicatif : monté via bind mounts (dev) ou copié (image)

## Lancement rapide
```bash
cd 19-App-AfpaBike/AB-Devops-ok
docker compose up -d
```
- Web : http://localhost:1234
- MySQL : localhost:3306 (user/pass dans `.env`)

## Points Dev non corrigés (à traiter par les devs)
- Vérifier/assainir les accès BDD dans le code PHP (connexion, gestion d'erreurs, injections SQL possibles)
- Harmoniser les chemins et includes PHP (config_afpabike_dev.ini contient des chemins Windows)
- Revoir la configuration des sessions/authentification
- Nettoyer les assets doublons (nombreux fichiers JS/CSS dupliqués)
- Mettre en place un chargement de config unique compatible Docker

## Notes techniques
- Réseau : bridge Docker par défaut (external network supprimé)
- Volumes anonymes `/var/www/...` supprimés (conflits avec bind mounts)
- SQL init : `docker-entrypoint-initdb.d` exécuté uniquement au premier démarrage
