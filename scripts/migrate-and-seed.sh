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
    # Remove sslmode parameter entirely for non-SSL connections
    export DATABASE_URL=$(echo "$DATABASE_URL" | sed 's/[;&]sslmode=[^;&]*//g')
    echo "Removed sslmode parameter (SSL disabled)"
  fi
fi

# Remove any existing ssl parameters if SSL is disabled
# The postgres library may try to use SSL if ssl parameter is present, even if set to false
# So we remove all ssl-related parameters entirely for non-SSL connections
if [[ "$DATABASE_URL" == *"ssl=false"* ]] || [[ "$DATABASE_URL" == *"ssl=0"* ]]; then
  export DATABASE_URL=$(echo "$DATABASE_URL" | sed 's/[;&]ssl=false//g')
  export DATABASE_URL=$(echo "$DATABASE_URL" | sed 's/[;&]ssl=0//g')
  export DATABASE_URL=$(echo "$DATABASE_URL" | sed 's/?ssl=false//g')
  export DATABASE_URL=$(echo "$DATABASE_URL" | sed 's/?ssl=0//g')
  echo "Removed ssl=false parameter (postgres library will use plain connection)"
fi

# Ensure no SSL parameters are present for non-SSL connections
# Clean up any trailing ? or & after removing parameters
export DATABASE_URL=$(echo "$DATABASE_URL" | sed 's/?$//' | sed 's/&$//')

echo "DATABASE_URL (after SSL configuration): ${DATABASE_URL}"
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

