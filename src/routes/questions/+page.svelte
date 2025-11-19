<script lang="ts">
	import { getQuestions } from './questions.remote';

	// Call remote function directly with top-level await
	let questions = await getQuestions();
</script>

<div class="container mx-auto px-4 py-8">
	<h1 class="mb-8 text-4xl font-bold text-gray-900">Animal Questions</h1>

	{#if questions.length === 0}
		<div class="rounded-lg border border-yellow-200 bg-yellow-50 p-6 text-center">
			<p class="text-yellow-800">No questions found. Run the seed script to add questions.</p>
		</div>
	{:else}
		<div class="grid gap-6 md:grid-cols-2 lg:grid-cols-3">
			{#each questions as question}
				<div
					class="rounded-lg border border-gray-200 bg-white p-6 shadow-md transition-shadow hover:shadow-lg"
				>
					<div class="mb-4">
						<h2 class="mb-2 text-xl font-semibold text-gray-800">{question.question}</h2>
						<div class="mb-2 flex items-center gap-2">
							<span class="text-sm text-gray-500">Answer:</span>
							<span class="text-lg font-medium text-blue-600">{question.answer}</span>
						</div>
						<div class="flex items-center gap-2">
							<span class="text-sm text-gray-500">Reward:</span>
							<span class="text-lg font-medium text-green-600">{question.reward}</span>
						</div>
					</div>
					<div class="text-xs text-gray-400">ID: {question.id}</div>
				</div>
			{/each}
		</div>
		<div class="mt-8 text-center text-gray-600">
			<p>Total questions: {questions.length}</p>
		</div>
	{/if}
</div>
