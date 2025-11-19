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
			{
				question: 'What is the largest land animal?',
				answer: 'Elephant',
				reward: 'Excellent work!'
			},
			{ question: 'What is the fastest land animal?', answer: 'Cheetah', reward: 'Well done!' },
			{ question: 'What is the tallest animal?', answer: 'Giraffe', reward: 'Great job!' },
			{
				question: 'What animal is known as the king of the jungle?',
				answer: 'Lion',
				reward: 'Fantastic!'
			},
			{ question: 'What is a baby cat called?', answer: 'Kitten', reward: 'Awesome!' },
			{ question: 'What is a baby dog called?', answer: 'Puppy', reward: 'Brilliant!' },
			{ question: 'What is a group of lions called?', answer: 'Pride', reward: 'Perfect!' },
			{ question: 'What is a group of wolves called?', answer: 'Pack', reward: 'Outstanding!' },
			{ question: 'What is a group of fish called?', answer: 'School', reward: 'Superb!' },
			{ question: 'What is the largest mammal?', answer: 'Whale', reward: 'Amazing!' },
			{ question: 'What animal has the longest neck?', answer: 'Giraffe', reward: 'Wonderful!' },
			{ question: 'What is a baby horse called?', answer: 'Foal', reward: 'Terrific!' },
			{ question: 'What is a baby cow called?', answer: 'Calf', reward: 'Impressive!' },
			{ question: 'What is a baby sheep called?', answer: 'Lamb', reward: 'You got it!' },
			{ question: 'What is a baby pig called?', answer: 'Piglet', reward: 'Nice one!' },
			{ question: 'What is a baby duck called?', answer: 'Duckling', reward: 'Keep it up!' },
			{ question: 'What is a baby bear called?', answer: 'Cub', reward: 'You rock!' },
			{ question: 'What is a baby kangaroo called?', answer: 'Joey', reward: 'Way to go!' },
			{ question: 'What is a baby elephant called?', answer: 'Calf', reward: "That's right!" },
			{ question: 'What is a baby tiger called?', answer: 'Cub', reward: 'Spot on!' },
			{ question: 'What is a baby rabbit called?', answer: 'Bunny', reward: 'Correct!' },
			{ question: 'What is a baby owl called?', answer: 'Owlet', reward: 'You nailed it!' },
			{ question: 'What is a baby eagle called?', answer: 'Eaglet', reward: 'Perfect answer!' },
			{ question: 'What is a baby swan called?', answer: 'Cygnet', reward: 'Well played!' }
		])
		.onConflictDoUpdate({
			target: questions.question,
			set: {
				answer: sql`excluded.answer`,
				reward: sql`excluded.reward`
			}
		});

	console.log('Seed completed!');
	process.exit(0);
}

seed().catch((err) => {
	console.error('Error seeding database:', err);
	process.exit(1);
});
