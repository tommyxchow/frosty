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

- Package imports (`import 'package:frosty/...'`), not relative imports
- `UPPER_SNAKE_CASE` for constants
- Derive state where possible — avoid duplicating what can be computed (MobX `@computed`)
- Trailing commas always
- Single quotes
- Inline until a pattern repeats 3+ times, then extract
- Extract related/grouped logic (state, reactions, actions) into dedicated stores when it improves readability — keep widgets focused on rendering

## Quality Priorities

In order: **correctness → user experience → simplicity → security**.

Not priorities: WCAG compliance (easy wins only), public accessibility, SEO, progressive enhancement.

## Tool Preferences

- Prefer LSP over Grep for semantic navigation:
  - `findReferences` before changing a function/widget signature (no false positives)
  - `hover` to resolve inferred/computed types (generics, MobX computed properties)
  - `goToDefinition` to navigate through re-exports and barrel files
  - `incomingCalls`/`outgoingCalls` to trace call chains across screens, stores, widgets
- When debugging third-party packages, **read the package source in the pub cache first** — don't speculate about behavior. Check for validation, protocol restrictions, and attribute filtering before writing code.

## UI Patterns

- When UI visibility depends on an async operation (modals, banners, gates), default to hidden and only show after loading completes — never let a default value flash the UI while a request is in flight.
- Adapt external designs (Figma specs, reference implementations) to codebase conventions before implementing. External descriptions may contain AI-generated rough drafts — always cross-reference against actual codebase patterns.

## Infrastructure Checklist

When creating new infrastructure (screens, API clients, stores), use exploration findings as a **checklist** — systematically verify each convention is followed before writing code.

## Code Review

- Label severity: `critical` / `major` / `minor`
- Prefer minimal, tightly scoped diffs — don't switch layout strategies (e.g., Column to Stack) unless explicitly asked, as it often breaks dependent sizing
- Flag unnecessary complexity with a simpler alternative

## Testing

- Suggest tests when changes touch logic, but don't write tests unless asked.
- Run targeted tests for relevant files, not the full suite.
- After finishing implementation that touches logic or adds new code paths, present a concrete list of test cases that should be added or updated. List each as a one-line description (happy path, sad path, edge cases). Surface this clearly, don't bury it.

## Commit Convention

Lowercase, no prefixes (e.g., `fix landscape bottom padding in chat bottom bar`). Keep commits tightly scoped.

## Branching

New branches: prefix with `tommy/` (e.g., `tommy/add-auth-flow`).

## Aliases

- **"vet"** means: review code for correctness/quality, verify claims against external sources (web search), and flag anything suspicious.

## Never

- Never edit `.g.dart` files directly — always regenerate with `dart run build_runner build`

---

# Project

Flutter mobile app for browsing Twitch on iOS and Android. Uses MobX for state management with code generation.

## Commands

```bash
flutter pub get                                                     # Install dependencies
flutter run --dart-define=clientId=ID --dart-define=secret=SECRET   # Run with Twitch credentials
flutter analyze                                                     # Static analysis (run after changes)
flutter test                                                        # Run tests (if changes touch testable logic)
dart run build_runner build                                         # Regenerate .g.dart files (MobX/JSON models)
dart run build_runner build --delete-conflicting-outputs             # Same, but clears stale outputs
```

## Source Structure

- `lib/apis/` — API services (all extend `BaseApiClient`)
- `lib/models/` — Data models (`@JsonSerializable` with `.g.dart` codegen)
- `lib/screens/{feature}/` — Feature screens with co-located `stores/` subdirectories
- `lib/stores/` — Global stores only (e.g., `global_assets_store.dart`)
- `lib/services/` — App-level services
- `lib/widgets/` — Shared widgets
- `lib/utils/` — Utility functions

## Architecture

- Feature stores live in `lib/screens/{feature}/stores/` — don't create new top-level store files (only `lib/stores/` holds global stores)
- All API services extend `BaseApiClient` (`lib/apis/base_api_client.dart`) — don't create standalone API classes
- MobX stores use a generated mixin pattern — see `lib/screens/settings/stores/auth_store.dart` for the canonical example

## Gotchas

- After changing MobX stores or `@JsonSerializable` models, regenerate with `dart run build_runner build`. Never edit `.g.dart` files directly. Commit `.g.dart` files to source control.
- The secure storage cleanup in `main.dart` looks unnecessary but handles an Android/iOS edge case where secure storage persists after uninstall. Don't remove it.

## Testing

- `flutter test` runs all tests; `flutter test test/path/to/file.dart` for a single file
- HTTP mocking: `http_mock_adapter` (`DioAdapter`) — use full URLs in `onGet`/`onPost`
- General mocking: `mocktail` (no codegen required)
- Fixtures live in `test/fixtures/` (e.g., `irc_messages.dart`, `api_responses.dart`)
