import type { SiteConfig } from '$lib/types/site'

export const site: SiteConfig = {
  protocol: import.meta.env.URARA_SITE_PROTOCOL ?? import.meta.env.DEV ? 'http://' : 'https://',
  domain: import.meta.env.URARA_SITE_DOMAIN ?? "blog.rushii.dev",
  title: 'rushii',
  subtitle: 'personal blog for dumb shit',
  lang: 'en-US',
  description: 'personal blog for dumb shit',
  author: {
    avatar: "https://avatars.githubusercontent.com/u/33725716?v=4",
    name: 'rushii',
    bio: 'I love reverse engineering android apps, jetpack compose, and kotlin',
    metadata: [
      {
        icon: "i-simple-icons-github",
        link: "https://github.com/rushiiMachine",
      }
    ]
  },
  themeColor: '#3D4451'
}
