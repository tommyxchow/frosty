# Repository Guidelines

## Project Structure & Module Organization
Frosty is a Flutter client with a standalone marketing site. App code sits in `lib/`, split into `apis/`, `services/`, `models/`, `screens/`, `widgets/`, plus shared helpers in `utils/`, `constants.dart`, `theme.dart`, and the `main.dart` entrypoint. Platform shells live in `android/` and `ios/`; touch them only for native integrations. Assets, fonts, and splash art are checked into `assets/` and declared in `pubspec.yaml`. The Next.js site under `web/` keeps its own `src/` and `public/` structure.

## Build, Test, and Development Commands
- `flutter pub get` syncs dependencies whenever `pubspec.yaml` changes.
- `dart run build_runner watch --delete-conflicting-outputs` keeps MobX `*.g.dart` files in sync while editing stores.
- `flutter run --dart-define=clientId=... --dart-define=secret=...` launches the app with Twitch credentials.
- `flutter analyze` enforces the lint rules used by CI.
- `flutter test` runs unit and widget suites; add `--coverage` when refreshing reports.
- Inside `web/`, run `pnpm install`, `pnpm dev`, and `pnpm lint` for the marketing site.

## Coding Style & Naming Conventions
Use the Flutter formatter (2-space indent) and respect `analysis_options.yaml` rules such as `prefer_single_quotes`, `require_trailing_commas`, and `always_use_package_imports`. Name Dart files with `snake_case`, classes with `PascalCase`, and MobX stores as `SomethingStore`. Keep styling centralised in `theme.dart` and avoid importing relative siblings across packages. In `web/`, rely on Prettier, TypeScript components in `PascalCase`, and hooks/helpers in `camelCase`.

## Testing Guidelines
Create Dart tests under `test/`, mirroring `lib/` paths (e.g., `lib/services/chat_service.dart` -> `test/services/chat_service_test.dart`). Prefer widget tests for UI states and mock network calls so suites stay deterministic. Run `flutter test` locally before pushing. For the web project, linting is the current gate; add component or e2e tests when introducing interactive behaviour.

## Commit & Pull Request Guidelines
Commits follow the existing conventional format (`refactor:`, `feat:`, `fix:`, `format`, etc.) and should stay tightly scoped. Include generated outputs (MobX `.g.dart`, assets) in the same commit as their source. Pull requests need a clear summary of user impact, manual test notes, and linked issues. Attach screenshots or recordings for UI changes and confirm `flutter analyze`, `flutter test`, and `pnpm lint` before requesting review.

## Security & Configuration Tips
Pass Twitch secrets through `--dart-define` or untracked `.env` files; never commit credentials. `lib/firebase_options.dart` is generated via `flutterfire configure`; regenerate rather than editing by hand. When adjusting native builds, prefer local Gradle/Xcode properties instead of checked-in configuration.
