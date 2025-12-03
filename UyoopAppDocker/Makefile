.PHONY: help build up down restart logs clean deploy backup restore

# Variables
DOCKER_COMPOSE = docker compose
APP_NAME = uyoop

# Couleurs pour l'aide
BLUE = \033[0;34m
GREEN = \033[0;32m
YELLOW = \033[0;33m
NC = \033[0m # No Color

help: ## Afficher cette aide
	@echo "$(BLUE)UyoopApp - Commandes disponibles :$(NC)"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-15s$(NC) %s\n", $$1, $$2}'
	@echo ""

build: ## Construire les images Docker
	@echo "$(YELLOW)Construction des images Docker...$(NC)"
	$(DOCKER_COMPOSE) -f docker/docker-compose.yml build --no-cache

up: ## Démarrer l'application
	@echo "$(YELLOW)Démarrage de l'application...$(NC)"
	@mkdir -p data
	$(DOCKER_COMPOSE) -f docker/docker-compose.yml up -d
	@echo "$(GREEN)✓ Application démarrée sur http://localhost:8080$(NC)"

down: ## Arrêter l'application
	@echo "$(YELLOW)Arrêt de l'application...$(NC)"
	$(DOCKER_COMPOSE) -f docker/docker-compose.yml down

restart: ## Redémarrer l'application
	@echo "$(YELLOW)Redémarrage de l'application...$(NC)"
	$(DOCKER_COMPOSE) -f docker/docker-compose.yml restart
	@echo "$(GREEN)✓ Application redémarrée$(NC)"

logs: ## Afficher les logs en temps réel
	$(DOCKER_COMPOSE) -f docker/docker-compose.yml logs -f

logs-php: ## Afficher les logs PHP uniquement
	$(DOCKER_COMPOSE) -f docker/docker-compose.yml logs -f php

logs-nginx: ## Afficher les logs Nginx uniquement
	$(DOCKER_COMPOSE) -f docker/docker-compose.yml logs -f nginx

status: ## Afficher le statut des conteneurs
	@echo "$(BLUE)Statut des conteneurs :$(NC)"
	$(DOCKER_COMPOSE) -f docker/docker-compose.yml ps
	@echo ""
	@echo "$(BLUE)Statistiques :$(NC)"
	docker stats --no-stream $(APP_NAME)-nginx $(APP_NAME)-php 2>/dev/null || true

shell-php: ## Accéder au shell du conteneur PHP
	$(DOCKER_COMPOSE) -f docker/docker-compose.yml exec php sh

shell-nginx: ## Accéder au shell du conteneur Nginx
	$(DOCKER_COMPOSE) -f docker/docker-compose.yml exec nginx sh

deploy: build up ## Déployer l'application (build + up)
	@echo "$(GREEN)✓ Déploiement terminé !$(NC)"
	@echo "Application disponible sur : http://localhost:8080"

redeploy: down deploy ## Redéployer complètement l'application

clean: ## Nettoyer les conteneurs et images
	@echo "$(YELLOW)Nettoyage des conteneurs et images...$(NC)"
	$(DOCKER_COMPOSE) -f docker/docker-compose.yml down -v
	docker system prune -f
	@echo "$(GREEN)✓ Nettoyage terminé$(NC)"

backup: ## Créer un backup de la base de données
	@echo "$(YELLOW)Création du backup...$(NC)"
	@mkdir -p backups
	@if [ -f data/uyoop.db ]; then \
		cp data/uyoop.db backups/uyoop-$$(date +%Y%m%d-%H%M%S).db; \
		echo "$(GREEN)✓ Backup créé : backups/uyoop-$$(date +%Y%m%d-%H%M%S).db$(NC)"; \
	else \
		echo "$(YELLOW)⚠ Aucune base de données à sauvegarder$(NC)"; \
	fi

restore: ## Restaurer le dernier backup (usage: make restore FILE=backups/uyoop-xxx.db)
	@if [ -z "$(FILE)" ]; then \
		echo "$(YELLOW)Usage: make restore FILE=backups/uyoop-xxx.db$(NC)"; \
		exit 1; \
	fi
	@if [ -f "$(FILE)" ]; then \
		cp $(FILE) data/uyoop.db; \
		$(MAKE) restart; \
		echo "$(GREEN)✓ Base de données restaurée depuis $(FILE)$(NC)"; \
	else \
		echo "$(YELLOW)✗ Fichier $(FILE) non trouvé$(NC)"; \
		exit 1; \
	fi

test: ## Tester l'accès à l'application
	@echo "$(YELLOW)Test de l'application...$(NC)"
	@curl -s -o /dev/null -w "Status HTTP: %{http_code}\n" http://localhost:8080 || echo "$(YELLOW)✗ Application non accessible$(NC)"

check-docker: ## Vérifier que Docker est installé
	@command -v docker >/dev/null 2>&1 || { \
		echo "$(RED)✗ Docker n'est pas installé$(NC)"; \
		echo ""; \
		echo "$(YELLOW)Pour installer Docker, exécutez :$(NC)"; \
		echo "  sudo ./install-docker.sh"; \
		echo ""; \
		echo "$(YELLOW)Ou consultez : https://docs.docker.com/engine/install/$(NC)"; \
		exit 1; \
	}
	@command -v docker compose >/dev/null 2>&1 || { \
		echo "$(RED)✗ Docker Compose n'est pas installé$(NC)"; \
		echo ""; \
		echo "$(YELLOW)Pour installer Docker Compose, exécutez :$(NC)"; \
		echo "  sudo ./install-docker.sh"; \
		exit 1; \
	}
	@echo "$(GREEN)✓ Docker et Docker Compose sont installés$(NC)"

install: check-docker ## Installation complète (pour première utilisation)
	@echo "$(BLUE)=== Installation UyoopApp ===$(NC)"
	@echo "$(YELLOW)1. Vérification des prérequis...$(NC)"
	@echo "$(GREEN)✓ Docker et Docker Compose installés$(NC)"
	@echo "$(YELLOW)2. Création des répertoires...$(NC)"
	@mkdir -p data backups
	@echo "$(GREEN)✓ Répertoires créés$(NC)"
	@echo "$(YELLOW)3. Copie du fichier .env...$(NC)"
	@if [ ! -f .env ]; then cp .env.example .env; echo "$(GREEN)✓ .env créé$(NC)"; else echo "$(YELLOW)⚠ .env existe déjà$(NC)"; fi
	@echo "$(YELLOW)4. Déploiement...$(NC)"
	@$(MAKE) deploy
	@echo ""
	@echo "$(GREEN)=== Installation terminée ! ===$(NC)"
	@echo "Application disponible sur : $(BLUE)http://localhost:8080$(NC)"
	@echo "Administration : $(BLUE)http://localhost:8080/admin.php$(NC)"

uninstall: ## Désinstaller complètement l'application
	@echo "$(YELLOW)⚠ Désinstallation de l'application...$(NC)"
	@read -p "Êtes-vous sûr ? (y/N) " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		$(MAKE) clean; \
		rm -rf data/*.db backups; \
		echo "$(GREEN)✓ Désinstallation terminée$(NC)"; \
	else \
		echo "$(YELLOW)Annulé$(NC)"; \
	fi

dev: ## Mode développement avec logs en direct
	@mkdir -p data
	$(DOCKER_COMPOSE) -f docker/docker-compose.yml up --build

.DEFAULT_GOAL := help
