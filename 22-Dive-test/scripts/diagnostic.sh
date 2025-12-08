#!/bin/bash
set -e

echo "=========================================="
echo "DIAGNOSTIC DIVE + DOCKER SETUP"
echo "=========================================="
echo ""

# 1) Vérifier Docker
echo "[1/8] Docker Engine"
if command -v docker &> /dev/null; then
    docker --version
    docker ps -q > /dev/null && echo "✓ Docker daemon accessible" || echo "✗ Docker daemon not responding"
else
    echo "✗ Docker not installed"
    exit 1
fi
echo ""

# 2) Vérifier les images
echo "[2/8] Images locales"
docker images | grep dive-demo || echo "⚠ Aucune image dive-demo trouvée"
echo ""

# 3) Vérifier Dive CLI
echo "[3/8] Dive CLI"
if command -v dive &> /dev/null; then
    dive --version
    echo "✓ Dive CLI installé"
else
    echo "✗ Dive CLI not found"
fi
echo ""

# 4) Vérifier Dive image Docker
echo "[4/8] Dive Docker image"
docker images | grep wagoodman/dive || echo "⚠ Image Dive Docker non présente (sera pulled)"
echo ""

# 5) Vérifier fichiers de test
echo "[5/8] Fichiers de test"
for file in Dockerfile Dockerfile.good app.py requirements.txt .dockerignore; do
    [ -f "$file" ] && echo "✓ $file" || echo "✗ $file manquant"
done
echo ""

# 6) Vérifier taille disque
echo "[6/8] Espace disque disponible"
df -h . | tail -1
echo ""

# 7) Vérifier le groupe docker
echo "[7/8] Appartenance au groupe docker"
groups | grep -q docker && echo "✓ Utilisateur dans le groupe docker" || echo "⚠ Utilisateur NOT in docker group (utiliser sudo)"
echo ""

# 8) Tester une simple commande docker
echo "[8/8] Test de connectivité Docker"
docker run --rm alpine:latest echo "✓ Docker fonctionne correctement" || echo "✗ Docker test failed"
echo ""

echo "=========================================="
echo "DIAGNOSTIC TERMINÉ"
echo "=========================================="
