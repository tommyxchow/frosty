# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Workflow

**Plan Mode - In-Depth Planning**: When in plan mode, interview thoroughly before coding:

- Ask detailed questions about technical implementation, UI/UX concerns, tradeoffs, and edge cases
- Continue asking questions until all requirements and non-obvious decisions are clear
- Don't begin implementation until all important details are resolved

**Pattern Consistency**: When implementing new code:

- Search the codebase to find existing usages and implementations
- Prefer following established patterns, styles, and practices for consistency

## Skills & Plugins

Claude Code has access to specialized skills. Use them proactively based on context:

**`/feature-dev:feature-dev`** — Guided Feature Development
- Use when: Planning or implementing new features, analyzing architecture, creating implementation blueprints
- Trigger phrases: "add a feature", "implement", "build", "create new functionality"

**`/frontend-design:frontend-design`** — Production UI Components
- Use when: Creating or improving UI components, widgets, screens, or visual design
- Trigger phrases: "design", "build UI", "create a widget", "improve the interface"

**`/code-review:code-review`** — Code Quality Review
- Use when: After writing or modifying code, before commits, reviewing changes
- Trigger phrases: "review my code", "check this", "is this good?"
- **Proactive**: Suggest after significant code modifications

**`/pr-review-toolkit:review-pr`** — Comprehensive PR Review
- Use when: Before creating PRs, reviewing PR changes, final quality checks
- Trigger phrases: "review the PR", "check before merging", "PR ready?"

### Automatic Triggers

Claude should proactively suggest skills in these situations:

| After This Action | Suggest This Skill |
|-------------------|-------------------|
| Writing/editing multiple files | `/code-review:code-review` |
| Completing a feature implementation | `/code-review:code-review` |
| User says "ready for PR" or "create PR" | `/pr-review-toolkit:review-pr` |
| Discussing new feature requirements | `/feature-dev:feature-dev` |
| Building UI components or screens | `/frontend-design:frontend-design` |

### Specialized Subagents

These are advanced capabilities Claude can use for deeper analysis (not slash commands, but can be requested):

**Code Quality & Review:**
- **Silent Failure Hunter** — Finds silent failures, poor error handling, swallowed exceptions
  - Trigger: "hunt for silent failures", "check error handling", "find swallowed errors"
- **Code Simplifier** — Simplifies code while preserving functionality
  - Trigger: "simplify this code", "make this cleaner", "reduce complexity"
- **Comment Analyzer** — Checks comments for accuracy and technical debt
  - Trigger: "review the comments", "check documentation accuracy"

**Architecture & Types:**
- **Type Design Analyzer** — Analyzes type design, encapsulation, and invariants
  - Trigger: "analyze type design", "review this type", "check encapsulation"
- **Code Architect** — Designs feature architectures with implementation blueprints
  - Trigger: "design the architecture", "create implementation blueprint"
- **Code Explorer** — Deep analysis of existing features, traces execution paths
  - Trigger: "trace this flow", "how does this work end-to-end", "analyze this feature"

**Testing:**
- **PR Test Analyzer** — Reviews test coverage quality and identifies gaps
  - Trigger: "analyze test coverage", "are tests thorough enough", "find test gaps"

## Development Commands

**Common Commands:**
- `flutter pub get` - Install dependencies
- `flutter run --dart-define=clientId=YOUR_CLIENT_ID --dart-define=secret=YOUR_CLIENT_SECRET` - Run with Twitch API credentials
- `flutter analyze` - Run static analysis and lint checks
- `flutter test` - Run all tests
- `flutter build apk` / `flutter build ios` - Build release binaries

**Code Generation** (required after changing MobX stores or `@JsonSerializable` models):
- `flutter packages pub run build_runner build` - Generate once
- `flutter packages pub run build_runner build --delete-conflicting-outputs` - Force rebuild all
- `flutter packages pub run build_runner watch` - Watch mode for development

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
- `SettingsStore` - User preferences with automatic persistence via MobX `autorun()`
- `GlobalAssetsStore` - Shared cache for global emotes and badges across all chat tabs

**HTTP & Auth**: Centralized Dio client (`DioClient.createClient()`) with connection pooling and optimized timeouts. `TwitchAuthInterceptor` auto-injects auth headers for Twitch API URLs. `UnauthorizedInterceptor` catches 401 errors for token refresh. Two-tier token system: default app token + optional user token in Flutter Secure Storage.

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
- **Assets Store**: Separate `ChatAssetsStore` manages channel-specific emotes/badges; `GlobalAssetsStore` caches global assets

## Deep Linking

App supports Twitch channel deep links (e.g., `twitch.tv/channelname`). Deep link handling in `main.dart`:
- Uses `app_links` package for URI stream handling
- Resolves channel names via Twitch API before navigation
- Graceful fallback with in-app browser option on failure

## Code Style

Analysis rules enforced via `analysis_options.yaml`:

- `prefer_single_quotes` - Use single quotes for strings
- `always_use_package_imports` - Package imports over relative imports
- `require_trailing_commas` - Trailing commas on multi-line constructs
- `prefer_final_locals`, `prefer_final_in_for_each` - Prefer final variables
- `directives_ordering`, `avoid_void_async`, `always_declare_return_types`
- `avoid_redundant_argument_values`, `unnecessary_parenthesis`

Generated `.g.dart` files are excluded from analysis but must be committed.

**Error Handling**: Use `Future.error()` for API failures rather than throwing exceptions.

## Commit Convention

Commits follow conventional format: `refactor:`, `feat:`, `fix:`, `format:`, etc. Keep commits tightly scoped. Include generated `.g.dart` outputs in the same commit as their source changes.
