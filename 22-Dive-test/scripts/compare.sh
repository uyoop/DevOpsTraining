#!/bin/bash
set -e

echo "=========================================="
echo "DIVE COMPARISON REPORT"
echo "=========================================="
echo ""

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
RESULTS_DIR="$SCRIPT_DIR/../results"

echo "Generating comparison report..."
echo ""

# Image sizes
echo "## Image Sizes" > "$RESULTS_DIR/comparison.md"
echo "" >> "$RESULTS_DIR/comparison.md"
docker images | grep dive-demo >> "$RESULTS_DIR/comparison.md" 2>/dev/null || echo "No images found" >> "$RESULTS_DIR/comparison.md"
echo "" >> "$RESULTS_DIR/comparison.md"

# Layer analysis
echo "## Layer Count Analysis" >> "$RESULTS_DIR/comparison.md"
echo "" >> "$RESULTS_DIR/comparison.md"
echo "**Bad (Dockerfile):**" >> "$RESULTS_DIR/comparison.md"
grep -c '^RUN' "$SCRIPT_DIR/../dockerfiles/bad/Dockerfile" | xargs -I {} echo "  - {} RUN instructions" >> "$RESULTS_DIR/comparison.md"
docker history dive-demo:bad --no-trunc --human 2>/dev/null | wc -l | xargs -I {} echo "  - {} total layers" >> "$RESULTS_DIR/comparison.md"
echo "" >> "$RESULTS_DIR/comparison.md"

echo "**Good (Dockerfile):**" >> "$RESULTS_DIR/comparison.md"
grep -c '^RUN' "$SCRIPT_DIR/../dockerfiles/good/Dockerfile" | xargs -I {} echo "  - {} RUN instructions" >> "$RESULTS_DIR/comparison.md"
docker history dive-demo:good --no-trunc --human 2>/dev/null | wc -l | xargs -I {} echo "  - {} total layers" >> "$RESULTS_DIR/comparison.md"
echo "" >> "$RESULTS_DIR/comparison.md"

# Key optimizations
echo "## Key Optimizations Applied" >> "$RESULTS_DIR/comparison.md"
echo "" >> "$RESULTS_DIR/comparison.md"
echo "### Bad Image Issues:" >> "$RESULTS_DIR/comparison.md"
echo "- ❌ Large base image (ubuntu:22.04)" >> "$RESULTS_DIR/comparison.md"
echo "- ❌ Multiple separate RUN instructions (poor layer caching)" >> "$RESULTS_DIR/comparison.md"
echo "- ❌ APT cache not cleaned (adds 100MB+)" >> "$RESULTS_DIR/comparison.md"
echo "- ❌ Unnecessary build tools (build-essential, vim, nano, etc.)" >> "$RESULTS_DIR/comparison.md"
echo "- ❌ Temporary files (100MB zero*.bin files)" >> "$RESULTS_DIR/comparison.md"
echo "- ❌ Duplicate dependencies installed" >> "$RESULTS_DIR/comparison.md"
echo "- ❌ Running as root" >> "$RESULTS_DIR/comparison.md"
echo "" >> "$RESULTS_DIR/comparison.md"

echo "### Good Image Optimizations:" >> "$RESULTS_DIR/comparison.md"
echo "- ✅ Slim base image (python:3.12-slim)" >> "$RESULTS_DIR/comparison.md"
echo "- ✅ Combined RUN instructions (single layer per step)" >> "$RESULTS_DIR/comparison.md"
echo "- ✅ \`rm -rf /var/lib/apt/lists/*\` after apt (removes cache)" >> "$RESULTS_DIR/comparison.md"
echo "- ✅ Only essential packages (ca-certificates)" >> "$RESULTS_DIR/comparison.md"
echo "- ✅ \`--no-cache-dir\` for pip (no wheel cache)" >> "$RESULTS_DIR/comparison.md"
echo "- ✅ Dependencies ordered for optimal cache reuse" >> "$RESULTS_DIR/comparison.md"
echo "- ✅ .dockerignore to exclude unnecessary files" >> "$RESULTS_DIR/comparison.md"
echo "- ✅ Non-root user (appuser)" >> "$RESULTS_DIR/comparison.md"
echo "- ✅ Production environment variables" >> "$RESULTS_DIR/comparison.md"
echo "" >> "$RESULTS_DIR/comparison.md"

echo "Report saved to: $RESULTS_DIR/comparison.md"
echo ""
cat "$RESULTS_DIR/comparison.md"
