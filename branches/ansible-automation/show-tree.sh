#!/bin/bash
# Script pour afficher l'arborescence Git

echo "=== BRANCHES GIT ==="
git branch -a
echo ""

echo "=== BRANCHE ACTUELLE ==="
git branch --show-current
echo ""

echo "=== ARBORESCENCE /home/cj/gitdata ==="
find . -maxdepth 3 -type d -not -path '*/\.git/*' | sort | sed 's|^\./||' | head -50
echo ""

echo "=== FICHIERS NON COMMITÉS (git status) ==="
git status --short
echo ""

echo "=== DERNIERS COMMITS ==="
git log --oneline --all --decorate --graph -10
