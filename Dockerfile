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

# Install all dependencies (drizzle-kit kept for potential manual operations)
# Migrations are handled by GitHub Actions CI/CD pipeline
RUN bun install --frozen-lockfile

# Copy built application
COPY --from=builder /app/build ./build

# Copy scripts (for optional seeding)
COPY scripts ./scripts
# Copy seed file for optional database seeding
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

# Use entrypoint for optional seeding (migrations handled by CI)
ENTRYPOINT ["/app/scripts/docker-entrypoint.sh"]

# Start the server
CMD ["bun", "run", "./build/index.js"]

