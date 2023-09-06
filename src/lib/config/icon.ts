import type { Icon } from '$lib/types/icon'
import { site } from '$lib/config/site'

export const favicon: Icon = {
  src: site.protocol + site.domain + '/favicon.png',
  sizes: '48x48',
  type: 'image/png'
}

export const any: { [key: number]: Icon } = {
  180: {
    src: site.protocol + site.domain + '/assets/any@180.png',
    sizes: '180x180',
    type: 'image/png'
  },
  192: {
    src: site.protocol + site.domain + '/assets/any@192.png',
    sizes: '192x192',
    type: 'image/png'
  },
  512: {
    src: site.protocol + site.domain + '/assets/any@512.png',
    sizes: '512x512',
    type: 'image/png'
  }
}

const githubAvatarUrl = "https://avatars.githubusercontent.com/u/33725716?v=4";
export const maskable: { [key: number]: Icon } = {
  192: {
    src: `${githubAvatarUrl}&size=192`,
    sizes: '192x192',
    type: 'image/png'
  },
  512: {
    src: `${githubAvatarUrl}&size=512`,
    sizes: '512x512',
    type: 'image/png'
  },
  1024: {
    src: `${githubAvatarUrl}&size=1024`,
    sizes: "1024x1024",
    type: "image/png"
  }
}
