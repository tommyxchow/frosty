# AGENTS.md

> **Monorepo note:** `web/` is a separate Next.js landing page with its own `AGENTS.md`. This file covers the Flutter app only.

## Workflow

- In plan mode, interview thoroughly — ask about UI/UX, tradeoffs, and edge cases before coding
- When new code supersedes existing functionality, find and remove everything it makes redundant
- Favor parallel tool calls and subagents when tasks are independent

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

## Architecture (non-obvious bits)

- Feature stores live in `lib/screens/{feature}/stores/` — don't create new top-level store files (only `lib/stores/` holds global stores)
- All API services extend `BaseApiClient` (`lib/apis/base_api_client.dart`) — don't create standalone API classes
- MobX stores use a generated mixin pattern — see `lib/screens/settings/stores/auth_store.dart` for the canonical example

## Gotchas

- After changing MobX stores or `@JsonSerializable` models, regenerate with `dart run build_runner build`. Never edit `.g.dart` files directly. Commit `.g.dart` files to source control.
- The secure storage cleanup in `main.dart` looks unnecessary but handles an Android/iOS edge case where secure storage persists after uninstall. Don't remove it.
- Use package imports (`import 'package:frosty/...'`), not relative imports
- Always include trailing commas
- Use single quotes

## Testing

- `flutter test` runs all tests; `flutter test test/path/to/file.dart` for a single file
- HTTP mocking: `http_mock_adapter` (`DioAdapter`) — use full URLs in `onGet`/`onPost`
- General mocking: `mocktail` (no codegen required)
- Fixtures live in `test/fixtures/` (e.g., `irc_messages.dart`, `api_responses.dart`)

## Commits

Lowercase, no prefixes (e.g., `fix landscape bottom padding in chat bottom bar`). Keep commits tightly scoped.
