#!/bin/bash

# Script de démarrage automatique du laboratoire Docker
# Ce script va créer la VM et installer Docker automatiquement

set -e  # Arrêter en cas d'erreur

echo "╔═══════════════════════════════════════════════════════════╗"
echo "║    Configuration du laboratoire Docker avec Vagrant      ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""

# Vérification des prérequis
echo "📋 Vérification des prérequis..."
echo ""

# Vérifier Vagrant
if ! command -v vagrant &> /dev/null; then
    echo "❌ Vagrant n'est pas installé"
    echo "   Installez-le depuis: https://www.vagrantup.com/"
    exit 1
fi
echo "✅ Vagrant $(vagrant --version | cut -d' ' -f2)"

# Vérifier VirtualBox
if ! command -v VBoxManage &> /dev/null; then
    echo "❌ VirtualBox n'est pas installé"
    echo "   Installez-le depuis: https://www.virtualbox.org/"
    exit 1
fi
echo "✅ VirtualBox installé"

# Vérifier Ansible
if ! command -v ansible-playbook &> /dev/null; then
    echo "❌ Ansible n'est pas installé"
    echo "   Installez-le avec: sudo apt install ansible  (ou pip3 install ansible)"
    exit 1
fi
echo "✅ Ansible $(ansible --version | head -n1 | cut -d' ' -f3-4)"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Étape 1: Démarrage de la VM
echo "🚀 Étape 1/3: Création et démarrage de la VM..."
echo "   (Cela peut prendre 5-10 minutes la première fois)"
echo ""

if vagrant up; then
    echo "✅ VM créée avec succès"
else
    echo "❌ Erreur lors de la création de la VM"
    exit 1
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Attendre que la VM soit complètement prête
echo "⏳ Attente de la disponibilité complète de la VM..."
sleep 10

# Étape 2: Test de connexion Ansible
echo "🔌 Étape 2/3: Test de la connexion Ansible..."
echo ""

max_retries=10
retry=0
while [ $retry -lt $max_retries ]; do
    if ansible -i inventory.ini all -m ping &> /dev/null; then
        echo "✅ Connexion Ansible établie"
        break
    else
        retry=$((retry + 1))
        if [ $retry -lt $max_retries ]; then
            echo "   Tentative $retry/$max_retries échouée, nouvelle tentative dans 5s..."
            sleep 5
        else
            echo "❌ Impossible de se connecter à la VM via Ansible"
            echo "   Essayez manuellement: ansible -i inventory.ini all -m ping"
            exit 1
        fi
    fi
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Étape 3: Installation de Docker
echo "🐳 Étape 3/3: Installation de Docker avec Ansible..."
echo ""

if ansible-playbook -i inventory.ini install_docker.yml; then
    echo "✅ Docker installé avec succès"
else
    echo "❌ Erreur lors de l'installation de Docker"
    exit 1
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Vérification finale
echo "🔍 Vérification finale..."
echo ""

if vagrant ssh -c "docker --version" &> /dev/null; then
    echo "✅ Docker fonctionne correctement"
    echo ""
    vagrant ssh -c "docker --version"
    vagrant ssh -c "docker compose version"
else
    echo "⚠️  Docker est installé mais nécessite une reconnexion"
fi

echo ""
echo "╔═══════════════════════════════════════════════════════════╗"
echo "║              🎉 Installation terminée ! 🎉                ║"
echo "╠═══════════════════════════════════════════════════════════╣"
echo "║  Votre laboratoire Docker est prêt à l'emploi            ║"
echo "║                                                           ║"
echo "║  Pour vous connecter:                                     ║"
echo "║    vagrant ssh                                            ║"
echo "║                                                           ║"
echo "║  Tester Docker:                                          ║"
echo "║    vagrant ssh -c 'docker run hello-world'               ║"
echo "║                                                           ║"
echo "║  VM Info:                                                ║"
echo "║    IP: 192.168.56.123                                    ║"
echo "║    RAM: 4 GB | CPU: 2 vCPUs                              ║"
echo "║    OS: Ubuntu 22.04 LTS                                  ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""
