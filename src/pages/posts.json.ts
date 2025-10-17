import { getSortedPosts } from "@utils/content-utils";
import type { APIContext } from "astro";

export async function GET(_context: APIContext): Promise<Response> {
    const blog = await getSortedPosts();
    const posts = blog.map((post) => ({
        title: post.data.title,
        description: post.data.description || "",
        published: post.data.published,
        tags: post.data.tags,
        link: `/posts/${post.slug}/`,
    }));

    return new Response(JSON.stringify(posts));
}