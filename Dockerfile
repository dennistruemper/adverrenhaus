FROM oven/bun:1 AS builder

WORKDIR /app

# Copy package files (prefer bun.lock over bun.lockb)
COPY package.json bun.lock* bun.lockb* ./

# Install dependencies
RUN bun install --frozen-lockfile

# Copy project files
COPY . .

# Build the application
RUN bun run build

# Production stage
FROM oven/bun:1

WORKDIR /app

# Copy package files (prefer bun.lock over bun.lockb)
COPY package.json bun.lock* bun.lockb* ./

# Install production dependencies only
RUN bun install --frozen-lockfile --production

# Copy built application
COPY --from=builder /app/build ./build

# Expose port
EXPOSE 3000

# Set environment variables
ENV PORT=3000
ENV HOST=0.0.0.0
ENV NODE_ENV=production

# Start the server
CMD ["bun", "run", "./build/index.js"]

