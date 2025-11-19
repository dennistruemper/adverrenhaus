FROM oven/bun:1 AS builder

WORKDIR /app

# Copy package files
COPY package.json bun.lock* bun.lockb* ./

# Install all dependencies (needed for build)
RUN bun install --frozen-lockfile

# Copy project files
COPY . .

# Build the application
RUN bun run build

# Production stage
FROM oven/bun:1

WORKDIR /app

# Copy package files
COPY package.json bun.lock* bun.lockb* ./

# Install all dependencies (including drizzle-kit for migrations if needed)
# In production, you might want --production, but keep dev deps if you run migrations
RUN bun install --frozen-lockfile

# Copy built application
COPY --from=builder /app/build ./build

# Copy migration files and scripts (for runtime migrations if needed)
COPY drizzle ./drizzle
COPY drizzle.config.ts ./
COPY scripts ./scripts
# Copy seed file for database seeding
COPY src/lib/server/db/seed.ts ./src/lib/server/db/seed.ts
COPY src/lib/server/db/schema.ts ./src/lib/server/db/schema.ts

# Make scripts executable
RUN chmod +x scripts/*.sh

# Expose port
EXPOSE 3000

# Set environment variables
ENV PORT=3000
ENV HOST=0.0.0.0
ENV NODE_ENV=production

# Use entrypoint to run migrations at runtime before starting the app
ENTRYPOINT ["/app/scripts/docker-entrypoint.sh"]

# Start the server
CMD ["bun", "run", "./build/index.js"]

