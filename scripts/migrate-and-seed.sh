#!/bin/bash
set -e

echo "=== Migration and Seeding Script ==="

if [ -z "$DATABASE_URL" ]; then
  echo "ERROR: DATABASE_URL is not set!" >&2
  exit 1
fi

# Convert sslmode parameter to ssl parameter for the postgres library if needed
# The postgres library (used by drizzle-kit) uses ssl=true/ssl=1, not sslmode
# If sslmode=disable or sslmode is not present, explicitly set ssl=false
if [[ "$DATABASE_URL" == *"sslmode="* ]]; then
  # If sslmode=require or sslmode=prefer, convert to ssl=true (postgres library format)
  if [[ "$DATABASE_URL" == *"sslmode=require"* ]] || [[ "$DATABASE_URL" == *"sslmode=prefer"* ]]; then
    export DATABASE_URL=$(echo "$DATABASE_URL" | sed 's/sslmode=require/ssl=true/g')
    export DATABASE_URL=$(echo "$DATABASE_URL" | sed 's/sslmode=prefer/ssl=true/g')
    echo "Converted sslmode parameter to ssl parameter for postgres library"
  else
    # Remove sslmode parameter and explicitly set ssl=false for non-SSL connections
    export DATABASE_URL=$(echo "$DATABASE_URL" | sed 's/[;&]sslmode=[^;&]*//g')
    if [[ "$DATABASE_URL" == *"?"* ]]; then
      export DATABASE_URL="${DATABASE_URL}&ssl=false"
    else
      export DATABASE_URL="${DATABASE_URL}?ssl=false"
    fi
    echo "Removed sslmode parameter and set ssl=false (SSL disabled)"
  fi
else
  # If no sslmode parameter and no ssl parameter, explicitly disable SSL
  # This ensures the postgres library doesn't try to use SSL by default
  if [[ "$DATABASE_URL" != *"ssl="* ]]; then
    if [[ "$DATABASE_URL" == *"?"* ]]; then
      export DATABASE_URL="${DATABASE_URL}&ssl=false"
    else
      export DATABASE_URL="${DATABASE_URL}?ssl=false"
    fi
    echo "Explicitly set ssl=false to disable SSL"
  fi
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

