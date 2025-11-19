import { pgTable, serial, text } from 'drizzle-orm/pg-core';

export const test = pgTable('test', {
	id: text('id').primaryKey(),
	data: text('data')
});

export const questions = pgTable('questions', {
	id: serial('id').primaryKey(),
	question: text('question').notNull().unique(),
	answer: text('answer').notNull(),
	reward: text('reward').notNull().default('Good job!')
});
