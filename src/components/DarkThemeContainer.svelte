<script lang="ts">
import { onMount } from "svelte";

let { children } = $props();

let darkMode: boolean = $state(true);

onMount(() => {
	darkMode = !!document.documentElement.classList.contains("dark");

	const observer = new MutationObserver((_) => {
		darkMode = document.documentElement.classList.contains("dark");
	});
	observer.observe(document.documentElement, {
		attributes: true,
		attributeFilter: ["class"],
	});

	return () => {
		observer.disconnect();
	};
});
</script>

{#if darkMode}
    {@render children?.()}
{/if}
