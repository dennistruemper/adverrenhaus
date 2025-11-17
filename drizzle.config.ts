import { defineConfig } from 'drizzle-kit';

export default defineConfig({
	schema: './src/lib/server/db/schema.ts',
	dialect: 'postgresql',
	dbCredentials: {
		url: process.env.DATABASE_URL || '' // Will be validated when drizzle-kit runs
	},
	verbose: true,
	strict: true
});
