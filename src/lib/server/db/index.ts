import { drizzle } from 'drizzle-orm/postgres-js';
import postgres from 'postgres';
import * as schema from './schema';
import { env } from '$env/dynamic/private';

let _client: ReturnType<typeof postgres> | null = null;
let _db: ReturnType<typeof drizzle> | null = null;

function getClient() {
	if (!_client) {
		if (!env.DATABASE_URL) throw new Error('DATABASE_URL is not set');
		_client = postgres(env.DATABASE_URL);
	}
	return _client;
}

export const db = new Proxy({} as ReturnType<typeof drizzle>, {
	get(_target, prop) {
		if (!_db) {
			_db = drizzle(getClient(), { schema });
		}
		return (_db as any)[prop];
	}
});
