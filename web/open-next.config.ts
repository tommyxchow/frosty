import { defineCloudflareConfig } from '@opennextjs/cloudflare'
// import r2IncrementalCache from '@opennextjs/cloudflare/overrides/incremental-cache/r2-incremental-cache'

export default defineCloudflareConfig({
  // Enable when using ISR — requires R2 bucket in wrangler.jsonc
  // incrementalCache: r2IncrementalCache,
})
