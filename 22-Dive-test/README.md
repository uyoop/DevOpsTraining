# TP22 - Dive Docker : Analyse et Optimisation d'Images

## 🎯 Objectifs

Ce TP est un **exercice pratique complet** pour maîtriser l'optimisation d'images Docker en utilisant **Dive**, l'outil d'analyse interactif des couches d'image.

**À la fin de ce TP, tu seras capable de :**

✅ Analyser la structure interne d'une image Docker couche par couche  
✅ Identifier les fichiers inutiles et les gaspillages d'espace  
✅ Optimiser un Dockerfile pour réduire taille, build time et wasted space  
✅ Maîtriser le cache Docker et l'ordre des instructions  
✅ Utiliser Dive en mode interactif (TUI) et en mode CI (non interactif)  
✅ Valider vos optimisations avec des métriques d'efficacité  

---

## 📚 Contexte

Cet exercice compare deux Dockerfiles :

1. **`Dockerfile` (bad)** : version délibérément non optimisée, présentant les **pièges courants**
   - Base image volumineuse (ubuntu:22.04)
   - RUN instructions séparées (mauvais caching)
   - Caches non nettoyés (apt, pip)
   - Fichiers temporaires inutiles
   - Dépendances dupliquées
   - Utilisateur root

2. **`Dockerfile.good` (good)** : version optimisée, démontrant les **bonnes pratiques**
   - Base slim (python:3.12-slim)
   - RUN instructions groupées (meilleur caching)
   - Nettoyage immédiat des caches
   - Dépendances minimales
   - Utilisateur non-root
   - .dockerignore configuré

---

## 🚀 Démarrage Rapide (3 étapes)

### Prérequis
- Docker Engine 20.10+ avec accès au socket
- Groupe docker configuré pour l'utilisateur courant
- Ansible 2.14+ (pour déploiement automatisé, optionnel)

### Étape 1 : Vérifier l'environnement
```bash
cd /home/cj/gitdata/22-Dive-test
./scripts/diagnostic.sh
```

**Résultat attendu :** tous les ✓ verts (Docker daemon, Dive CLI, fichiers de test)

### Étape 2 : Lancer les tests
```bash
./scripts/test-dive.sh
```

Ce script va :
1. Construire l'image non optimisée (`dive-demo:bad`)
2. Lancer Dive TUI pour explorer la structure
3. Construire l'image optimisée (`dive-demo:good`)
4. Lancer Dive TUI pour comparer
5. Générer des rapports (history, inspect)

### Étape 3 : Analyser les résultats
```bash
./scripts/compare.sh
cat results/comparison.md
```

---

## 🔍 Guide d'Utilisation de Dive (Interface TUI)

Une fois Dive lancé, tu accèdes à une interface **split-screen** :

```
┌─────────────────────────┬─────────────────────────┐
│   LAYERS (left)         │   FILES (right)         │
│                         │                         │
│ Layer 1 (FROM ubuntu)   │ / (directory tree)      │
│ Layer 2 (RUN apt-get)   │ ├── bin/                │
│ Layer 3 (RUN install)   │ ├── usr/                │
│ ...                     │ └── var/                │
└─────────────────────────┴─────────────────────────┘

┌─────────────────────────────────────────────────┐
│  [Image Efficiency: 75%] [Wasted: 500 MB]       │
│  [Total Size: 1.47 GB] [Layers: 15]             │
└─────────────────────────────────────────────────┘
```

### Commandes Clés

| Touche | Action |
|--------|--------|
| **Tab** | Basculer entre panneau layers ↔ files |
| **↑/↓** | Naviguer (layers ou fichiers) |
| **→/←** | Collapse/expand les dossiers |
| **Space** | Expand/collapse nœud sélectionné |
| **Ctrl+U** | Afficher **uniquement** les fichiers modifiés (clé pour trouver le gaspillage) |
| **Ctrl+A** | Afficher les fichiers **ajoutés** |
| **Ctrl+R** | Afficher les fichiers **supprimés** |
| **Ctrl+L** | Afficher les fichiers **non changés** |
| **d** | Trier par taille décroissante |
| **Ctrl+C** / **q** | Quitter |

### Métriques Clés à Observer

- **Image efficiency score** : % de fichiers réellement utilisés dans la dernière couche
  - > 90% = très bon
  - 70-90% = acceptable
  - < 70% = médiocre, optimisations possibles

