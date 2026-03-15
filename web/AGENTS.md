# AGENTS.md

---

# Author Preferences

## Behavior

- When asked to add items to a list (models, emotes, constants, etc.), be thorough on the first pass. Read the source data completely and add ALL relevant items, not just the first few.
- In plan mode, interview thoroughly — ask about technical implementation, UI/UX, tradeoffs, and edge cases before coding. Don't begin implementation until all important details are resolved. For refactors: summary → trade-offs → next steps.
- When implementing new code, search the codebase for existing usages and follow established patterns.
- When new code supersedes existing functionality, find and remove everything it makes redundant.
- When asked to "verify", always use web search to check current documentation and sources before responding. Do not rely solely on training data.
- Favor parallel tool calls and subagents when tasks are independent.

## Code Opinions

- Named exports only — no default exports except where required by Next.js (page, layout, route, etc.)
- `satisfies` over `as` for type validation
- `UPPER_SNAKE_CASE` for constants
- Derive state where possible — avoid duplicating what can be computed
- Avoid `useRef` unless DOM access or imperative work
- Inline until a pattern repeats 3+ times, then extract
- Extract related/grouped logic (state, effects, handlers) into dedicated custom hooks when it improves readability — keep components focused on rendering
- For new components/hooks/APIs: include a usage example

## Quality Priorities

In order: **correctness → user experience → simplicity → security**.

Not priorities: WCAG compliance (easy wins only), public accessibility, SEO, progressive enhancement.

## Tool Preferences

- Prefer LSP over Grep for semantic navigation:
  - `findReferences` before changing a function/component signature (no false positives)
  - `hover` to resolve inferred/computed types (tRPC routers, Drizzle schemas, generics)
  - `goToDefinition` to navigate through re-exports and barrel files
  - `incomingCalls`/`outgoingCalls` to trace call chains across routes, hooks, components
- When debugging third-party libraries, **read the extension source in `node_modules` first** — don't speculate about behavior. Check for validation, protocol restrictions, and attribute filtering before writing code.

## UI Patterns

- When UI visibility depends on an async query (modals, banners, gates), default to hidden and only show after loading completes — never let `defaultValue` flash the UI while the query is in flight.
- Adapt external designs (Figma specs, reference implementations) to codebase conventions before implementing. External descriptions may contain AI-generated rough drafts — always cross-reference against actual codebase patterns.

## Infrastructure Checklist

When creating new infrastructure (routes, API handlers, providers), use exploration findings as a **checklist** — systematically verify each convention is followed before writing code.

## Code Review

- Label severity: `critical` / `major` / `minor`
- Prefer minimal, tightly scoped diffs — don't switch layout strategies (e.g., grid to flex) unless explicitly asked, as it often breaks dependent sizing
- Flag unnecessary complexity with a simpler alternative

## Testing

- Suggest tests when changes touch logic, but don't write tests unless asked.
- Run targeted tests for relevant files, not the full suite.
- After finishing implementation that touches backend logic or adds new code paths, present a concrete list of test cases that should be added or updated. List each as a one-line description (happy path, sad path, edge cases). Surface this clearly, don't bury it.

## Commit Convention

Lowercase, no prefixes (e.g., `remove marquee emote background from hero section`). Keep commits tightly scoped.

## Branching

New branches: prefix with `tommy/` (e.g., `tommy/add-auth-flow`).

## Aliases

- **"vet"** means: review code for correctness/quality, verify claims against external sources (web search), and flag anything suspicious.

## Never

- Never use `npm`, `npx`, or `yarn` — always use `pnpm` / `pnpx`

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

Enabled ([docs](https://nextjs.org/docs/app/getting-started/cache-components)) — everything is dynamic (SSR) by default. Opt into caching with `"use cache"` + `cacheLife()`, wrap async work in `<Suspense>` for PPR. Old `revalidate`/`dynamic`/`fetchCache` exports are replaced. Use `cacheTag()` + `revalidateTag()`/`updateTag()` for on-demand invalidation. Durable runtime cache requires R2 incremental cache (see `open-next.config.ts`) — without it, cache is in-memory only per Worker instance.

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
