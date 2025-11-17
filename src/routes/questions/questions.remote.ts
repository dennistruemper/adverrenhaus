import { query } from '$app/server';
import { db } from '$lib/server/db';
import { questions } from '$lib/server/db/schema';

export const getQuestions = query(async () => {
	try {
		const allQuestions = await db.select().from(questions);
		return allQuestions;
	} catch (err) {
		console.error('Error loading questions:', err);
		throw new Error('Failed to load questions');
	}
});

