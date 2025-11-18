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

# Database is already healthy due to depends_on condition, but add a small delay
# to ensure network is fully established
sleep 1

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

