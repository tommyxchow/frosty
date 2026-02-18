import type { MetadataRoute } from 'next'

export default function sitemap(): MetadataRoute.Sitemap {
  return [
    { url: 'https://frostyapp.io', lastModified: new Date(), priority: 1 },
    {
      url: 'https://frostyapp.io/privacy',
      lastModified: new Date(),
      priority: 0.3,
    },
  ]
}
