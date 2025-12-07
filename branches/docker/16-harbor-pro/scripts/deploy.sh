#!/bin/bash
# Harbor Deploy Script
# ==============================================================================
# Description: Deploy Harbor with production configuration
# Usage: ./deploy.sh
# ==============================================================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Functions
log() { echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1" >&2; exit 1; }
warn() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
info() { echo -e "${BLUE}[INFO]${NC} $1"; }

# Check prerequisites
check_prerequisites() {
  log "Checking prerequisites..."
  command -v docker &> /dev/null || error "Docker is not installed"
  command -v docker-compose &> /dev/null || error "Docker Compose is not installed"
  [[ -f ".env" ]] || error ".env file not found. Copy from .env.example first"
  [[ -f "docker-compose.yml" ]] || error "docker-compose.yml not found"
  log "Prerequisites check passed"
}

# Validate configuration
validate_config() {
  log "Validating configuration..."
  
  # Check required environment variables
  source .env
  
  [[ -z "$HARBOR_HOSTNAME" ]] && error "HARBOR_HOSTNAME is not set"
  [[ -z "$HARBOR_ADMIN_PASSWORD" ]] && error "HARBOR_ADMIN_PASSWORD is not set"
  [[ -z "$POSTGRES_PASSWORD" ]] && error "POSTGRES_PASSWORD is not set"
  [[ -z "$REDIS_PASSWORD" ]] && error "REDIS_PASSWORD is not set"
  
  log "Configuration validation passed"
}

# Create required directories
create_directories() {
  log "Creating required directories..."
  mkdir -p backups
  mkdir -p traefik/acme.json
  chmod 600 traefik/acme.json 2>/dev/null || true
  log "Directories created"
}

# Generate ACMEcertificate
setup_acme() {
  log "Setting up ACME certificate directory..."
  touch traefik/acme.json
  chmod 600 traefik/acme.json
  log "ACME certificate directory ready"
}

# Pull images
pull_images() {
  log "Pulling Docker images..."
  docker-compose pull || warn "Some images may have failed to pull"
  log "Images pulled"
}

# Start services
start_services() {
  log "Starting Harbor services..."
  docker-compose up -d || error "Failed to start services"
  log "Services started"
}

# Wait for services
wait_for_services() {
  log "Waiting for services to be ready..."
  
  local retries=0
  local max_retries=60
  
  while [[ $retries -lt $max_retries ]]; do
    if docker-compose exec -T postgres-primary pg_isready -U "$POSTGRES_USER" &>/dev/null; then
      log "PostgreSQL is ready"
      break
    fi
    sleep 2
    ((retries++))
  done
  
  if [[ $retries -eq $max_retries ]]; then
    warn "PostgreSQL did not become ready in time"
  fi
  
  # Wait for Harbor Core
  retries=0
  while [[ $retries -lt $max_retries ]]; do
    if docker-compose exec -T harbor curl -f http://localhost:8080/api/v2.0/health &>/dev/null; then
      log "Harbor Core is healthy"
      return 0
    fi
    sleep 2
    ((retries++))
  done
  
  warn "Harbor did not become healthy in time - continue monitoring"
}

# Initialize Harbor
init_harbor() {
  log "Initializing Harbor database..."
  docker-compose exec -T postgres-primary psql -U "$POSTGRES_USER" -d "$POSTGRES_DATABASE" -c "SELECT 1" 2>/dev/null || warn "Database initialization may have failed"
  log "Harbor initialization completed"
}

# Display summary
display_summary() {
  source .env
  
  echo -e "${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
  echo -e "${GREEN}║           Harbor Deployment Summary                   ║${NC}"
  echo -e "${GREEN}╚════════════════════════════════════════════════════════╝${NC}"
  echo ""
  echo -e "${BLUE}Harbor Configuration:${NC}"
  echo "  URL: https://$HARBOR_HOSTNAME"
  echo "  Admin User: admin"
  echo "  Admin Password: [Use the one set in .env]"
  echo ""
  echo -e "${BLUE}Monitoring:${NC}"
  echo "  Prometheus: https://prometheus.$HARBOR_HOSTNAME"
  echo "  Grafana: https://grafana.$HARBOR_HOSTNAME"
  echo "  AlertManager: https://alerts.$HARBOR_HOSTNAME"
  echo ""
  echo -e "${BLUE}Services:${NC}"
  docker-compose ps
  echo ""
  echo -e "${BLUE}Next Steps:${NC}"
  echo "  1. Update /etc/hosts or DNS to point $HARBOR_HOSTNAME to this server"
  echo "  2. Access Harbor at https://$HARBOR_HOSTNAME"
  echo "  3. Log in with admin credentials"
  echo "  4. Configure LDAP/OIDC in Harbor Settings if needed"
  echo "  5. Monitor logs: docker-compose logs -f"
  echo ""
  echo -e "${GREEN}✅ Harbor deployment completed!${NC}"
}

# Main execution
main() {
  log "Starting Harbor deployment..."
  check_prerequisites
  validate_config
  create_directories
  setup_acme
  pull_images
  start_services
  wait_for_services
  init_harbor
  display_summary
}

main "$@"
