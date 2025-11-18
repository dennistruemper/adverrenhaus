#!/bin/bash
set -e

echo "=== Migration and Seeding Script ==="

if [ -z "$DATABASE_URL" ]; then
  echo "ERROR: DATABASE_URL is not set!" >&2
  exit 1
fi

echo "Running database migrations..."
echo "Migration files available:"
ls -la drizzle/*.sql 2>/dev/null || echo "No migration files found in drizzle/"

DB_HOST=$(echo "$DATABASE_URL" | sed -E 's#.*@([^:/?]+).*#\1#')
if [ -n "$DB_HOST" ]; then
  echo "Resolved database host: $DB_HOST"
  ATTEMPT=0
  MAX_ATTEMPTS=30
  until getent hosts "$DB_HOST" >/dev/null 2>&1; do
    ATTEMPT=$((ATTEMPT + 1))
    if [ $ATTEMPT -ge $MAX_ATTEMPTS ]; then
      echo "ERROR: Unable to resolve database host '$DB_HOST' after $MAX_ATTEMPTS attempts" >&2
      exit 1
    fi
    echo "Waiting for DNS entry for '$DB_HOST' (attempt $ATTEMPT/$MAX_ATTEMPTS)..."
    sleep 1
  done
else
  echo "WARNING: Could not determine database host from DATABASE_URL"
fi

if bun run db:migrate 2>&1; then
  echo "✓ Migrations completed successfully"
else
  MIGRATE_EXIT=$?
  echo "ERROR: Migration failed with exit code: $MIGRATE_EXIT" >&2
  exit $MIGRATE_EXIT
fi

# Seeding is optional - controlled by RUN_SEED environment variable
if [ "${RUN_SEED:-true}" = "true" ]; then
  echo "Seeding database..."
  if bun run db:seed; then
    echo "✓ Seeding completed successfully"
  else
    SEED_EXIT=$?
    echo "ERROR: Seeding failed with exit code: $SEED_EXIT" >&2
    exit $SEED_EXIT
  fi
fi

echo "=== Migration and seeding completed successfully! ==="
exit 0

