#!/bin/bash
set -e

echo "=== Migration and Seeding Script ==="

if [ -z "$DATABASE_URL" ]; then
  echo "ERROR: DATABASE_URL is not set!" >&2
  exit 1
fi

# Convert sslmode parameter to ssl parameter for the postgres library
# The postgres library (used by drizzle-kit) uses ssl=true/ssl=1, not sslmode
# Coolify and other managed databases often use sslmode=require which needs conversion
if [[ "$DATABASE_URL" == *"sslmode="* ]]; then
  # Replace sslmode=require/prefer with ssl=true (postgres library format)
  export DATABASE_URL=$(echo "$DATABASE_URL" | sed 's/sslmode=require/ssl=true/g')
  export DATABASE_URL=$(echo "$DATABASE_URL" | sed 's/sslmode=prefer/ssl=true/g')
  # Remove any remaining sslmode parameters (for non-SSL connections like sslmode=disable)
  export DATABASE_URL=$(echo "$DATABASE_URL" | sed 's/[;&]sslmode=[^;&]*//g')
  echo "Converted sslmode parameter to ssl parameter for postgres library"
fi

# Only add SSL for remote/managed databases, not local Docker Compose
# Detect local databases by checking for localhost, 127.0.0.1, or the 'db' service name
if [[ "$DATABASE_URL" != *"ssl="* ]] && [[ "$DATABASE_URL" != *"sslmode"* ]]; then
  if [[ "$DATABASE_URL" != *"@localhost"* ]] && \
     [[ "$DATABASE_URL" != *"@127.0.0.1"* ]] && \
     [[ "$DATABASE_URL" != *"@db:"* ]] && \
     [[ "$DATABASE_URL" != *"@db/"* ]]; then
    # This is a remote/managed database - add SSL
    if [[ "$DATABASE_URL" == *"?"* ]]; then
      export DATABASE_URL="${DATABASE_URL}&ssl=true"
    else
      export DATABASE_URL="${DATABASE_URL}?ssl=true"
    fi
    echo "Added ssl=true to DATABASE_URL for remote database connection"
  else
    echo "Local database detected - skipping SSL configuration"
  fi
fi

# Set NODE_TLS_REJECT_UNAUTHORIZED=0 if SSL certificate validation is causing issues
# WARNING: This disables certificate validation - only use for development/testing
# For production, ensure proper SSL certificates are configured
if [ "${DISABLE_SSL_VERIFY:-false}" = "true" ]; then
  export NODE_TLS_REJECT_UNAUTHORIZED=0
  echo "WARNING: SSL certificate verification disabled (DISABLE_SSL_VERIFY=true)"
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

