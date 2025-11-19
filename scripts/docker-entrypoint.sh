#!/bin/bash
set -e

echo "=== Docker Entrypoint ==="

# Migrations are now handled by GitHub Actions CI/CD pipeline
# Only run seeding if explicitly requested (for local development or manual seeding)
if [ "${RUN_SEED:-false}" = "true" ]; then
  if [ -n "$DATABASE_URL" ] && [ -f /app/scripts/migrate-and-seed.sh ]; then
    echo "Running database seeding (migrations skipped - handled by CI)..."
    # Run only seeding, skip migrations
    if [ -f /app/src/lib/server/db/seed.ts ]; then
      bun run db:seed
      echo "✓ Seeding completed successfully"
    else
      echo "WARNING: Seed file not found, skipping seeding"
    fi
  else
    echo "WARNING: DATABASE_URL not set or seed script not found, skipping seeding"
  fi
else
  echo "Skipping seeding (RUN_SEED not set to true)"
  echo "Migrations are handled by GitHub Actions CI/CD pipeline"
fi

echo "=== Starting application ==="
# Execute the main command (start the app)
exec "$@"

