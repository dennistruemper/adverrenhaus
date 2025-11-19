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

# Copy migration files (needed if running migrations in container)
COPY drizzle ./drizzle
COPY drizzle.config.ts ./
COPY scripts ./scripts

# Expose port
EXPOSE 3000

# Set environment variables
ENV PORT=3000
ENV HOST=0.0.0.0
ENV NODE_ENV=production

# Start the server
CMD ["bun", "run", "./build/index.js"]

