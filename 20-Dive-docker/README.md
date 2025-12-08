# TP20 - Dive pour analyser les images Docker

Analyse interactive (TUI) et en mode CI des couches d'une image Docker afin d'optimiser taille, cache et sécurité.

## 🎯 Objectifs
- Comprendre la structure d'une image Docker couche par couche.
- Identifier les fichiers inutiles et optimiser les Dockerfiles.
- Utiliser Dive en mode interactif et en mode CI pour valider vos builds.

## 🔗 Référence
Tutoriel de base : https://blog.stephane-robert.info/docs/conteneurs/outils/dive/

## ✅ Prérequis
- Docker 20.10+ et Docker Compose 2+
- Accès internet (téléchargement binaire Dive ou via gestionnaire de paquets)
- Linux (Ubuntu/Debian) recommandé. macOS/Windows possibles via Homebrew/Chocolatey.

## 📦 Installation rapide
### Linux (paquet .deb)
```bash
wget https://github.com/wagoodman/dive/releases/download/v0.12.0/dive_0.12.0_linux_amd64.deb
sudo apt install ./dive_0.12.0_linux_amd64.deb
```

### Linux (gestion de versions ASDF)
```bash
asdf plugin add dive
asdf install dive latest
asdf set --home dive latest
```

### macOS / Windows
- macOS : `brew install dive`
- Windows : `choco install dive`

> Vérification : `dive --version`

## 🚀 Démarrage rapide
```bash
# 1) Choisir une image existante
sudo docker pull nginx:1.27-alpine

# 2) Lancer l'analyse interactive
sudo dive nginx:1.27-alpine

# 3) Naviguer
# ←/→ pour parcourir les couches, ↑/↓ pour naviguer dans l'arborescence.
# "Content view" montre les fichiers ajoutés/modifiés/supprimés.
```

### Interpréter les métriques clés
- *Image efficiency score* : pourcentage de fichiers réellement utilisés dans la dernière couche.
- *Wasted bytes* : espace gaspillé (fichiers écrasés, supprimés ou inutiles).
- *User-created layers* : nombre de RUN/ADD/COPY du Dockerfile.

## 🧪 Exercice guidé
1) Construire une image volontairement sous-optimisée :
```bash
cat > Dockerfile <<'EOF'
FROM python:3.12-slim
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*
RUN useradd -ms /bin/bash app
COPY . /app
WORKDIR /app
RUN pip install --no-cache-dir -r requirements.txt
CMD ["python", "app.py"]
EOF

docker build -t demo-dive:raw .
```
2) Inspecter avec Dive :
```bash
sudo dive demo-dive:raw
```
3) Optimiser le Dockerfile : fusionner les RUN, nettoyer `apt`, ajouter `.dockerignore`, utiliser multi-stage si besoin.
4) Rebuild (`demo-dive:opt`) et comparer le score et les wasted bytes.

## 🔁 Mode CI (non interactif)
Dive peut échouer un pipeline si l'efficacité est trop basse :
```bash
sudo dive demo-dive:opt --ci --json dive-report.json --exit-code 1 --lowestEfficiency 0.90
```
- `--ci` : mode non interactif.
- `--lowestEfficiency` : seuil minimal d'efficacité accepté.
- `--json`/`--html` : export de rapport.

## 🧰 Tips d'optimisation Dockerfile
- Regrouper les RUN et nettoyer les caches `apt`, `pip`, `npm`.
- Utiliser des bases `-alpine` ou `-slim` si compatibles.
- Ajouter `.dockerignore` (node_modules, venv, tests, docs).
- Tirer parti du cache : ordonner les instructions du moins variable (deps système) au plus variable (sources).
- Multi-stage builds pour garder uniquement les artefacts nécessaires.

## 📚 Ressources
- Repo officiel : https://github.com/wagoodman/dive
- Article de référence : https://blog.stephane-robert.info/docs/conteneurs/outils/dive/
- Outils complémentaires : Trivy (scan vulnérabilités), Dockle (lint d'image), Skopeo (copie), Crane (inspect).
