<p align="center">
  <img src="https://user-images.githubusercontent.com/54859075/160067655-f96b7e62-67f7-43d6-96ea-19ac85418bf6.svg" width="180px" alt="Frosty Logo" />
  <h1 align="center">Frosty</h1>
</p>

<p align="center">
  A <a href="https://www.twitch.tv/">Twitch</a> client for iOS and Android with
  <a href="https://betterttv.com/">BTTV</a>,
  <a href="https://www.frankerfacez.com/">FFZ</a>, and
  <a href="https://7tv.app/">7TV</a> support. Built with
  <a href="https://flutter.dev/">Flutter</a>.
</p>


<p align="center">
  <a href="https://github.com/tommyxchow/frosty/actions/workflows/main.yml">
    <img
      alt="CI"
      src="https://github.com/tommyxchow/frosty/actions/workflows/main.yml/badge.svg"
    />
  </a>
  <a href="https://github.com/tommyxchow/frosty/blob/main/LICENSE">
    <img
      alt="License"
      src="https://img.shields.io/github/license/tommyxchow/frosty"
    />
  </a>
  <a href="https://github.com/tommyxchow/frosty/releases/latest">
    <img
      alt="Release"
      src="https://img.shields.io/github/v/release/tommyxchow/frosty"
    />
  </a>
</p>

<p align="center">
  <a
    href="https://apps.apple.com/us/app/frosty-for-twitch/id1603987585"
    target="_blank"
  >
    <img
      title="Get it on iOS (Apple App Store)"
      alt="Apple App Store Badge"
      src="https://user-images.githubusercontent.com/54859075/160051843-1d8b2186-97e9-4edd-a957-bb4797b71b4a.svg"
      width="200px"
    />
  </a>
  <a
    href="https://play.google.com/store/apps/details?id=com.tommychow.frosty"
    target="_blank"
  >
    <img
      title="Get it on Android (Google Play Store)"
      alt="Google Play Store Badge"
      src="https://user-images.githubusercontent.com/54859075/160051854-21a57556-6b5a-41e9-8127-334daf1fac47.svg"
      width="225px"
    />
  </a>
</p>

<p align="center">
  <a href="https://www.buymeacoffee.com/tommychow" target="_blank">
    <img
      title="Support the App!"
      alt="Buy Me A Coffee"
      src="https://user-images.githubusercontent.com/54859075/160051848-2e581476-a6c6-4de6-9af7-773d96632de1.svg"
      width="200px"
    />
  </a>
</p>

<p align="center">
  <img
    title="Followed Streams"
    alt="Followed Streams"
    src="https://user-images.githubusercontent.com/54859075/160052219-efd07a9d-491b-430e-88d0-6a9146ebaf69.png"
    width="32%"
  />
  <img
    title="Categories Section"
    alt="Categories Section"
    src="https://user-images.githubusercontent.com/54859075/160052212-9e0c74c4-658c-43b8-8d88-d6c9ae647acb.png"
    width="32%"
  />
  <img
    title="Search Section"
    alt="Search Section"
    src="https://user-images.githubusercontent.com/54859075/160052221-4c256c11-4c19-4b18-a6bd-d1b1d39e4b69.png"
    width="32%"
  />
  <img
    title="Channel (Video/Chat) View"
    alt="Channel (Video/Chat) View"
    src="https://user-images.githubusercontent.com/54859075/160052220-31e7575a-6140-430b-8c0a-b1f22919d637.png"
    width="32%"
  />
  <img
    title="Emote Menu"
    alt="Emote Menu"
    src="https://user-images.githubusercontent.com/54859075/160052223-742b2fc0-6ef2-4f47-a343-3e5b6e288ad1.png"
    width="32%"
  />
  <img
    title="Settings Section"
    alt="Settings Section"
    src="https://user-images.githubusercontent.com/54859075/160052222-91fd8b7a-f057-421e-97f6-1553e738fbbd.png"
    width="32%"
  />
</p>

## Features

