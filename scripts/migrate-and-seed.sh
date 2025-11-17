#!/bin/bash
# Don't use set -e, we want to handle errors manually
set +e

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
echo "Command: bun run db:migrate"
bun run db:migrate 2>&1 | tee /tmp/migrate.log
MIGRATE_EXIT=${PIPESTATUS[0]}
if [ $MIGRATE_EXIT -eq 0 ]; then
  echo "✓ Migrations completed successfully"
else
  echo "ERROR: Migration failed with exit code: $MIGRATE_EXIT"
  echo "Migration output:"
  cat /tmp/migrate.log
  exit $MIGRATE_EXIT
fi

echo "Seeding database..."
echo "Command: bun run db:seed"
bun run db:seed 2>&1 | tee /tmp/seed.log
SEED_EXIT=${PIPESTATUS[0]}
if [ $SEED_EXIT -eq 0 ]; then
  echo "✓ Seeding completed successfully"
else
  echo "ERROR: Seeding failed with exit code: $SEED_EXIT"
  echo "Seed output:"
  cat /tmp/seed.log
  exit $SEED_EXIT
fi

echo "=== Migration and seeding completed successfully! ==="
exit 0

