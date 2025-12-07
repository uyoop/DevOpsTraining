#!/bin/bash
# Initialize Harbor database
# ==============================================================================

set -e

echo "Initializing Harbor database..."

psql -U "$POSTGRES_USER" -d "$POSTGRES_DATABASE" <<-EOSQL
  CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
  CREATE EXTENSION IF NOT EXISTS "pgcrypto";
  
  -- Harbor core tables will be created by Harbor Core service
  -- This script is for initial setup only
  
  SELECT 'Database initialized successfully' as status;
EOSQL

echo "Harbor database initialized."
