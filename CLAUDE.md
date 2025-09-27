# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

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
- `--dart-define=clientId=YOUR_TWITCH_CLIENT_ID`
- `--dart-define=secret=YOUR_TWITCH_CLIENT_SECRET`

Example: `flutter run --dart-define=clientId=abc123 --dart-define=secret=def456`

## Architecture Overview

**State Management**: Uses MobX for reactive state management. All stores end with `Store` and have corresponding `.g.dart` generated files. Stores are located within their respective screen directories under `stores/` folders.

**Key Directories**:
- `lib/screens/` - UI screens organized by feature (home, channel, settings, onboarding)
  - Each screen has its own MobX stores in a `stores/` subdirectory
- `lib/models/` - Data models with JSON serialization (uses .g.dart files)
- `lib/apis/` - API services for Twitch, BTTV, FFZ, and 7TV
- `lib/widgets/` - Reusable UI components
- `lib/cache_manager.dart` - Custom cache management for images/media
- `lib/utils.dart` - Utility functions and helpers

**Main Application Flow**:
1. App starts in `main.dart` with Firebase initialization and dependency injection via Provider
2. Authentication handled by `AuthStore` using Twitch OAuth
3. Settings persisted via `SettingsStore` with SharedPreferences
4. API services inject common HTTP client for efficient connection reuse

**Screen Architecture**:
- Home screen with tabs: Following streams, Top streams, Categories, Search
- Channel screen with video player and chat functionality
- Settings screen with account management and app configuration
- Onboarding flow for first-time users

**Chat System**:
- Real-time chat via WebSocket connection to Twitch IRC
- Third-party emote support (BTTV, FFZ, 7TV) loaded asynchronously
- Chat message parsing and rendering with emote/badge support
- User interaction features (blocking, reporting, moderation)

**Third-party Integrations**:
- Firebase: Crashlytics, Performance monitoring, Analytics
- Twitch API: Authentication, streams, users, chat
- BTTV/FFZ/7TV APIs: Extended emote and badge support

## Development Notes

**MobX Code Generation**: This project heavily uses MobX for state management and JSON serialization. Any changes to MobX stores or model classes with `@JsonSerializable()` require running the build_runner to regenerate the corresponding `.g.dart` files. Generated files are excluded from analysis in `analysis_options.yaml`.

**API Configuration**: Requires Twitch Client ID and Client Secret from dev.twitch.tv console for API access. Use `--dart-define` flags when running the app.

**Code Style**: The project enforces specific lint rules via `analysis_options.yaml` including single quotes, trailing commas, final locals, and package imports. Custom rules include `directives_ordering`, `always_use_package_imports`, `prefer_final_locals`, and `require_trailing_commas`. Run `flutter analyze` to check for violations.

**Dependency Injection**: Uses Provider for dependency injection, with all major services (API clients, stores) provided at the app root in `main.dart` with a shared HTTP client for efficiency.

**Platform Support**: iOS and Android with platform-specific configurations. Uses Firebase for crashlytics, performance monitoring, and analytics.

## HTTP Client Architecture

**Centralized Dio Setup**: All API services share a single Dio instance configured in `DioClient.createClient()` with:
- Connection pooling and keep-alive headers for efficiency
- Optimized timeouts: 8s connect, 15s receive, 10s send
- Global Twitch User-Agent header
- Simple logging in debug mode (not verbose to avoid log spam)

**Authentication Interceptor**: `TwitchAuthInterceptor` automatically injects auth headers:
- Detects Twitch API URLs and adds Authorization + Client-Id headers
- Updates automatically when user authentication changes
- Eliminates manual header passing throughout the codebase

**API Service Pattern**: All API services extend `BaseApiClient` for consistent error handling and HTTP operations. Services include `TwitchApi`, `BTTVApi`, `FFZApi`, and `SevenTVApi`.

## Authentication & Token Management

**Two-tier Token System**:
- Default app token for unauthenticated requests
- Optional user token stored in Flutter Secure Storage
- Automatic token validation on startup with fallback

**WebView OAuth Flow**: Custom JavaScript injection in WebView for seamless Twitch login experience without opening external browsers.

**Secure Storage Cleanup**: First-run detection clears secure storage to handle Android/iOS uninstall scenarios where secure storage persists.

## MobX Store Implementation

**Store Pattern**: All stores follow `StoreBase with _$StoreName` pattern:
- Generate `.g.dart` files with `flutter packages pub run build_runner build`
- Use `@observable`, `@action`, and `@computed` annotations
- Settings store uses `@JsonSerializable()` with automatic persistence via `autorun()`

**Authentication Headers**: Generated as `@computed` properties that automatically update when tokens change.

**State Persistence**: Settings automatically saved to SharedPreferences via MobX `autorun()` reaction.

## Custom Cache Management

**Orphaned File Cleanup**: `CustomCacheManager.removeOrphanedCacheFiles()` runs on startup to remove files not in database.

**Optimized Settings**: 30-day stale period, 10,000 max objects for efficient image caching across the app.

## Chat System Architecture

**Real-time IRC**: WebSocket connection to Twitch IRC with custom `IRCMessage` parsing.

**Third-party Emotes**: Asynchronous loading of BTTV, FFZ, and 7TV assets via dedicated APIs.

**Message Management**: 5000 message limit with 20% batch removal optimization for performance.

**Assets Store**: Separate `ChatAssetsStore` manages emotes, badges, and chat-related data.

## Code Style Guidelines

- **Prefer modern Flutter/Dart features and type-safety**
- **Use consistent naming, comments, and styles matching the existing codebase**
- **Single quotes, trailing commas, and final locals per lint rules**
- **Package imports over relative imports**
- **Observer widgets only wrap necessary UI components for MobX optimization**
