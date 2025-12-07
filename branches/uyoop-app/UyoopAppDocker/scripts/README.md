# 🚀 Scripts UyoopApp

Ce dossier contient tous les scripts d'automatisation du projet.

## 📜 Scripts disponibles

### Scripts principaux

#### **deploy.sh** - Déploiement automatique
Déploie l'application avec Docker en une commande.
```bash
./scripts/deploy.sh
```

#### **test.sh** - Suite de tests
Lance tous les tests automatiques de l'application.
```bash
./scripts/test.sh
```

#### **install-docker.sh** - Installation Docker
Installe automatiquement Docker sur Ubuntu/Debian.
```bash
sudo ./scripts/install-docker.sh
```

#### **show-structure.sh** - Affichage de la structure
Affiche la structure du projet de manière visuelle.
```bash
./scripts/show-structure.sh
```

## 🔧 Utilisation

### Depuis la racine du projet
```bash
./scripts/deploy.sh
./scripts/test.sh
./scripts/show-structure.sh
```

### Via Make (recommandé)
```bash
make install    # Équivalent à deploy.sh avec vérifications
make test       # Équivalent à test.sh
```

## 📝 Notes

- Tous les scripts sont exécutables (`chmod +x`)
- Les scripts utilisent des couleurs pour une meilleure lisibilité
- Gestion d'erreurs intégrée dans chaque script

## 🔙 Retour

- [INDEX.md](../INDEX.md) - Guide de navigation principal
- [docs/COMMANDS.md](../docs/COMMANDS.md) - Référence complète des commandes
