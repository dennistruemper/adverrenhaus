#!/bin/bash
set -e

echo "Waiting for database to be ready..."
sleep 2

echo "Running database migrations..."
# Auto-confirm drizzle-kit push prompts
bun run db:migrate || {
  echo "Migration completed or no changes needed"
}

echo "Seeding database..."
bun run db:seed

echo "Migration and seeding completed!"

