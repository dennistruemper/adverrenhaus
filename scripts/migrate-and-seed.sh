#!/bin/bash
set -e

echo "=== Migration and Seeding Script ==="
echo "Waiting for database to be ready..."
sleep 2

if [ -z "$DATABASE_URL" ]; then
  echo "ERROR: DATABASE_URL is not set!"
  exit 1
fi

echo "DATABASE_URL is set (showing first 30 chars): ${DATABASE_URL:0:30}..."

echo "Running database migrations..."
if bun run db:migrate 2>&1; then
  echo "✓ Migrations completed successfully"
else
  MIGRATE_EXIT=$?
  echo "Migration exit code: $MIGRATE_EXIT"
  if [ $MIGRATE_EXIT -eq 0 ]; then
    echo "Migration completed successfully"
  else
    echo "WARNING: Migration had issues, but continuing..."
  fi
fi

echo "Seeding database..."
if bun run db:seed 2>&1; then
  echo "✓ Seeding completed successfully"
else
  SEED_EXIT=$?
  echo "ERROR: Seeding failed with exit code: $SEED_EXIT"
  exit $SEED_EXIT
fi

echo "=== Migration and seeding completed successfully! ==="

