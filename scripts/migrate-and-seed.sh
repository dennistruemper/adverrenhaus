#!/bin/bash
set -e

echo "=== Migration and Seeding Script ==="
echo "Waiting for database to be ready..."
sleep 2

if [ -z "$DATABASE_URL" ]; then
  echo "ERROR: DATABASE_URL is not set!"
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

