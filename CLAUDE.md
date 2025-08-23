# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Commands

**Build and Development**
- `flutter pub get` - Install dependencies
- `flutter run` - Run the app on connected device/emulator
- `flutter build apk` - Build Android APK
- `flutter build ios` - Build iOS app
- `flutter analyze` - Run static analysis and lint checks

**Code Generation (Required for MobX stores and JSON serialization)**
- `flutter packages pub run build_runner build` - Generate code once
- `flutter packages pub run build_runner watch` - Watch and regenerate code on changes
- `flutter packages pub run build_runner build --delete-conflicting-outputs` - Force rebuild all generated files

**Environment Variables**
Use `--dart-define` to set environment variables:
- `--dart-define=clientId=YOUR_TWITCH_CLIENT_ID`
- `--dart-define=secret=YOUR_TWITCH_CLIENT_SECRET`

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

**Code Style**: The project enforces specific lint rules including single quotes, trailing commas, final locals, and package imports. Run `flutter analyze` to check for violations.

**Dependency Injection**: Uses Provider for dependency injection, with all major services (API clients, stores) provided at the app root in `main.dart` with a shared HTTP client for efficiency.

**Platform Support**: iOS and Android with platform-specific configurations. Uses Firebase for crashlytics, performance monitoring, and analytics.