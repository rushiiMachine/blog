import type { ThemeConfig, HeadConfig, HeaderConfig, FooterConfig, DateConfig, FeedConfig } from '$lib/types/general'

export const theme: ThemeConfig = [
  {
    name: 'dracula',
    text: 'Dark'
  },
  {
    name: 'cmyk',
    text: 'Light'
  },
  {
    name: 'night',
    text: 'Night'
  },
  {
    name: 'black',
    text: 'Black'
  }
]

export const head: HeadConfig = {}

export const header: HeaderConfig = {
  nav: [
    {
      text: 'GitHub',
      link: 'https://github.com/rushiiMachine'
    },
  ]
}

export const footer: FooterConfig = {
  nav: [
    {
      text: 'Feed',
      link: '/atom.xml'
    },
    {
      text: 'Sitemap',
      link: '/sitemap.xml'
    },
    {
      text: "Source code",
      link: "https://github.com/rushiiMachine/blog"
    }
  ]
}

export const date: DateConfig = {
  locales: 'en-US',
  options: {
    year: 'numeric',
    weekday: 'long',
    month: 'short',
    day: 'numeric'
  }
}

export const feed: FeedConfig = {}