- **Wasted Space** : espace gaspillé (fichiers écrasés, supprimés ou en cache)
  - Objectif : < 50 MB sur une application simple
  - Mauvais : > 500 MB

- **Layer Count** : nombre de couches
  - Moins = mieux (meilleur caching, image plus légère)
  - Bad : 15-20 couches
  - Good : 5-8 couches

---

## 📖 Analyse Détaillée : Bad vs Good

### Bad Image (dive-demo:bad)
```bash
# Build
docker build -t dive-demo:bad -f dockerfiles/bad/Dockerfile .

# Dive TUI
docker run --rm -it \
  -v /var/run/docker.sock:/var/run/docker.sock \
  wagoodman/dive:latest \
  dive-demo:bad
```

**Observations attendues :**
- Taille : 1.4-1.5 GB
- Layers : 15-20
- Efficiency score : 70-80%
- Wasted space : 600-800 MB
  - Layer 4 : `/var/lib/apt/lists/*` (cache apt ~200 MB)
  - Layer 6 : `/tmp/bigfiles/zero*.bin` (fichiers temp 100 MB)
  - Multiples installations Python (duplication)

**Problèmes identifiés (naviguer avec Ctrl+U) :**
1. `/var/lib/apt/lists/` : cache apt non nettoyé après `apt-get install`
2. `/tmp/bigfiles/` : fichiers temporaires de test (100 MB) jamais supprimés
3. Python packages : `flask`, `requests`, `numpy`, `pandas` installés deux fois
4. Build tools non supprimés : `build-essential`, `vim`, `nano`, `git`, etc.
5. Logs : `/var/log/apt/` contient des logs inutiles

### Good Image (dive-demo:good)
```bash
# Build
docker build -t dive-demo:good -f dockerfiles/good/Dockerfile .

# Dive TUI
docker run --rm -it \
  -v /var/run/docker.sock:/var/run/docker.sock \
  wagoodman/dive:latest \
  dive-demo:good
```

**Observations attendues :**
- Taille : 300-400 MB (réduction de **75%** !)
- Layers : 6-8
- Efficiency score : 92-96%
- Wasted space : < 20 MB

**Optimisations appliquées :**
1. Base `python:3.12-slim` au lieu de `ubuntu:22.04` (500 MB vs 150 MB)
2. RUN groupés : APT + pip en une seule instruction (1 couche au lieu de 3)
3. `rm -rf /var/lib/apt/lists/*` après `apt-get` (élimine cache apt)
4. `pip install --no-cache-dir` (pas de wheel cache)
5. Dépendances réduites : uniquement `ca-certificates` (rien de plus)
6. `.dockerignore` : exclut `__pycache__`, `.git`, etc. du contexte de build
7. Utilisateur non-root `appuser` (sécurité)
8. Variables d'env prod au lieu de debug

### Comparaison Récapitulative

| Métrique | Bad | Good | Amélioration |
|----------|-----|------|--------------|
| **Taille** | 1.47 GB | 350 MB | **76% reduction** |
| **Layers** | 18 | 7 | **61% reduction** |
| **Efficiency** | 74% | 94% | **+20 pp** |
| **Wasted Space** | 720 MB | 12 MB | **98% reduction** |
| **Build Time** | 120s | 45s | **62% faster** |

---

## 🧪 Cas d'Usage Avancés

### Mode CI/CD (non interactif)
Pour intégrer Dive dans un pipeline, générez un rapport JSON avec seuil d'efficacité :

```bash
# Mode CI avec seuil
dive dive-demo:bad --ci \
  --json results/dive-bad.json \
  --lowestEfficiency 0.90 \
  --exit-code 1
```

**Comportement :**
- Si efficiency < 90%, le pipeline échoue (exit code 1)
- Rapport JSON généré pour archivage
- Idéal pour gating (refuser les PRs avec images inefficaces)

### Multi-stage Build (avancé)
Pour les apps compilées, utilisez le multi-stage pour réduire encore :

```Dockerfile
# Stage 1: build
FROM golang:1.21 AS builder
COPY . /src
RUN go build -o /app .

# Stage 2: runtime (léger)
FROM alpine:latest
COPY --from=builder /app /app
ENTRYPOINT ["/app"]
```

Seul le binaire final (~10 MB) sera copié, éliminant tous les outils de build !

---

## 🛠️ Scripts Utilitaires

### `./scripts/diagnostic.sh`
Vérifie la configuration (Docker, Dive, fichiers, groupe docker, espace disque).

```bash
./scripts/diagnostic.sh
```

