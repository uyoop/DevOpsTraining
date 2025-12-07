.PHONY: help setup deploy verify test clean vault-encrypt vault-edit

help:
	@echo "=== Commandes disponibles ==="
	@echo "make setup           - Démarrer les VMs Vagrant"
	@echo "make test            - Tester la connectivité Ansible"
	@echo "make deploy          - Déployer l'application complète"
	@echo "make deploy-db       - Déployer uniquement la base de données"
	@echo "make deploy-app      - Déployer uniquement l'application"
	@echo "make deploy-web      - Déployer uniquement le serveur web"
	@echo "make verify          - Vérifier le déploiement"
	@echo "make vault-encrypt   - Chiffrer le fichier vault"
	@echo "make vault-edit      - Éditer le fichier vault"
	@echo "make clean           - Détruire les VMs Vagrant"
	@echo ""

setup:
	@echo "Démarrage des VMs Vagrant..."
	vagrant up

test:
	@echo "Test de connectivité..."
	ansible-playbook test_connectivity.yml

deploy:
	@echo "Déploiement complet de l'application..."
	ansible-playbook webapp_deploy.yml --ask-vault-pass

deploy-db:
	@echo "Déploiement de la base de données..."
	ansible-playbook webapp_deploy.yml --tags database --ask-vault-pass

deploy-app:
	@echo "Déploiement de l'application..."
	ansible-playbook webapp_deploy.yml --tags appserver --ask-vault-pass

deploy-web:
	@echo "Déploiement du serveur web..."
	ansible-playbook webapp_deploy.yml --tags webserver --ask-vault-pass

verify:
	@echo "Vérification du déploiement..."
	ansible-playbook verify_deployment.yml --ask-vault-pass

vault-encrypt:
	@echo "Chiffrement du fichier vault..."
	ansible-vault encrypt group_vars/vault.yml

vault-edit:
	@echo "Édition du fichier vault..."
	ansible-vault edit group_vars/vault.yml

clean:
	@echo "Destruction des VMs..."
	vagrant destroy -f
