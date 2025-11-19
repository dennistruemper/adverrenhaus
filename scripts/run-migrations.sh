#!/bin/bash
set -e

echo "=== Running Database Migrations ==="

if [ -z "$DATABASE_URL" ]; then
  echo "ERROR: DATABASE_URL is not set!" >&2
  exit 1
fi

echo "Running database migrations..."
if bun run db:migrate; then
  echo "✓ Migrations completed successfully"
  exit 0
else
  MIGRATE_EXIT=$?
  echo "ERROR: Migration failed with exit code: $MIGRATE_EXIT" >&2
  exit $MIGRATE_EXIT
fi

