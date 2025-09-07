# Copilot Instructions for Frosty

## Project Overview

Frosty is a cross-platform Flutter app for Twitch that supports third-party emotes (7TV, BTTV, FFZ). The architecture is built around **MobX state management** with strict code generation requirements and a **shared HTTP client pattern** for API efficiency.

## Critical Development Workflow

### Essential Commands

**Dependencies and Development:**

- `flutter pub get` - Install dependencies
- `flutter run` - Run the app on connected device/emulator
- `flutter build apk` - Build Android APK
- `flutter build ios` - Build iOS app
- `flutter analyze` - Run static analysis and lint checks

### Code Generation (REQUIRED)

All MobX stores and JSON models require code generation. **Always run after any MobX or model changes:**

```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
```

**Alternative commands:**

- `flutter packages pub run build_runner build` - Generate code once
- `flutter packages pub run build_runner watch` - Watch and regenerate code on changes

Generated `.g.dart` files are excluded from linting but must be committed to source control.

### Environment Setup

Twitch API requires client credentials via `--dart-define`:

```bash
flutter run --dart-define=clientId=YOUR_TWITCH_CLIENT_ID --dart-define=secret=YOUR_TWITCH_CLIENT_SECRET
```

## Architecture Patterns

### State Management (MobX)

- **Store Pattern**: Each feature has stores in `lib/screens/{feature}/stores/` (not at screen root)
- **Naming**: All stores end with `Store` suffix and have corresponding `.g.dart` files
- **Global Stores**: `AuthStore` and `SettingsStore` in `lib/screens/settings/stores/`
- **Dependency Injection**: Stores are provided via Provider in `main.dart` with shared HTTP client

### API Service Architecture

- **Shared HTTP Client**: Single Dio instance configured in `DioClient.createClient()` with:
  - Connection pooling and keep-alive headers for efficiency
  - Optimized timeouts: 8s connect, 15s receive, 10s send
  - Global Twitch User-Agent header
  - Simple logging in debug mode (not verbose to avoid log spam)
- **API Services**: `TwitchApi`, `BTTVApi`, `FFZApi`, `SevenTVApi` in `lib/apis/`
- **Authentication Interceptor**: `TwitchAuthInterceptor` automatically injects auth headers:
  - Detects Twitch API URLs and adds Authorization + Client-Id headers
  - Updates automatically when user authentication changes
  - Eliminates manual header passing throughout the codebase
- **Error Handling**: `UnauthorizedInterceptor` catches 401 errors for token refresh
- **Service Pattern**: All API services extend `BaseApiClient` for consistent error handling

### Project Structure

**Key Directories:**

- `lib/screens/` - UI screens organized by feature (home, channel, settings, onboarding)
  - Each screen has its own MobX stores in a `stores/` subdirectory
- `lib/models/` - Data models with JSON serialization (uses `.g.dart` files)
- `lib/apis/` - API services for Twitch, BTTV, FFZ, and 7TV
- `lib/widgets/` - Reusable UI components
- `lib/cache_manager.dart` - Custom cache management for images/media
- `lib/utils.dart` - Utility functions and helpers
- `lib/utils/` - Additional utility modules including context extensions

### Screen Organization

```
lib/screens/{feature}/
├── {feature}.dart          # Main UI
├── stores/                 # Feature stores directory
│   ├── {feature}_store.dart
│   └── {feature}_store.g.dart
└── subdirectories/         # Feature sub-components
```

**Main Application Flow:**

1. App starts in `main.dart` with Firebase initialization and dependency injection via Provider
2. Authentication handled by `AuthStore` using Twitch OAuth
3. Settings persisted via `SettingsStore` with SharedPreferences
4. API services inject common HTTP client for efficient connection reuse

### Model Generation

- **JSON Serialization**: Models use `@JsonSerializable()` with `.g.dart` companions
- **Emote Architecture**: Base `Emote` class with platform-specific factories (`Emote.fromTwitch()`, `Emote.fromBTTV()`)

