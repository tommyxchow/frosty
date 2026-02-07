# AGENTS.md

## Workflow

- In plan mode, interview thoroughly — ask about UI/UX, tradeoffs, and edge cases before coding
- When new code supersedes existing functionality, find and remove everything it makes redundant
- Favor parallel tool calls and subagents when tasks are independent

## Architecture (non-obvious bits)

- Screens live in `lib/screens/{feature}/` with co-located `stores/` subdirectories — don't create top-level store files
- All API services extend `BaseApiClient` (`lib/apis/base_api_client.dart`) — don't create standalone API classes
- MobX stores use a generated mixin pattern — see `lib/screens/settings/stores/auth_store.dart` for the canonical example

## Gotchas

- Run requires Twitch credentials: `flutter run --dart-define=clientId=YOUR_ID --dart-define=secret=YOUR_SECRET`
- After changing MobX stores or `@JsonSerializable` models, run `dart run build_runner build`. Never edit `.g.dart` files directly. Use `--delete-conflicting-outputs` if the build fails on stale generated files. Commit `.g.dart` files to source control.
- The secure storage cleanup in `main.dart` looks unnecessary but handles an Android/iOS edge case where secure storage persists after uninstall. Don't remove it.
- Use package imports (`import 'package:frosty/...'`), not relative imports
- Always include trailing commas
- Use single quotes
- Run `flutter analyze` after making changes. Run `flutter test` if changes touch testable logic.

## Commits

Lowercase, no prefixes (e.g., `fix landscape bottom padding in chat bottom bar`). Keep commits tightly scoped.
