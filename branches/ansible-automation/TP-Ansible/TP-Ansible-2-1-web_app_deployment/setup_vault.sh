#!/bin/bash
# setup_vault.sh - Script pour configurer Ansible Vault

echo "=== Configuration Ansible Vault ==="
echo ""
echo "Ce script va vous aider à sécuriser les données sensibles avec Ansible Vault."
echo ""

# Vérifier si le fichier vault existe déjà et est chiffré
if [ -f "group_vars/vault.yml" ]; then
    if grep -q "ANSIBLE_VAULT" group_vars/vault.yml; then
        echo "✓ Le fichier vault.yml est déjà chiffré."
        echo ""
        echo "Pour éditer le vault : ansible-vault edit group_vars/vault.yml"
        echo "Pour déchiffrer : ansible-vault decrypt group_vars/vault.yml"
        exit 0
    else
        echo "⚠ Le fichier vault.yml existe mais n'est pas chiffré."
        read -p "Voulez-vous le chiffrer maintenant ? (o/n) " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Oo]$ ]]; then
            ansible-vault encrypt group_vars/vault.yml
            echo "✓ Fichier chiffré avec succès !"
        fi
    fi
else
    echo "✗ Le fichier group_vars/vault.yml n'existe pas."
    exit 1
fi

echo ""
echo "=== Commandes utiles ==="
echo "• Éditer le vault     : ansible-vault edit group_vars/vault.yml"
echo "• Chiffrer un fichier : ansible-vault encrypt <fichier>"
echo "• Déchiffrer          : ansible-vault decrypt <fichier>"
echo "• Changer le mot passe: ansible-vault rekey group_vars/vault.yml"
echo ""
echo "• Lancer le playbook  : ansible-playbook webapp_deploy.yml --ask-vault-pass"
echo "• Avec fichier passwd : ansible-playbook webapp_deploy.yml --vault-password-file .vault_pass"