## Key Integration Points

### Firebase Services

Initialized in `main.dart` with error handling:

- Crashlytics for uncaught errors
- Performance monitoring
- Analytics

### Chat System

- **IRC Connection**: WebSocket to Twitch IRC for real-time chat
- **Emote Loading**: Asynchronous third-party emote fetching (BTTV/FFZ/7TV)
- **Message Parsing**: Custom rendering with emote/badge support
- **Real-time IRC**: WebSocket connection to Twitch IRC with custom `IRCMessage` parsing
- **Third-party Emotes**: Asynchronous loading of BTTV, FFZ, and 7TV assets via dedicated APIs
- **Message Management**: 5000 message limit with 20% batch removal optimization for performance
- **Assets Store**: Separate `ChatAssetsStore` manages emotes, badges, and chat-related data
- **User interaction features**: Blocking, reporting, moderation capabilities

### Authentication Flow

- **OAuth**: Twitch OAuth via WebView in `AuthStore`
- **Token Storage**: FlutterSecureStorage for secure token persistence
- **Auto-refresh**: Token validation and refresh logic in `AuthStore`
- **Two-tier Token System**:
  - Default app token for unauthenticated requests
  - Optional user token stored in Flutter Secure Storage
  - Automatic token validation on startup with fallback
- **WebView OAuth Flow**: Custom JavaScript injection in WebView for seamless Twitch login experience without opening external browsers
- **Secure Storage Cleanup**: First-run detection clears secure storage to handle Android/iOS uninstall scenarios where secure storage persists

## Code Style Enforcement

Analysis rules in `analysis_options.yaml`:

- Single quotes: `prefer_single_quotes`
- Package imports: `always_use_package_imports`
- Trailing commas: `require_trailing_commas`
- Final locals: `prefer_final_locals`
- Additional rules: `directives_ordering`, `avoid_void_async`, `always_declare_return_types`

**Important**: `.g.dart` files are excluded from analysis but must be committed to source control.

## Common Patterns

### MobX Reactions

```dart
late final ReactionDisposer _disposeReaction;
_disposeReaction = reaction(
  (_) => authStore.isLoggedIn,
  (_) => _selectedIndex = 0,
);
```

### Settings Persistence

Auto-saving pattern in `main.dart`:

```dart
autorun((_) => prefs.setString('settings', jsonEncode(settingsStore)));
```

### Error Handling

Use `Future.error()` for API failures, not exceptions.

## MobX Store Implementation

### Store Pattern

All stores follow `StoreBase with _$StoreName` pattern:

- Generate `.g.dart` files with `flutter packages pub run build_runner build`
- Use `@observable`, `@action`, and `@computed` annotations
- Settings store uses `@JsonSerializable()` with automatic persistence via `autorun()`

### Authentication Headers

Generated as `@computed` properties that automatically update when tokens change.

### State Persistence

Settings automatically saved to SharedPreferences via MobX `autorun()` reaction.

## Custom Cache Management

- **Orphaned File Cleanup**: `CustomCacheManager.removeOrphanedCacheFiles()` runs on startup to remove files not in database
- **Optimized Settings**: 30-day stale period, 10,000 max objects for efficient image caching across the app

## Code Style Guidelines

- **Prefer modern Flutter/Dart features and type-safety**
- **Use consistent naming, comments, and styles matching the existing codebase**
- **Single quotes, trailing commas, and final locals per lint rules**
- **Package imports over relative imports**
- **Observer widgets only wrap necessary UI components for MobX optimization**

## Platform Support

- **iOS/Android**: Native platform features via plugins
- **Custom Cache**: `CustomCacheManager` for media caching
- **PiP Mode**: Custom implementation via git dependency

When working with this codebase, always consider MobX code generation requirements and the shared HTTP client pattern for API efficiency.
