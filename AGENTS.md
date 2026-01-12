# AGENTS.md

## Development Workflow

**Plan Mode**: When in plan mode, interview thoroughly before coding:
- Ask detailed questions about technical implementation, UI/UX concerns, tradeoffs, and edge cases
- Continue asking questions until all requirements and non-obvious decisions are clear
- Don't begin implementation until all important details are resolved

**Pattern Consistency**: When implementing new code:
- Search the codebase to find existing usages and implementations
- Prefer following established patterns, styles, and practices for consistency

## Development Commands

**Common Commands:**
- `flutter pub get` - Install dependencies
- `flutter run --dart-define=clientId=YOUR_CLIENT_ID --dart-define=secret=YOUR_CLIENT_SECRET` - Run with Twitch API credentials
- `flutter analyze` - Run static analysis and lint checks
- `flutter test` - Run all tests
- `flutter test test/path/to/test.dart` - Run a single test file
- `flutter build apk` / `flutter build ios` - Build release binaries

**Code Generation** (required after changing MobX stores or `@JsonSerializable` models):
- `dart run build_runner build` - Generate once
- `dart run build_runner build --delete-conflicting-outputs` - Force rebuild all
- `dart run build_runner watch` - Watch mode for development

Generated `.g.dart` files are excluded from linting but must be committed to source control.

## Architecture Overview

**State Management**: MobX with code generation. All stores end with `Store` and have corresponding `.g.dart` generated files.

**Key Directories**:
- `lib/screens/` - UI screens organized by feature (home, channel, settings, onboarding)
- `lib/models/` - Data models with JSON serialization (uses .g.dart files)
- `lib/apis/` - API services for Twitch, BTTV, FFZ, and 7TV
- `lib/widgets/` - Reusable UI components
- `lib/utils/` - Utility modules including context extensions

**Screen Organization**: `lib/screens/{feature}/` contains `{feature}.dart` (main UI), `stores/` subdirectory with MobX stores, and feature sub-components.

**Main Application Flow**:
1. App starts in `main.dart` with Firebase initialization and dependency injection via Provider
2. Authentication handled by `AuthStore` using Twitch OAuth
3. Settings persisted via `SettingsStore` with SharedPreferences and MobX `autorun()`
4. API services share a common Dio HTTP client for efficient connection reuse

**Global Stores** (injected via Provider in `main.dart`):
- `AuthStore` (`lib/screens/settings/stores/`) - Authentication state and token management
- `SettingsStore` (`lib/screens/settings/stores/`) - User preferences with automatic persistence via MobX `autorun()`
- `GlobalAssetsStore` (`lib/stores/`) - Shared cache for global emotes and badges across all chat tabs

## HTTP & API Architecture

**Shared HTTP Client**: Single Dio instance configured in `DioClient.createClient()` with:
- Connection pooling and keep-alive headers for efficiency
- Optimized timeouts: 8s connect, 15s receive, 10s send
- Frosty User-Agent header for Twitch API compatibility

**Authentication Interceptor**: `TwitchAuthInterceptor` automatically injects auth headers for Twitch API URLs. `UnauthorizedInterceptor` catches 401 errors for token refresh.

**Two-tier Token System**: Default app token for unauthenticated requests + optional user token in Flutter Secure Storage.

**BaseApiClient Pattern**: All API services (`TwitchApi`, `BTTVApi`, `FFZApi`, `SevenTVApi`) extend `BaseApiClient` which provides:
- Generic GET/POST/PUT/DELETE methods with centralized error handling
- Automatic conversion of `DioException` to typed exceptions

**Exception Hierarchy**: `ApiException` base class with `NetworkException`, `TimeoutException`, `ServerException`, `NotFoundException`, `UnauthorizedException` (see `lib/apis/base_api_client.dart`).

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

**MobX Reactions** (for side effects and persistence):

```dart
// Auto-save settings whenever they change (in main.dart)
autorun((_) => prefs.setString('settings', jsonEncode(settingsStore)));

// React to specific state changes
reaction((_) => authStore.isLoggedIn, (_) => _selectedIndex = 0);
```

## Chat System Architecture

- **Real-time IRC**: WebSocket connection to Twitch IRC with custom `IRCMessage` parsing
- **Third-party Emotes**: Asynchronous loading of BTTV, FFZ, and 7TV assets via dedicated APIs
- **Message Management**: 5000 message limit with 20% batch removal optimization
- **Assets Store**: `ChatAssetsStore` manages channel-specific emotes/badges
- **User Interaction**: Blocking, reporting, and moderation capabilities

## Additional Patterns

**Emote Architecture**: Base `Emote` class with platform-specific factories: `Emote.fromTwitch()`, `Emote.fromBTTV()`, `Emote.fromFFZ()`, `Emote.from7TV()`.

**Custom Cache Manager**: Uses 30-day stale period and 10k max objects. `CustomCacheManager.removeOrphanedCacheFiles()` runs on startup to clean files not in database.

**Secure Storage Cleanup**: First-run detection clears Flutter Secure Storage to handle Android/iOS uninstall edge case where secure storage persists but app data is wiped.

**Authentication Flow**:
- OAuth via WebView with custom JavaScript injection for seamless Twitch login
- Token storage in FlutterSecureStorage
- Auto-refresh and validation logic in `AuthStore`

## Code Style

**Lint Rules** (from `analysis_options.yaml`):
- `prefer_single_quotes`, `always_use_package_imports`, `require_trailing_commas`
- `prefer_final_locals`, `prefer_final_in_for_each`, `avoid_redundant_argument_values`
- `directives_ordering`, `avoid_void_async`, `always_declare_return_types`, `unnecessary_parenthesis`

## Commit Convention

Commits use lowercase, descriptive messages without prefixes (e.g., `fix landscape bottom padding in chat bottom bar`, `add swipe pip gesture support`). Keep commits tightly scoped.
