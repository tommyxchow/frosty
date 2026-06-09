![Showcase of the Frosty app with screenshots in a masonry grid](https://github.com/tommyxchow/frosty/assets/54859075/09178dcc-2fd2-4618-8076-502719159424)

<p>
  <a href="https://github.com/namecallfilter/glacier/actions/workflows/ci.yml">
    <img
      alt="Badge showing the CI status."
      src="https://github.com/namecallfilter/glacier/actions/workflows/ci.yml/badge.svg"
    />
  </a>
  <a href="https://github.com/namecallfilter/glacier/issues">
    <img
      alt="Badge showing the number of open issues."
      src="https://img.shields.io/github/issues/namecallfilter/glacier"
    />
  </a>
  <a href="https://github.com/namecallfilter/glacier/commits">
    <img
      alt="Badge showing the date of the last commit."
      src="https://img.shields.io/github/last-commit/namecallfilter/glacier"
    />
  </a>
  <a href="https://github.com/namecallfilter/glacier/blob/main/LICENSE">
    <img
      alt="Badge showing the current license of the repo."
      src="https://img.shields.io/github/license/namecallfilter/glacier"
    />
  </a>
  <a href="https://github.com/namecallfilter/glacier/releases/latest">
    <img
      alt="Badge showing the version of the latest release."
      src="https://img.shields.io/github/v/release/namecallfilter/glacier"
    />
  </a>
</p>

## Download

Android APKs are published through [GitHub Releases](https://github.com/namecallfilter/glacier/releases). This fork is not published through app stores.

## About

Glacier is an Android-only fork of [Frosty](https://github.com/tommyxchow/frosty), keeping the Frosty app branding while shipping fork-specific Android APK releases.

The official Twitch mobile app doesn't support emotes from [7TV](https://chrome.google.com/webstore/detail/7tv/ammjkodgmmoknidbanneddgankgfejfh), [BetterTTV (BTTV)](https://chrome.google.com/webstore/detail/betterttv/ajopnjidmegmdimjlfnijceegpefgped), and [FrankerFaceZ (FFZ)](https://chrome.google.com/webstore/detail/frankerfacez/fadndhdgpmmaapbmfcknlfgcflmmmieb). Frosty renders those emotes directly in chat.

## Features

- Support for 7TV, BetterTTV, and FrankerFaceZ emotes and badges
- Browse followed streams, top streams, and top categories
- Autocomplete for emotes and user mentions
- Light, dark, and black (OLED) themes
- Search for channels and categories
- See and filter chatters in a channel
- Local chat user message history
- Theater and fullscreen mode
- Watch live streams with chat
- Picture-in-picture mode
- Block and report users
- Emote menu
- Sleep timer

## Development setup

1. [Install Flutter](https://docs.flutter.dev/get-started/install).

2. Clone this repo:

   ```bash
   git clone https://github.com/namecallfilter/glacier.git
   ```

3. Go to the [Twitch dev console](https://dev.twitch.tv/login) and register a new application to retrieve a **Client ID** and **Client Secret**.

4. Copy `.env.example` to `.env` and fill in your credentials:

   ```bash
   cp .env.example .env
   ```

5. Run `flutter pub get` to fetch dependencies.

6. Choose an Android emulator or device and run the app.

> [!IMPORTANT]
> Frosty uses [MobX](https://mobx.netlify.app/) for state management. Regenerate code after changing MobX stores or JSON models.

## Release

This fork version-matches upstream Frosty. The current baseline is `v5.0.5`.

To publish an Android APK, update `pubspec.yaml` and `assets/release-notes.md`, push a fork release tag like `glacier-v5.0.5`, then publish the drafted GitHub release. The Android app version stays `5.0.5`, while the fork tag avoids colliding with upstream Frosty tags.

## License

Frosty is licensed under [AGPL-3.0-or-later](LICENSE). This fork preserves the same license.
