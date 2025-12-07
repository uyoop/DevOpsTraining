#!/bin/bash
# Script de test pour UyoopApp

set -e

echo "========================================="
echo "   Tests UyoopApp"
echo "========================================="
echo ""

# Couleurs
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Variables
BASE_URL="http://localhost:8080"
FAILED=0

# Fonction de test
test_endpoint() {
    local name=$1
    local url=$2
    local expected_code=${3:-200}
    
    echo -n "Test: $name... "
    
    http_code=$(curl -s -o /dev/null -w "%{http_code}" "$url" || echo "000")
    
    if [ "$http_code" = "$expected_code" ]; then
        echo -e "${GREEN}✓ OK${NC} (HTTP $http_code)"
    else
        echo -e "${RED}✗ ÉCHEC${NC} (HTTP $http_code, attendu $expected_code)"
        FAILED=$((FAILED + 1))
    fi
}

# Vérifier que Docker est en cours d'exécution
echo -e "${YELLOW}→ Vérification de Docker...${NC}"
if ! docker compose -f docker/docker-compose.yml ps | grep -q "Up"; then
    echo -e "${RED}✗ Les conteneurs ne sont pas démarrés${NC}"
    echo "Lancez 'docker compose -f docker/docker-compose.yml up -d' d'abord"
    exit 1
fi
echo -e "${GREEN}✓ Conteneurs actifs${NC}"
echo ""

# Tests des endpoints
echo -e "${YELLOW}→ Tests des endpoints HTTP...${NC}"
test_endpoint "Page d'accueil" "$BASE_URL/"
test_endpoint "Page admin" "$BASE_URL/admin.php"
test_endpoint "Fichier CSS" "$BASE_URL/assets/style.css"
test_endpoint "Fichier JS" "$BASE_URL/assets/app.js"
test_endpoint "API Save (GET should fail)" "$BASE_URL/api/save" "405"
echo ""

# Test de la base de données
echo -e "${YELLOW}→ Test de la base de données...${NC}"
if [ -d "data" ] && [ -w "data" ]; then
    echo -e "${GREEN}✓ Répertoire data accessible${NC}"
else
    echo -e "${RED}✗ Répertoire data non accessible${NC}"
    FAILED=$((FAILED + 1))
fi
echo ""

# Test de création d'un formulaire
echo -e "${YELLOW}→ Test de sauvegarde d'un formulaire...${NC}"
response=$(curl -s -X POST "$BASE_URL/api/save" \
    -H "Content-Type: application/json" \
    -d '{
        "org_name": "Test Organisation",
        "contact_name": "Test User",
        "contact_email": "test@example.com",
        "project_type": "site_web",
        "budget": 5000,
        "timeline": "3 mois",
        "goals": "Test automatique"
    }' || echo '{"error": "connexion impossible"}')

if echo "$response" | grep -q '"id"'; then
    echo -e "${GREEN}✓ Sauvegarde réussie${NC}"
    
    # Extraire l'ID et tester la génération
    id=$(echo "$response" | grep -o '"id":[0-9]*' | grep -o '[0-9]*')
    if [ ! -z "$id" ]; then
        test_endpoint "Génération cahier des charges (ID: $id)" "$BASE_URL/generate?id=$id"
    fi
else
    echo -e "${RED}✗ Échec de la sauvegarde${NC}"
    echo "Réponse: $response"
    FAILED=$((FAILED + 1))
fi
echo ""

# Vérifier les logs pour des erreurs
echo -e "${YELLOW}→ Vérification des logs...${NC}"
if docker compose -f docker/docker-compose.yml logs --tail=50 | grep -i error | grep -v "error_log"; then
    echo -e "${YELLOW}⚠ Des erreurs ont été détectées dans les logs${NC}"
else
    echo -e "${GREEN}✓ Aucune erreur critique dans les logs${NC}"
fi
echo ""

# Résumé
echo "========================================="
if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}   ✓ Tous les tests sont passés !${NC}"
    echo "========================================="
    exit 0
else
    echo -e "${RED}   ✗ $FAILED test(s) ont échoué${NC}"
    echo "========================================="
    exit 1
fi
