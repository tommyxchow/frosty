# AGENTS.md

---

# Author Preferences

## Code Opinions

- Extract related/grouped logic (state, reactions, actions) into dedicated stores when it improves readability — keep widgets focused on rendering
- Default to writing tests: new or changed logic (stores, API clients, parsing, utils) ships with tests; when touching existing tested code, update or extend its tests. Pure UI/rendering or config changes may skip.

## Infrastructure Checklist

When creating new infrastructure (screens, API clients, stores), use exploration findings as a **checklist** — systematically verify each convention is followed before writing code.

## Never

- Never edit `.g.dart` files directly — always regenerate with `dart run build_runner build`

---

# Project

Flutter mobile app for browsing Twitch on iOS and Android. Uses MobX for state management with code generation.

## Commands

```bash
flutter pub get                                                     # Install dependencies
flutter run --dart-define=CLIENT_ID=ID --dart-define=SECRET=SECRET  # Run with Twitch credentials
flutter analyze                                                     # Static analysis (run after changes)
flutter test                                                        # Run tests
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
- Several deps in `pubspec.yaml` are git-pinned forks carrying compatibility patches (`extended_text_field`, `better_native_video_player`, `simple_pip_mode`). When upgrading dependencies, don't swap them back to pub.dev releases.

## Testing

- `flutter test` runs all tests; `flutter test test/path/to/file.dart` for a single file
- HTTP mocking: `http_mock_adapter` (`DioAdapter`) — use full URLs in `onGet`/`onPost`
- General mocking: `mocktail` (no codegen required)
- Test layout mirrors `lib/` (`test/apis/`, `test/models/`, `test/screens/`); shared fixtures live in `test/fixtures/` (e.g., `irc_messages.dart`, `api_responses.dart`)