- Browse followed streams, top streams, and top categories
- Search for channels and categories
- Watch live streams with chat
- Support for BTTV, FFZ, and 7TV emotes/badges
- View local chat user message history
- See the list of users in chat and filter them
- Theater and full-screen mode
- Block and unblock users
- Light, dark, and black (OLED) themes
- Picture-in-picture mode (iOS only)
- Customizable settings

## Motivation

A major problem with the official Twitch app for many users is that emotes from services such as [BetterTTV (BTTV)](https://chrome.google.com/webstore/detail/betterttv/ajopnjidmegmdimjlfnijceegpefgped), [FrankerFaceZ (FFZ)](https://chrome.google.com/webstore/detail/frankerfacez/fadndhdgpmmaapbmfcknlfgcflmmmieb), and [7TV](https://chrome.google.com/webstore/detail/7tv/ammjkodgmmoknidbanneddgankgfejfh) are not officially supported. Twitch is unaffiliated with these services, hence why they haven't been integrated officially.

As a result, the millions of users of these services have an unideal viewing experience on the official Twitch app. In the stream chat, only text is positioned where emotes should be (imagine only being able to see :emoji_code: rather than the emojis themselves).

Frosty aims to bring these emotes and other general quality of life features to **both iOS and Android**.

## Development Setup

1. Go to the [Twitch dev console](https://dev.twitch.tv/login) and register a new application to retrieve a **client ID** and **client secret** and add a **OAuth redirect URL**.

2. Clone the repo to a directory.

3. Navigate to `lib/constants/constants.dart` and replace the `clientId` and `secret` constants with your **client ID** and **client secret** (or better yet, if using VSCode use `--dart-define` to [define them as environment variables](https://dartcode.org/docs/using-dart-define-in-flutter/)).

4. Navigate to `android/app/src/main/AndroidManifest.xml` and under the `flutter_web_auth` intent filter replace the value of `android:scheme` to the scheme in your **OAuth redirect URL**.

5. Run `flutter pub get` to fetch all the dependencies.

6. Choose an emulator or device and run the app!

## FAQ

### Why do certain animations and scrolling appear to be janky?

Due to Flutter, there may be some stutter and jank on the first installation and launch. After using and moving around the app for a bit the jank will be mitigated through shader warmup/caching and should be minimal on subsequent launches. Watching a stream with a relatively fast chat for a couple of minutes usually resolves it for me.

### Why am I getting ads even though I'm subscribed to the channel or have Turbo?

Even if you've logged in to the app, you'll still have to log in to the WebView so that you can be identified when the stream plays. You can do so by going to the settings and then under the "Account" section tap the "Log in to WebView" button.

### How can I change the quality of the stream?

On Android, you can change the stream quality by turning off the custom stream overlay in the settings and tapping the gear icon on the bottom right.

On iOS, sadly quality options aren't available through the native player and rely on an "auto" setting. There is no official API for getting the live stream URLs so specific quality options are not possible at this time.

### Why is there a delay between the stream and chat?

On Android, the delay should be minimal. Try refreshing the player if you have a delay.

On iOS, there seems to be delays up to 15 seconds due to the native player so unfortunately it's out of my control. The best you can do for now is refreshing or pausing/playing the stream until the delay is minimized.

### Why are some GIFs either slow or very fast?

This seems to be caused by the Flutter framework itself (see [here](https://github.com/flutter/flutter/issues/24804) and [here](https://github.com/flutter/flutter/issues/29130)).

### Why is ProMotion (120hz) not working?

This is caused by the Flutter framework and is being worked on (see [here](https://github.com/flutter/flutter/issues/90675)).

### Why is feature "X" from Twitch not in the app as well?

I'm limited to what is available in the [Twitch API](https://dev.twitch.tv/docs/api/reference), so certain features from the Twitch web or mobile app (e.g., voting on predictions and category viewer count) are sadly not available at the moment.

I'll try to add as many features as possible but occasionally I may take a break or be limited in time due to studies and personal reasons.

### I'd like to report a bug or request a new feature. Where can I do that?

You can open a new issue [here](https://github.com/tommyxchow/frosty/issues) with the appropriate labels and I'll take a look at it.

## License

Frosty is licensed under [AGPL-3.0-or-later](LICENSE).
