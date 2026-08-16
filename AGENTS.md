# AGENTS.md

Flutter Twitch client for iOS and Android. MobX with `build_runner`. The landing page is `web/` (own `AGENTS.md`). Flutter is pinned in `pubspec.yaml` `environment.flutter` — bump that one field; CI reads it via `flutter-version-file`.

## Commands

```bash
flutter pub get
flutter run --dart-define-from-file=.env   # local; .env is gitignored
flutter run --dart-define=CLIENT_ID=ID --dart-define=SECRET=SECRET
flutter analyze
flutter test
flutter test test/path/to/file.dart
dart run build_runner build   # after MobX / @JsonSerializable changes
```

`--delete-conflicting-outputs` is ignored as of build_runner 2.15. Don't add it.

## Layout

- `lib/apis/` — API clients extend `BaseApiClient`
- `lib/models/` — data models; `@JsonSerializable` ones commit `.g.dart`
- `lib/screens/{feature}/` — screens; feature stores in co-located `stores/`
- `lib/stores/` — global stores only (`global_assets_store.dart`)
- `test/` mirrors `lib/`; shared fixtures in `test/fixtures/`

Don't add top-level store files or standalone API classes. Canonical MobX store: `lib/screens/settings/stores/auth_store.dart`. Extract state, reactions, and actions into stores when it keeps widgets on rendering.

New or changed logic (stores, API clients, parsing, utils) ships with tests; extend existing tests when touching tested code. Pure UI or config may skip. HTTP: `http_mock_adapter` (`DioAdapter`) with full URLs. Otherwise `mocktail`.

## Gotchas

- Commit regenerated `.g.dart` files. Never edit them. CI fails the PR if they're stale.
- `main.dart` secure-storage `deleteAll()` looks redundant; it handles Android/iOS storage surviving uninstall. Don't remove it.
- `flutter_secure_storage` stays on v9 (v10 shipped in 5.0.0 and was reverted in 5.0.1 over an Android 14 startup freeze). That also holds `package_info_plus` v9 and `device_info_plus` v12 (win32). Don't jump them in a drive-by upgrade.
- Git-pinned forks in `pubspec.yaml` (`extended_text_field`, `better_native_video_player`, `simple_pip_mode`) carry patches. Don't swap them back to pub.dev.
- `android/gradle.properties`: keep `android.builtInKotlin=false` and `android.newDsl=false` so plugins that still apply KGP build on AGP 9.
- `ios/Runner/AppDelegate.swift` is customized (`CookieExtractorPlugin` + `FlutterImplicitEngineDelegate`). Flutter will not auto-migrate UIScene; don't replace the delegate with the template.
- `android/.../MainActivity.kt` extends `PipCallbackHelperActivityWrapper` and registers `CookieExtractorPlugin` by hand. Don't revert it to `FlutterActivity`.
- Helix OAuth (`Bearer`) and the Twitch web GQL cookie are different tokens. Native playback uses the cookie; don't send the Helix token to GQL/Usher.
- `syncedChatDelay` is runtime-only (`includeFromJson/toJson: false`). Don't persist it with the other settings.
- Don't remove the `ALLOW_DEBUG_SIGNED_RELEASE` branch in `android/app/build.gradle.kts`. Real releases must still fail if `key.properties` is missing.

## Releases

When cutting a store or GitHub release, read `docs/release.md` and follow it. That playbook is repo-local, not a global skill.
