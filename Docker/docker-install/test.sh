#!/bin/bash

# Script de test rapide de l'installation Docker
# Exécute quelques commandes de vérification

echo "╔═══════════════════════════════════════════════════════════╗"
echo "║           Test du laboratoire Docker                     ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""

# Vérifier que la VM est démarrée
echo "🔍 Vérification de l'état de la VM..."
if ! vagrant status | grep -q "running"; then
    echo "❌ La VM n'est pas démarrée"
    echo "   Lancez: vagrant up"
    exit 1
fi
echo "✅ VM en cours d'exécution"
echo ""

# Tester la connexion SSH
echo "🔌 Test de connexion SSH..."
if vagrant ssh -c "echo 'Connexion OK'" &> /dev/null; then
    echo "✅ Connexion SSH fonctionnelle"
else
    echo "❌ Impossible de se connecter à la VM"
    exit 1
fi
echo ""

# Vérifier Docker
echo "🐳 Vérification de Docker..."
if vagrant ssh -c "docker --version" &> /dev/null; then
    echo "✅ Docker est installé"
    vagrant ssh -c "docker --version"
else
    echo "❌ Docker n'est pas installé"
    echo "   Lancez: ansible-playbook -i inventory.ini install_docker.yml"
    exit 1
fi
echo ""

# Vérifier Docker Compose
echo "🎼 Vérification de Docker Compose..."
if vagrant ssh -c "docker compose version" &> /dev/null; then
    echo "✅ Docker Compose est installé"
    vagrant ssh -c "docker compose version"
else
    echo "⚠️  Docker Compose n'est pas disponible"
fi
echo ""

# Test fonctionnel: Lancer hello-world
echo "🧪 Test fonctionnel (hello-world)..."
if vagrant ssh -c "docker run --rm hello-world" &> /tmp/docker-test.log; then
    echo "✅ Docker fonctionne correctement"
    echo ""
    echo "   Extrait du test:"
    vagrant ssh -c "docker run --rm hello-world" 2>&1 | grep "Hello from Docker"
else
    echo "❌ Le test Docker a échoué"
    cat /tmp/docker-test.log
    exit 1
fi
echo ""

# Informations système
echo "📊 Informations système de la VM..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
vagrant ssh -c "
echo 'OS: \$(lsb_release -d | cut -f2)'
echo 'Kernel: \$(uname -r)'
echo 'RAM: \$(free -h | grep Mem | awk \"{print \\\$2}\") total, \$(free -h | grep Mem | awk \"{print \\\$7}\") disponible'
echo 'CPU: \$(nproc) vCPU(s)'
echo 'Disque: \$(df -h / | tail -1 | awk \"{print \\\$4}\") disponible'
"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Statistiques Docker
echo "🐳 Statistiques Docker..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
vagrant ssh -c "docker system df"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Résumé
echo "╔═══════════════════════════════════════════════════════════╗"
echo "║              ✅ Tous les tests sont OK ! ✅              ║"
echo "╠═══════════════════════════════════════════════════════════╣"
echo "║  Votre laboratoire Docker est prêt pour les TPs          ║"
echo "║                                                           ║"
echo "║  Commandes utiles:                                        ║"
echo "║    vagrant ssh              Se connecter à la VM         ║"
echo "║    vagrant halt             Arrêter la VM                ║"
echo "║    vagrant reload           Redémarrer la VM             ║"
echo "║                                                           ║"
echo "║  Documentation:                                           ║"
echo "║    README.md                Guide complet                ║"
echo "║    COMMANDES.md             Aide-mémoire Docker          ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""
