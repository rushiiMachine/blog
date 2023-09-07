<script lang="ts">
  import { site } from '$lib/config/site'
  import { any, maskable } from '$lib/config/icon'
  export let post: Urara.Post | undefined = undefined
  export let page: Urara.Page | undefined = undefined
</script>

<svelte:head>
  <meta property="og:site_name" content={site.title} />
  <meta property="og:locale" content={site.lang} />
  {#if post}
    <meta property="og:type" content="article" />
    <meta property="og:title" content={post.title ?? post.summary ?? post.path.slice(1)} />
    <meta content="{site.themeColor}" data-react-helmet="true" name="theme-color" />
    {#if post.summary}
      <meta property="og:description" content={post.summary} />
    {/if}
    {#if post.embedImage}
      <meta property="og:image" content={(post.embedImage.startsWith('http') ? '' : site.protocol + site.domain) + post.embedImage} />
      <meta name="twitter:card" content="summary_large_image" />
    {:else if post.embedPreview}
      <meta property="og:image" content={(post.embedPreview.startsWith('http') ? '' : site.protocol + site.domain) + post.embedPreview} />
      <meta name="twitter:card" content="summary" />
    {:else}
      <meta property="og:image" content={maskable['512'].src ?? any['512'].src ?? any['192'].src} />
      <meta name="twitter:card" content="summary" />
    {/if}
    {#if post.tags}
      {#each post.tags as tag}
        <meta property="article:tag" content={tag} />
      {/each}
    {/if}
    <meta property="og:url" content={site.protocol + site.domain + post.path} />
    <meta property="article:author" content={site.author.name} />
    <meta property="article:published_time" content={post.published ?? post.created} />
    {#if post.updated}
      <meta property="article:modified_time" content={post.updated} />
    {/if}
  {:else}
    <meta property="og:type" content="website" />
    <meta property="og:image" content={maskable['512'].src ?? any['512'].src ?? any['192'].src} />
    <meta property="og:description" content={site.description} />
    {#if page}
      <meta property="og:title" content={page.title ?? page.path.slice(1)} />
      <meta property="og:url" content={site.protocol + site.domain + page.path} />
    {:else}
      <meta property="og:title" content={site.title} />
      <meta property="og:url" content={site.protocol + site.domain} />
    {/if}
  {/if}
</svelte:head>
