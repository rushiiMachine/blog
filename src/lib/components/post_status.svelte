<script lang="ts">
  import { date } from '$lib/config/general'
  import { site } from '$lib/config/site'
  export let post: Urara.Post
  export let preview: boolean = false
  const stringPublished = new Date(post.published ?? post.created).toLocaleString(date.locales, date.options)
  const stringUpdated = new Date(post.updated).toLocaleString(date.locales, date.options)
  const jsonPublished = new Date(post.published ?? post.created).toJSON()
  const jsonUpdated = new Date(post.updated).toJSON()
</script>

<div class:md:mb-4={!preview && post.type !== 'article'} class="flex font-semibold gap-1.5 overflow-x-auto whitespace-nowrap ">
  <a
    class:hidden={preview}
    rel="author"
    class="opacity-75 hover:opacity-100 hover:text-primary duration-500 ease-in-out p-author h-card"
    href={site.protocol + site.domain}>
    {site.author.name}
  </a>
  <span class:hidden={preview} class="opacity-50">/</span>
  <time
    class="font-semibold opacity-75 dt-published"
    datetime={jsonPublished}
    itemprop="datePublished">
    {stringPublished}
  </time>

  {#if post.updated}
    <span class="opacity-50">/</span>
    <time
      class="opacity-50 font-semibold mr-auto dt-updated"
      datetime={jsonUpdated}
      itemprop="dateModified">
    {stringUpdated}
    </time>
  {/if}
</div>
