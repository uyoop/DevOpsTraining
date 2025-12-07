# UyoopApp

Application minimale (PHP + JS + CSS) pour le recueil de besoins et la génération automatique d'un cahier des charges.

## Structure
- `public/index.php` — page principale et mini-routeur
- `public/admin.php` — page d'administration pour consulter les formulaires
- `public/assets/style.css` — styles responsives
- `public/assets/app.js` — formulaire intelligent (sections conditionnelles) + aperçu
- `src/api_save.php` — enregistrement des données via PDO/SQLite
- `src/generate.php` — génération HTML du cahier des charges
- `src/db.php` — helper de connexion PDO SQLite
- `data/` — répertoire pour la base de données SQLite

## Pré-requis
- PHP 8.4+
- Extension PHP : `php-sqlite3`

### Installation de l'extension SQLite
```bash
sudo apt install -y php8.4-sqlite3
```

## Lancer en local

```bash
cd public
php -S localhost:8080
```

Ouvrir :
- **Formulaire** : `http://localhost:8080`
- **Administration** : `http://localhost:8080/admin.php`

## Déploiement
- Nginx/Apache: pointer le root sur `public/`.
- PHP-FPM recommandé.
- S'assurer que le dossier `data/` est accessible en écriture par le serveur web.

## Fonctionnalités
- Formulaire intelligent : sections conditionnelles selon le type de projet
- Génération automatique d'un cahier des charges en HTML
- Enregistrement des données en base SQLite
- Page d'administration pour consulter tous les formulaires complétés
- Styles modernes, responsive, branding Uyoop

## Notes
- Le formulaire affiche des champs selon `Type de projet`.
- Le bouton "Prévisualiser" rend le cahier des charges en HTML.
- Le bouton "Enregistrer & Générer" tente d'insérer en base et fournit un lien de téléchargement `/generate?id=...`.
