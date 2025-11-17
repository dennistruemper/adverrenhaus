#!/bin/bash
set -e  # Exit on error

echo "=== Migration and Seeding Script ==="
echo "Current working directory: $(pwd)"
echo "Listing /app directory:"
ls -la /app/ | head -20 || echo "Cannot list /app"

# Wait for database to be ready
# Docker Compose healthcheck ensures db is healthy before this service starts
# But we add a small delay to ensure the connection is fully established
echo "Waiting for database connection to be established..."
sleep 2
echo "✓ Database should be ready (healthcheck passed)"

if [ -z "$DATABASE_URL" ]; then
  echo "ERROR: DATABASE_URL is not set!" >&2
  exit 1
fi

# Fix DATABASE_URL if it uses localhost - replace with service name 'db'
# Coolify sets localhost, but in Docker Compose we need the service name
if [[ "$DATABASE_URL" == *"@localhost"* ]] || [[ "$DATABASE_URL" == *"@127.0.0.1"* ]]; then
  echo "WARNING: DATABASE_URL contains localhost, replacing with service name 'db'"
  DATABASE_URL=$(echo "$DATABASE_URL" | sed 's/@localhost/@db/g' | sed 's/@127.0.0.1/@db/g')
  export DATABASE_URL
fi

echo "DATABASE_URL is set (showing first 50 chars): ${DATABASE_URL:0:50}..."

# Check if migration files exist
if [ -d "drizzle" ] && [ -n "$(ls -A drizzle/*.sql 2>/dev/null)" ]; then
  echo "Found migration files in drizzle/ directory"
  ls -la drizzle/*.sql
else
  echo "WARNING: No migration files found in drizzle/ directory"
  echo "This might be expected if migrations haven't been generated yet"
fi

echo ""
echo "Running database migrations..."
echo "Command: bun run db:migrate"
if bun run db:migrate; then
  echo "✓ Migrations completed successfully"
else
  MIGRATE_EXIT=$?
  echo "ERROR: Migration failed with exit code: $MIGRATE_EXIT" >&2
  exit $MIGRATE_EXIT
fi

# Seeding is optional - controlled by RUN_SEED environment variable
# Default to true for backward compatibility, but can be disabled in production
if [ "${RUN_SEED:-true}" = "true" ]; then
  echo ""
  echo "Seeding database..."
  echo "Command: bun run db:seed"
  if bun run db:seed; then
    echo "✓ Seeding completed successfully"
  else
    SEED_EXIT=$?
    echo "ERROR: Seeding failed with exit code: $SEED_EXIT" >&2
    exit $SEED_EXIT
  fi
else
  echo ""
  echo "Skipping seeding (RUN_SEED=false)"
fi

echo ""
echo "=== Migration and seeding completed successfully! ==="
exit 0

