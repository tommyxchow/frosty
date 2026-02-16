import type { NextConfig } from 'next'

if (process.env.NODE_ENV === 'development') {
  void import('@opennextjs/cloudflare').then(
    ({ initOpenNextCloudflareForDev }) => initOpenNextCloudflareForDev(),
  )
}

const nextConfig: NextConfig = {
  typedRoutes: true,
  reactCompiler: true,
  logging: {
    fetches: {
      fullUrl: true,
    },
  },
}

export default nextConfig
