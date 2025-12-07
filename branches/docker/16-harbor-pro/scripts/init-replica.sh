#!/bin/bash
# Initialize PostgreSQL replica from primary
# ==============================================================================

set -e

echo "Initializing PostgreSQL replica..."

# Wait for primary to be ready
until pg_isready -h postgres-primary -U "$POSTGRES_USER" 2>/dev/null; do
  echo "Waiting for primary database to be ready..."
  sleep 1
done

echo "Primary database is ready. Starting replica..."

# Use pg_basebackup to create replica
pg_basebackup -h postgres-primary -U "$POSTGRES_USER" -D /var/lib/postgresql/data -v -P -W

echo "PostgreSQL replica initialized."
