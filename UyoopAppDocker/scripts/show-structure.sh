#!/bin/bash
# Script d'affichage de la structure du projet

cat << 'EOF'
╔══════════════════════════════════════════════════════════════╗
║              🚀 UYOOP APP - STRUCTURE DU PROJET              ║
╚══════════════════════════════════════════════════════════════╝

📦 UyoopAppDocker/
│
├── 🐳 CONTENEURISATION DOCKER
│   ├── Dockerfile                    # Image PHP 8.4-FPM + SQLite
│   ├── docker-compose.yml            # Config développement
│   ├── docker-compose.prod.yml       # Config production
│   ├── nginx.conf                    # Serveur web Nginx
│   ├── healthcheck.sh               # Vérification santé conteneur
│   ├── .dockerignore                # Exclusions build Docker
│   └── .env.example                 # Variables d'environnement
│
├── 🚀 SCRIPTS DE DÉPLOIEMENT
│   ├── deploy.sh                    # Déploiement automatique
│   ├── test.sh                      # Suite de tests
│   └── Makefile                     # Commandes simplifiées (make help)
│
├── 🤖 AUTOMATISATION ANSIBLE
│   └── ansible/
│       ├── deploy.yml               # Playbook déploiement serveur
│       ├── inventory.ini            # Inventaire serveurs
│       ├── ansible.cfg              # Configuration Ansible
│       └── README.md                # Guide Ansible
│
├── 📱 APPLICATION PHP
│   ├── public/                      # Racine web
│   │   ├── index.php               # Page principale + routeur
│   │   ├── admin.php               # Administration
│   │   └── assets/
│   │       ├── app.js              # JavaScript
│   │       ├── style.css           # CSS
│   │       └── uyoop-logo.png      # Logo
│   │
│   └── src/                        # Backend PHP
│       ├── db.php                  # Connexion SQLite
│       ├── api_save.php            # API sauvegarde
│       └── generate.php            # Génération cahier charges
│
├── 💾 DONNÉES
│   └── data/                       # Base de données (créée auto)
│       └── uyoop.db               # SQLite
│
└── 📚 DOCUMENTATION
    ├── README.md                   # Guide principal
    ├── QUICKSTART.md              # Démarrage rapide
    ├── DOCKER.md                  # Documentation Docker complète
    ├── ARCHITECTURE.md            # Architecture technique
    ├── CHANGELOG.md               # Historique des versions
    └── .gitignore                 # Exclusions Git

╔══════════════════════════════════════════════════════════════╗
║                    🎯 COMMANDES PRINCIPALES                   ║
╚══════════════════════════════════════════════════════════════╝

  📋 Voir toutes les commandes
     $ make help

  🚀 Installation première fois
     $ make install

  ▶️  Démarrer l'application
     $ make up

  📊 Voir les logs
     $ make logs

  📈 Statut des conteneurs
     $ make status

  💾 Backup base de données
     $ make backup

  🧪 Lancer les tests
     $ make test

  🔄 Redémarrer
     $ make restart

  ⏹️  Arrêter
     $ make down

╔══════════════════════════════════════════════════════════════╗
║                      🌐 ACCÈS APPLICATION                     ║
╚══════════════════════════════════════════════════════════════╝

  🏠 Page principale
     → http://localhost:8080

  ⚙️  Administration
     → http://localhost:8080/admin.php

╔══════════════════════════════════════════════════════════════╗
║                    📖 GUIDES DISPONIBLES                      ║
╚══════════════════════════════════════════════════════════════╝

  • QUICKSTART.md    - Démarrage en 3 commandes
  • README.md        - Documentation complète
  • DOCKER.md        - Guide Docker détaillé
  • ARCHITECTURE.md  - Architecture technique
  • ansible/README.md - Déploiement automatisé

╔══════════════════════════════════════════════════════════════╗
║                   🎓 PROCHAINES ÉTAPES                        ║
╚══════════════════════════════════════════════════════════════╝

  1️⃣  Vérifier Docker installé
     $ docker --version && docker compose version

  2️⃣  Lancer l'installation
     $ make install

  3️⃣  Ouvrir dans le navigateur
     → http://localhost:8080

  4️⃣  Consulter la documentation
     $ cat QUICKSTART.md

EOF
