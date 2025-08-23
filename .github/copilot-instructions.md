# Copilot Instructions for Frosty

## Project Overview

Frosty is a cross-platform Flutter app for Twitch that supports third-party emotes (7TV, BTTV, FFZ). The architecture is built around **MobX state management** with strict code generation requirements and a **shared HTTP client pattern** for API efficiency.

## Critical Development Workflow

### Code Generation (REQUIRED)

All MobX stores and JSON models require code generation. **Always run after any MobX or model changes:**

```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
```

Generated `.g.dart` files are excluded from linting but must be committed.

### Environment Setup

Twitch API requires client credentials via `--dart-define`:

```bash
flutter run --dart-define=clientId=YOUR_CLIENT_ID --dart-define=secret=YOUR_SECRET
```

## Architecture Patterns

### State Management (MobX)

- **Store Pattern**: Each feature has stores in `lib/screens/{feature}/stores/` (not at screen root)
- **Naming**: All stores end with `Store` suffix and have corresponding `.g.dart` files
- **Global Stores**: `AuthStore` and `SettingsStore` in `lib/screens/settings/stores/`
- **Dependency Injection**: Stores are provided via Provider in `main.dart` with shared HTTP client

### API Service Architecture

- **Shared HTTP Client**: Single `Client()` instance injected into all API services in `main.dart`
- **API Services**: `TwitchApi`, `BTTVApi`, `FFZApi`, `SevenTVApi` in `lib/apis/`
- **Headers Pattern**: Twitch API methods accept `headers` parameter for auth tokens

### Screen Organization

```
lib/screens/{feature}/
├── {feature}.dart          # Main UI
├── {feature}_store.dart    # Feature store (NOT at root)
├── {feature}_store.g.dart  # Generated file
└── subdirectories/         # Feature sub-components
```

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

### Authentication Flow

- **OAuth**: Twitch OAuth via WebView in `AuthStore`
- **Token Storage**: FlutterSecureStorage for secure token persistence
- **Auto-refresh**: Token validation and refresh logic in `AuthStore`

## Code Style Enforcement

Analysis rules in `analysis_options.yaml`:

- Single quotes: `prefer_single_quotes`
- Package imports: `always_use_package_imports`
- Trailing commas: `require_trailing_commas`
- Final locals: `prefer_final_locals`

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

## Platform Support

- **iOS/Android**: Native platform features via plugins
- **Custom Cache**: `CustomCacheManager` for media caching
- **PiP Mode**: Custom implementation via git dependency

When working with this codebase, always consider MobX code generation requirements and the shared HTTP client pattern for API efficiency.
