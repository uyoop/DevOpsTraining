# TP19 - AfpaBike

Organisation des livrables pour l'application AfpaBike.

## Dossiers
- `AB-projet-base/` : sources d'origine fournies (application non fonctionnelle, conteneurisation initiale).
- `AB-Devops-ok/` : copie de base avec corrections DevOps uniquement (build et run viables, application non corrigée côté code).
- `AB-App-ok/` : copie de base destinée aux corrections complètes (Dev + DevOps) pour rendre l'application fonctionnelle et optimisée.

## Branche Git
- Branche de travail : `docker` (changements commités et poussés).

## Actions menées
- ✅ Extraction de l'archive initiale dans `AB-projet-base/` (code source original non modifié).
- ✅ Duplication en `AB-Devops-ok/` et refonte complète de la stack Docker (healthcheck, service_healthy, named volumes, SQL init, .env).
- ✅ Vérification approfondie DevOps sur `AB-Devops-ok/` : infrastructure validée et documentée.
- ✅ Duplication en `AB-App-ok/` avec corrections DevOps + Dev appliquées.
- ✅ Fix configuration applicative : `config_afpabike_dev.ini` adapté pour Docker Linux (PATH_HOME, PATH_CLASS, DB config).
- ✅ Documentation complète des trois variantes avec READMEs détaillés.
- ✅ Commits et push effectués sur branche `docker`.

## État actuel
**AB-projet-base** : Archive originale préservée (référence).
**AB-Devops-ok** : Infrastructure Docker optimisée ✅ fonctionnelle (code app non corrigé intentionnellement).
**AB-App-ok** : Corrections DevOps + Dev appliquées ✅ prêt pour déploiement.

## Démarrage rapide
```bash
# Infrastructure seule (DevOps)
cd 19-App-AfpaBike/AB-Devops-ok
docker compose up -d

# Application complète (DevOps + Dev)
cd 19-App-AfpaBike/AB-App-ok
docker compose up -d
```

Accès web : http://localhost:1234
