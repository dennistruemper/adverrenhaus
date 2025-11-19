#!/bin/bash
set -e

echo "=== Docker Entrypoint ==="

# Always run migrations at runtime before starting the app
if [ -n "$DATABASE_URL" ] && [ -f /app/scripts/migrate-and-seed.sh ]; then
  echo "Running migrations at runtime..."
  bash /app/scripts/migrate-and-seed.sh
else
  echo "ERROR: DATABASE_URL not set or migrate-and-seed.sh not found!" >&2
  exit 1
fi

echo "=== Starting application ==="
# Execute the main command (start the app)
exec "$@"