### `./scripts/test-dive.sh`
Lance le test complet : build bad + good, Dive TUI interactif, génère rapports.

```bash
./scripts/test-dive.sh
```

### `./scripts/compare.sh`
Génère un rapport Markdown comparant les deux images (tailles, layers, optimisations).

```bash
./scripts/compare.sh
cat results/comparison.md
```

---

## 📁 Structure du Dossier

```
22-Dive-test/
├── README.md                          # Ce fichier
├── QUICKSTART.md                      # Démarrage ultra-rapide
│
├── dockerfiles/                       # Sources Dockerfile
│   ├── bad/Dockerfile                # Version non optimisée
│   └── good/Dockerfile               # Version optimisée
│
├── app/                               # Code applicatif
│   ├── app.py                        # Flask simple
│   ├── requirements.txt              # Dépendances
│   └── .dockerignore                 # Exclusions build
│
├── scripts/                           # Utilitaires
│   ├── diagnostic.sh                 # Vérifier l'environnement
│   ├── test-dive.sh                  # Lancer les tests
│   └── compare.sh                    # Générer rapport
│
├── ansible/                           # Déploiement automatisé
│   ├── playbook-docker.yml           # Install Docker + Dive
│   └── inventory.ini                 # Hôte cible
│
└── results/                          # Résultats générés
    ├── .gitkeep
    ├── bad-history.txt
    ├── bad-inspect.json
    ├── good-history.txt
    ├── good-inspect.json
    └── comparison.md
```

---

## 🚢 Déploiement avec Ansible (Optionnel)

Pour déployer Docker + Dive sur une machine distante :

```bash
cd ansible

# 1) Adapter l'inventaire
nano inventory.ini
# Remplacer IP et user SSH

# 2) Lancer le playbook
ansible-playbook -i inventory.ini playbook-docker.yml

# 3) Valider sur l'hôte distant
ssh user@host "./scripts/diagnostic.sh"
ssh user@host "./scripts/test-dive.sh"
```

---

## 📊 Métriques de Succès

✅ **Performance :**
- Image size : < 500 MB (objectif)
- Build time : < 60s (sans cache)
- Efficiency score : > 90%

✅ **Sécurité :**
- Utilisateur non-root : `USER appuser`
- Base image à jour : `python:3.12-slim`
- Secrets absents de l'image (pas de .env copiés)

✅ **Caching :**
- Dépendances avant code source (réutilisation cache)
- RUN instructions groupées (moins de layers)
- .dockerignore configuré

---

## 🔗 Ressources

- **Blog Stéphane Robert (Dive)** : https://blog.stephane-robert.info/docs/conteneurs/outils/dive/
- **GitHub Dive** : https://github.com/wagoodman/dive
- **Docker Best Practices** : https://docs.docker.com/develop/dev-best-practices/
- **Optimiser les images** : https://blog.stephane-robert.info/docs/conteneurs/images-conteneurs/optimiser-taille-image/

---

## ❓ FAQ

**Q : Pourquoi ma base image est-elle si grande ?**  
A : Ubuntu complet = 77 MB + all packages. Utilisez `-slim` (python, debian, etc.) ou `-alpine` (5-10 MB).

**Q : Pourquoi Dive montre "wasted space" ?**  
A : Docker préserve les couches précédentes. Si un fichier est supprimé dans la couche N, il existe toujours dans couche N-1. Dive account cet "espace gaspillé".

**Q : Comment tester en mode CI ?**  
A : `dive image --ci --json report.json --lowestEfficiency 0.92 --exit-code 1`

**Q : Où mettre mes secrets (DB password, API keys) ?**  
A : **JAMAIS** dans l'image (RUN/COPY). Utilisez des variables d'environnement ou des secrets Docker/Kubernetes.

**Q : Multi-stage est-il toujours nécessaire ?**  
A : Non, seulement si vous compilez (Go, Rust, C++) et avez besoin d'éliminer les outils de build (gcc, etc.).

---

## 📝 Notes

- Tu peux modifier les Dockerfiles et relancer les tests pour expérimenter.
- Ajoute `--verbose` aux scripts pour plus de détails.
- Les résultats sont sauvegardés dans `results/` pour comparaison future.
- Collaborateurs : utiliser des tags de version (`v1.0`, `v1.1`) sur les images.

---

**Prêt ? Lance : `./scripts/diagnostic.sh` → `./scripts/test-dive.sh` → `./scripts/compare.sh`** 🚀
