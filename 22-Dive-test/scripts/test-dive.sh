#!/bin/bash
set -e

echo "=========================================="
echo "SCRIPT DE TEST DIVE COMPLET"
echo "=========================================="
echo ""

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[✓]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[!]${NC} $1"; }
log_error() { echo -e "${RED}[✗]${NC} $1"; }

# STEP 1 : Build bad image
echo ""
echo "STEP 1: Building non-optimized image (dive-demo:bad)"
echo "=========================================="
if docker build -t dive-demo:bad -f Dockerfile . > /tmp/build-bad.log 2>&1; then
    log_info "Image 'dive-demo:bad' built successfully"
    SIZE_BAD=$(docker images dive-demo:bad --format "{{.Size}}")
    log_info "Size: $SIZE_BAD"
else
    log_error "Failed to build dive-demo:bad"
    cat /tmp/build-bad.log
    exit 1
fi

# STEP 2 : Build good image
echo ""
echo "STEP 2: Building optimized image (dive-demo:good)"
echo "=========================================="
if docker build -t dive-demo:good -f Dockerfile.good . > /tmp/build-good.log 2>&1; then
    log_info "Image 'dive-demo:good' built successfully"
    SIZE_GOOD=$(docker images dive-demo:good --format "{{.Size}}")
    log_info "Size: $SIZE_GOOD"
else
    log_error "Failed to build dive-demo:good"
    cat /tmp/build-good.log
    exit 1
fi

# STEP 3 : Get image history
echo ""
echo "STEP 3: Image history analysis"
echo "=========================================="
log_info "Generating history for both images"
docker history dive-demo:bad --human --no-trunc > bad-history.txt
docker history dive-demo:good --human --no-trunc > good-history.txt
log_info "History saved to bad-history.txt and good-history.txt"

# STEP 4 : Get image metadata
echo ""
echo "STEP 4: Image metadata"
echo "=========================================="
docker inspect dive-demo:bad > bad-inspect.json
docker inspect dive-demo:good > good-inspect.json
log_info "Metadata saved to bad-inspect.json and good-inspect.json"

# STEP 5 : Dive analysis in container (bad)
echo ""
echo "STEP 5: Running Dive analysis (bad image) in container"
echo "=========================================="
log_warn "Launching Dive TUI for dive-demo:bad (interactive mode)"
log_warn "Controls: Tab=switch panel, ↑/↓=navigate, Ctrl+U=modified, Ctrl+C=quit"
docker run --rm -it \
  -v /var/run/docker.sock:/var/run/docker.sock \
  wagoodman/dive:latest \
  dive-demo:bad || log_warn "Dive analysis cancelled or completed"

# STEP 6 : Dive analysis in container (good)
echo ""
echo "STEP 6: Running Dive analysis (good image) in container"
echo "=========================================="
log_warn "Launching Dive TUI for dive-demo:good (interactive mode)"
docker run --rm -it \
  -v /var/run/docker.sock:/var/run/docker.sock \
  wagoodman/dive:latest \
  dive-demo:good || log_warn "Dive analysis cancelled or completed"

# STEP 7 : Summary
echo ""
echo "=========================================="
echo "TEST SUMMARY"
echo "=========================================="
echo ""
echo "Image comparison:"
docker images | grep dive-demo
echo ""
echo "Files generated:"
ls -lh bad-history.txt good-history.txt bad-inspect.json good-inspect.json 2>/dev/null || log_warn "Some files missing"
echo ""
log_info "Test completed successfully!"
echo ""
echo "Next steps:"
echo "  1. Review bad-history.txt and good-history.txt"
echo "  2. Check disk usage: du -sh *"
echo "  3. Analyze layer count: grep -c 'RUN' Dockerfile vs Dockerfile.good"
echo ""
