import { sql } from 'drizzle-orm';
import { drizzle } from 'drizzle-orm/postgres-js';
import postgres from 'postgres';
import { questions } from './schema';

if (!process.env.DATABASE_URL) throw new Error('DATABASE_URL is not set');

const client = postgres(process.env.DATABASE_URL);
const db = drizzle(client);

async function seed() {
	console.log('Seeding database...');

	// Upsert 24 animal questions
	await db
		.insert(questions)
		.values([
			{ question: 'What is the largest land animal?', answer: 'Elephant' },
			{ question: 'What is the fastest land animal?', answer: 'Cheetah' },
			{ question: 'What is the tallest animal?', answer: 'Giraffe' },
			{ question: 'What animal is known as the king of the jungle?', answer: 'Lion' },
			{ question: 'What is a baby cat called?', answer: 'Kitten' },
			{ question: 'What is a baby dog called?', answer: 'Puppy' },
			{ question: 'What is a group of lions called?', answer: 'Pride' },
			{ question: 'What is a group of wolves called?', answer: 'Pack' },
			{ question: 'What is a group of fish called?', answer: 'School' },
			{ question: 'What is the largest mammal?', answer: 'Whale' },
			{ question: 'What animal has the longest neck?', answer: 'Giraffe' },
			{ question: 'What is a baby horse called?', answer: 'Foal' },
			{ question: 'What is a baby cow called?', answer: 'Calf' },
			{ question: 'What is a baby sheep called?', answer: 'Lamb' },
			{ question: 'What is a baby pig called?', answer: 'Piglet' },
			{ question: 'What is a baby duck called?', answer: 'Duckling' },
			{ question: 'What is a baby bear called?', answer: 'Cub' },
			{ question: 'What is a baby kangaroo called?', answer: 'Joey' },
			{ question: 'What is a baby elephant called?', answer: 'Calf' },
			{ question: 'What is a baby tiger called?', answer: 'Cub' },
			{ question: 'What is a baby rabbit called?', answer: 'Bunny' },
			{ question: 'What is a baby owl called?', answer: 'Owlet' },
			{ question: 'What is a baby eagle called?', answer: 'Eaglet' },
			{ question: 'What is a baby swan called?', answer: 'Cygnet' }
		])
		.onConflictDoUpdate({
			target: questions.question,
			set: {
				answer: sql`excluded.answer`
			}
		});

	console.log('Seed completed!');
	process.exit(0);
}

seed().catch((err) => {
	console.error('Error seeding database:', err);
	process.exit(1);
});
