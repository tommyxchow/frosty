# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Workflow

**Plan Mode - In-Depth Planning**: When in plan mode, conduct thorough discussion before coding:

- Ask clarifying questions about technical implementation, UI/UX concerns, tradeoffs, and edge cases
- Ensure all requirements and non-obvious decisions are clear
- Don't begin implementation until all important details are resolved

**Pattern Consistency**: When implementing new code:

- Search the codebase to find existing usages and implementations
- Prefer following established patterns, styles, and practices for consistency

## Development Commands

**Build and Development**

- `flutter pub get` - Install dependencies
- `flutter run` - Run the app on connected device/emulator
- `flutter build apk` - Build Android APK
- `flutter build ios` - Build iOS app
- `flutter analyze` - Run static analysis and lint checks
- `flutter test` - Run tests (note: no test suite currently exists)

**Code Generation (Required for MobX stores and JSON serialization)**

- `flutter packages pub run build_runner build` - Generate code once
- `flutter packages pub run build_runner watch` - Watch and regenerate code on changes
- `flutter packages pub run build_runner build --delete-conflicting-outputs` - Force rebuild all generated files

**Asset Generation**

- `flutter pub run flutter_native_splash:create` - Generate native splash screens
- `flutter pub run flutter_launcher_icons:main` - Generate app launcher icons

**Environment Variables**
Use `--dart-define` to set environment variables (required for Twitch API access):

```bash
flutter run --dart-define=clientId=YOUR_TWITCH_CLIENT_ID --dart-define=secret=YOUR_TWITCH_CLIENT_SECRET
```

## Architecture Overview

**State Management**: MobX with code generation. All stores end with `Store` and have corresponding `.g.dart` generated files.

**Key Directories**:

- `lib/screens/` - UI screens organized by feature (home, channel, settings, onboarding)
  - Each screen has its own MobX stores in a `stores/` subdirectory
- `lib/models/` - Data models with JSON serialization (uses .g.dart files)
- `lib/apis/` - API services for Twitch, BTTV, FFZ, and 7TV
- `lib/widgets/` - Reusable UI components
- `lib/utils/` - Utility modules including context extensions

**Main Application Flow**:

1. App starts in `main.dart` with Firebase initialization and dependency injection via Provider
2. Authentication handled by `AuthStore` using Twitch OAuth
3. Settings persisted via `SettingsStore` with SharedPreferences and MobX `autorun()`
4. API services share a common Dio HTTP client for efficient connection reuse

**Global Stores** (provided at app root in `main.dart`):

- `AuthStore` - Authentication state and token management
- `SettingsStore` - User preferences with automatic persistence

## HTTP Client Architecture

**Centralized Dio Setup**: All API services share a single Dio instance configured in `DioClient.createClient()` with connection pooling, keep-alive headers, and optimized timeouts (8s connect, 15s receive, 10s send).

**Authentication Interceptor**: `TwitchAuthInterceptor` automatically injects auth headers for Twitch API URLs. Updates automatically when user authentication changes.

**API Service Pattern**: All API services extend `BaseApiClient` for consistent error handling. Services: `TwitchApi`, `BTTVApi`, `FFZApi`, `SevenTVApi`.

## Authentication & Token Management

**Two-tier Token System**:

- Default app token for unauthenticated requests
- Optional user token stored in Flutter Secure Storage
- Automatic token validation on startup with fallback

**Secure Storage Cleanup**: First-run detection clears secure storage to handle Android/iOS uninstall scenarios where secure storage persists.

## MobX Store Implementation

**Store Pattern**: All stores follow `StoreBase with _$StoreName` pattern:

```dart
class SomeStore = SomeStoreBase with _$SomeStore;

abstract class SomeStoreBase with Store {
  @observable
  var someValue = '';

  @action
  void updateValue(String value) => someValue = value;

  @computed
  String get derivedValue => someValue.toUpperCase();
}
```

After any changes to MobX stores or `@JsonSerializable()` models, run the build_runner to regenerate `.g.dart` files.

## Chat System Architecture

- **Real-time IRC**: WebSocket connection to Twitch IRC with custom `IRCMessage` parsing
- **Third-party Emotes**: Asynchronous loading of BTTV, FFZ, and 7TV assets via dedicated APIs
- **Message Management**: 5000 message limit with 20% batch removal optimization
- **Assets Store**: Separate `ChatAssetsStore` manages emotes, badges, and chat-related data

## Code Style

Analysis rules enforced via `analysis_options.yaml`:

- `prefer_single_quotes` - Use single quotes for strings
- `always_use_package_imports` - Package imports over relative imports
- `require_trailing_commas` - Trailing commas on multi-line constructs
- `prefer_final_locals` - Final for local variables
- `directives_ordering`, `avoid_void_async`, `always_declare_return_types`

Generated `.g.dart` files are excluded from analysis but must be committed.

## Commit Convention

Commits follow conventional format: `refactor:`, `feat:`, `fix:`, `format:`, etc. Keep commits tightly scoped. Include generated `.g.dart` outputs in the same commit as their source changes.
