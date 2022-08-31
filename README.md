<p align="center">
  <a align="center" href="https://frostyapp.io">
    <img
      src="https://user-images.githubusercontent.com/54859075/185783257-228d5c49-015e-4ee6-bf78-41f898cf770a.svg"
      width="180px"
      alt="The Frosty rounded logo."
    />
    <h1 align="center">Frosty</h1>
  </a>
</p>

<p align="center">
  A mobile
  <a href="https://www.twitch.tv/">Twitch</a>
  client for iOS and Android with
  <a href="https://7tv.app/">7TV</a>, <a href="https://betterttv.com/">BTTV</a>,
  and
  <a href="https://www.frankerfacez.com/">FFZ</a>
  support. Built with
  <a href="https://flutter.dev/">Flutter</a>.
</p>

<p align="center">
  <a href="https://github.com/tommyxchow/frosty/actions/workflows/ci.yml">
    <img
      alt="Badge showing the CI status."
      src="https://github.com/tommyxchow/frosty/actions/workflows/ci.yml/badge.svg"
    />
  </a>
  <a href="https://github.com/tommyxchow/frosty/issues">
    <img
      alt="Badge showing the number of open issues."
      src="https://img.shields.io/github/issues/tommyxchow/frosty"
    />
  </a>
  <a href="https://github.com/tommyxchow/frosty/commits">
    <img
      alt="Badge showing the date of the last commit."
      src="https://img.shields.io/github/last-commit/tommyxchow/frosty"
    />
  </a>
  <a href="https://github.com/tommyxchow/frosty/blob/main/LICENSE">
    <img
      alt="Badge showing the current license of the repo."
      src="https://img.shields.io/github/license/tommyxchow/frosty"
    />
  </a>
  <a href="https://github.com/tommyxchow/frosty/releases/latest">
    <img
      alt="Badge showing the version of the latest release."
      src="https://img.shields.io/github/v/release/tommyxchow/frosty"
    />
  </a>
</p>

<p align="center">
  <a href="https://apps.apple.com/us/app/frosty-for-twitch/id1603987585">
    <img
      title="Get it on iOS (Apple App Store)"
      alt="Apple App Store badge."
      src="https://user-images.githubusercontent.com/54859075/160051843-1d8b2186-97e9-4edd-a957-bb4797b71b4a.svg"
      width="200px"
    />
  </a>
  <a href="https://play.google.com/store/apps/details?id=com.tommychow.frosty">
    <img
      title="Get it on Android (Google Play Store)"
      alt="Google Play Store badge."
      src="https://user-images.githubusercontent.com/54859075/160051854-21a57556-6b5a-41e9-8127-334daf1fac47.svg"
      width="225px"
    />
  </a>
</p>

<p align="center">
  <a href="https://www.buymeacoffee.com/tommychow">
    <img
      title="Donate"
      alt="Buy Me A Coffee badge."
      src="https://user-images.githubusercontent.com/54859075/160051848-2e581476-a6c6-4de6-9af7-773d96632de1.svg"
      width="200px"
    />
  </a>
</p>

<p align="center">
  <img
    title="Followed streams section"
    alt="iOS screenshot of the Followed Streams section."
    src="https://user-images.githubusercontent.com/54859075/185780262-a3ba5ecf-a710-4511-a583-94e0d0ce0156.png"
    width="32%"
  />
  <img
    title="Channel (video/chat) view"
    alt="iOS screenshot of xQc's channel with the stream and chat."
    src="https://user-images.githubusercontent.com/54859075/185780260-0f7f3247-2cb5-431d-8714-e88e9fcb72f5.png"
    width="32%"
  />
  <img
    title="Search section"
    alt='iOS screenshot of the search section with results from the query "pokelaw".'
    src="https://user-images.githubusercontent.com/54859075/185780261-4301f180-04dc-4328-8a4c-4f035a5ec796.png"
    width="32%"
  />
</p>

## Motivation

The official Twitch mobile app doesn't support emotes from [7TV](https://chrome.google.com/webstore/detail/7tv/ammjkodgmmoknidbanneddgankgfejfh), [BetterTTV (BTTV)](https://chrome.google.com/webstore/detail/betterttv/ajopnjidmegmdimjlfnijceegpefgped), and [FrankerFaceZ (FFZ)](https://chrome.google.com/webstore/detail/frankerfacez/fadndhdgpmmaapbmfcknlfgcflmmmieb) — third-party services and extensions for Twitch used by millions of viewers and many top channels. This results in a poor mobile chat experience since only emote codes render rather than their image or GIF counterpart.

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
- And more...

For a more detailed overview, visit [frostyapp.io](https://www.frostyapp.io/).

## Development setup

1. Go to the [Twitch dev console](https://dev.twitch.tv/login) and register a new application to retrieve a **Client ID** and **Client Secret**.

2. Clone the repo to a directory (e.g., `git clone https://github.com/tommyxchow/frosty.git`).

3. Navigate to `lib/constants.dart` and replace the `clientId` and `secret` constants with your **client ID** and **client secret** from step 1 (if using VSCode, use `--dart-define` to [define them as environment variables](https://dartcode.org/docs/using-dart-define-in-flutter/)).

4. Run `flutter pub get` to fetch all the dependencies.

5. Choose an emulator or device and run the app!

> **Note**
>
> Frosty uses [MobX](https://mobx.netlify.app/) for state management. Please refer to the documentation about code generation, otherwise your changes within MobX stores may not be applied.

> **Warning**
>
> I built Frosty while learning Flutter, so some of the code may not be optimal. I'm working on refactoring, documenting, and cleaning up various parts as much as I can.

## Feature requests and issues

If you have a feature request, found a bug, or have a general issue, you can submit it [here](https://github.com/tommyxchow/frosty/issues/new/choose) on the issues tab. Doing so makes it easier for me to keep track of them and makes it publicly visible for others to review.

> **Note**
>
> I work on Frosty in my free time and take occasional breaks, so I may not respond immediately.

## Donate

Downloading Frosty and leaving a review or starring this repository is more than enough to show support.

If you're feeling generous and would like to support me with a donation, you can do so through the following:

- [Buy Me a Coffee](https://www.buymeacoffee.com/tommychow)
- [GitHub Sponsors](https://github.com/sponsors/tommyxchow)
- [PayPal](https://www.paypal.com/donate/?business=NF33JDG6KBU6W)
- BTC: bc1qzpth6gc3vum764lat6a8ul7cmekwles58070a6
- ETH: 0x317b5930fc2898884f711016dCae79d24910888E

If you decide to support me monetarily, it is extremely appreciated and further motivates me to continue improving and maintaining Frosty ❤️.

## License

Frosty is licensed under [AGPL-3.0-or-later](LICENSE).
