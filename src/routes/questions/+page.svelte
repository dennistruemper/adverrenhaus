<script lang="ts">
	import { getQuestions } from './questions.remote';

	// Call remote function directly with top-level await
	let questions = await getQuestions();
</script>

<div class="container mx-auto px-4 py-8">
	<h1 class="text-4xl font-bold mb-8 text-gray-900">Animal Questions</h1>

	{#if questions.length === 0}
		<div class="bg-yellow-50 border border-yellow-200 rounded-lg p-6 text-center">
			<p class="text-yellow-800">No questions found. Run the seed script to add questions.</p>
		</div>
	{:else}
		<div class="grid gap-6 md:grid-cols-2 lg:grid-cols-3">
			{#each questions as question}
				<div class="bg-white rounded-lg shadow-md p-6 border border-gray-200 hover:shadow-lg transition-shadow">
					<div class="mb-4">
						<h2 class="text-xl font-semibold text-gray-800 mb-2">{question.question}</h2>
						<div class="flex items-center gap-2">
							<span class="text-sm text-gray-500">Answer:</span>
							<span class="text-lg font-medium text-blue-600">{question.answer}</span>
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
