#!/bin/bash
# Portainer Deploy Script
# ==============================================================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() { echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1" >&2; exit 1; }
warn() { echo -e "${YELLOW}[WARNING]${NC} $1"; }

check_prerequisites() {
  log "Checking prerequisites..."
  command -v docker &> /dev/null || error "Docker is not installed"
  command -v docker-compose &> /dev/null || error "Docker Compose is not installed"
  [[ -f ".env" ]] || error ".env file not found"
  log "Prerequisites check passed"
}

create_acme() {
  log "Setting up ACME certificate directory..."
  mkdir -p traefik
  touch traefik/acme.json
  chmod 600 traefik/acme.json
}

pull_images() {
  log "Pulling Docker images..."
  docker-compose pull || warn "Some images may have failed to pull"
}

start_services() {
  log "Starting Portainer services..."
  docker-compose up -d || error "Failed to start services"
}

wait_for_portainer() {
  log "Waiting for Portainer to be ready..."
  local retries=0
  local max_retries=60
  
  while [[ $retries -lt $max_retries ]]; do
    if docker-compose exec -T portainer wget -q -O- http://localhost:9000 &>/dev/null; then
      log "✅ Portainer is ready"
      return 0
    fi
    sleep 2
    ((retries++))
  done
  
  warn "Portainer did not become ready in time - continue monitoring"
}

display_summary() {
  source .env
  
  echo ""
  echo -e "${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
  echo -e "${GREEN}║        Portainer Enterprise Deployment Summary        ║${NC}"
  echo -e "${GREEN}╚════════════════════════════════════════════════════════╝${NC}"
  echo ""
  echo -e "${YELLOW}Portainer Configuration:${NC}"
  echo "  URL: https://$PORTAINER_HOSTNAME"
  echo "  Admin User: admin"
  echo "  Port HTTP: 8000"
  echo "  Port HTTPS: 9443"
  echo ""
  echo -e "${YELLOW}Monitoring:${NC}"
  echo "  Prometheus: https://prometheus.$PORTAINER_HOSTNAME"
  echo "  Grafana: https://grafana.$PORTAINER_HOSTNAME"
  echo ""
  echo -e "${YELLOW}Services:${NC}"
  docker-compose ps
  echo ""
  echo -e "${YELLOW}Next Steps:${NC}"
  echo "  1. Update /etc/hosts or DNS to point $PORTAINER_HOSTNAME to this server"
  echo "  2. Access Portainer at https://$PORTAINER_HOSTNAME"
  echo "  3. Log in with admin credentials"
  echo "  4. Add remote Docker environments in Endpoints"
  echo "  5. Deploy stacks and manage containers"
  echo ""
  echo -e "${GREEN}✅ Portainer deployment completed!${NC}"
}

main() {
  log "Starting Portainer Enterprise deployment..."
  check_prerequisites
  create_acme
  pull_images
  start_services
  wait_for_portainer
  display_summary
}

main "$@"
