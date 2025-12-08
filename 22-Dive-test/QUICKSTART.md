# Dive Docker : Quickstart (30 secondes)

## 🚀 3 Commandes Pour Commencer

```bash
cd /home/cj/gitdata/22-Dive-test

# 1) Vérifier l'env
./scripts/diagnostic.sh

# 2) Lancer les tests (build bad + good, Dive TUI)
./scripts/test-dive.sh

# 3) Voir le rapport
./scripts/compare.sh
cat results/comparison.md
```

## Dans Dive TUI

- **Tab** : changer panneau (layers ↔ files)
- **Ctrl+U** : voir uniquement les modifications (= trouver le gaspillage)
- **Ctrl+C** : quitter
- **↑/↓** : naviguer

## Résultat

- **Bad** : 1.47 GB, 75% efficiency, 720 MB wasted
- **Good** : 350 MB, 94% efficiency, 12 MB wasted

**Réduction : 76% taille, 20% meilleure efficacité !**

---

Pour plus d'infos → `cat README.md`
