# AGENTS.md

---

# Author Preferences

## Infrastructure Checklist

When creating new infrastructure (routes, API handlers, providers), use exploration findings as a **checklist** — systematically verify each convention is followed before writing code.

---

# Project

Next.js 16 landing page for [Frosty](https://frostyapp.io) using the App Router with React 19. Deployed on **Cloudflare Workers** via `@opennextjs/cloudflare`.

## Commands

```bash
pnpm dev          # Start development server
pnpm build        # Production build
pnpm start        # Start production server (Node.js)
pnpm preview      # Build and preview on local Cloudflare Workers
pnpm deploy       # Build and deploy to Cloudflare Workers
pnpm upload       # Build and upload to Cloudflare Workers (no deploy)
pnpm cf-typegen   # Generate CloudflareEnv types from wrangler.jsonc
pnpm lint         # Run ESLint
pnpm typecheck    # TypeScript type checking (tsc --noEmit)
pnpm format       # Format with Prettier
pnpm clean        # Delete .next, .open-next, and node_modules
pnpm nuke         # Delete .next, .open-next, node_modules, and pnpm-lock.yaml
```

## Source Structure

- `src/app/` - App Router pages and layouts
- `src/components/` - React components (`ui/` subdirectory for shadcn `base-vega` style — add with `pnpm dlx shadcn@latest add <component>`)
- `src/lib/` - Utilities (`cn()` for className merging, `constants.ts` for external links)
- `src/assets/` - Static images (screenshots)

## Key Configuration

- **React Compiler**: Enabled in `next.config.ts` for automatic memoization
- **Typed Routes**: Enabled for type-safe navigation (use `Route` type from `next/navigation`)
- **Path Alias**: `@/*` maps to `./src/*`
- **Strict TypeScript**: `noUncheckedIndexedAccess`, `noImplicitReturns`, `noFallthroughCasesInSwitch`, `noImplicitOverride`, `verbatimModuleSyntax`

## Cache Components

Not yet enabled — `cacheComponents` is not set in `next.config.ts` and no `"use cache"` directives are in use. Everything is dynamic (SSR) by default. To opt in: add `cacheComponents: true` to `next.config.ts`, use `"use cache"` + `cacheLife()` on server components/functions, and wrap async work in `<Suspense>` for PPR. Durable runtime cache requires R2 incremental cache (see `open-next.config.ts`) — without it, cache is in-memory only per Worker instance.

## Cloudflare Workers

- `wrangler.jsonc` - Cloudflare Workers configuration (bindings, R2, KV, etc.)
- `open-next.config.ts` - OpenNext adapter config (ISR requires uncommenting R2 incremental cache)
- `cloudflare-env.d.ts` - Generated types for Cloudflare bindings (run `pnpm cf-typegen` to regenerate)
- Dev mode calls `initOpenNextCloudflareForDev()` in `next.config.ts` for local Cloudflare emulation

## Naming Conventions

- Components: PascalCase (`Button.tsx`)
- Utilities: camelCase (`formatDate.ts`)
- Hooks: `use` prefix (`useDebounce.ts`)
- Types: PascalCase (`UserProfile`)

## ESLint Rules

Config: `eslint.config.mjs`. Ignores `src/components/ui/`.

Notable strict rules enforced:

- `eqeqeq: 'smart'` - Strict equality (except `== null`)
- `no-console` - Warn on console usage (allows `console.warn` and `console.error`)
- `@typescript-eslint/strict-boolean-expressions` - No implicit boolean coercion (but `allowNullableBoolean` and `allowNullableString` are enabled)
- `@typescript-eslint/switch-exhaustiveness-check` - Exhaustive switch statements
- `@typescript-eslint/consistent-type-imports` - Use `import type` for types (`fixStyle: 'inline-type-imports'`)
- `@typescript-eslint/no-unnecessary-condition` - No redundant conditions
- `@typescript-eslint/no-misused-promises` - Prevent floating promises (`checksVoidReturn.attributes` disabled for JSX)
- `@eslint-react/jsx-shorthand-boolean` - Use shorthand boolean JSX props
- `@eslint-react/no-array-index-key` - Warn on array index as key
- `react-you-might-not-need-an-effect` - Avoid unnecessary useEffect
- Unused variables must be prefixed with `_`

## Gotchas

- **shadcn uses @base-ui/react**: Not Radix UI — component primitives differ from older shadcn examples. `button.tsx` is a `'use client'` module with no `asChild` prop. Check `src/components/ui/` before building custom UI.
- **`useSearchParams()` needs Suspense**: Always wrap components using `useSearchParams()` in a `<Suspense>` boundary — required for production builds.
- **Never remove `tw-animate-css`**: Required by shadcn/ui components for animations. Check shadcn dependencies before removing any package.
- **No `pnpm` prefix inside package.json scripts**: The package manager is already the script runner. Use bare commands (e.g., `next build`, not `pnpm next build`).

## Dev Tooling

- **Prettier**: Auto-sorts imports (`prettier-plugin-organize-imports`) and Tailwind classes (`prettier-plugin-tailwindcss`)
- **react-scan**: Runtime render performance visualization (dev only)
