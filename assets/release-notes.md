## v5.2.0

August 16, 2026

### New Features

- Added moderator actions to delete messages, timeout, ban, and unban users from the message long-press menu and user panel (by @francislavoie on GitHub).
- Added channel bubbles in Twitch shared chat, so you can focus one participant or hide their messages.

### Improvements

- Improved the default video player by switching to native. It handles Picture-in-Picture, quality selection, and latency better than the legacy WebView player.
- Improved native player stability across device rotation (by @francislavoie on GitHub).
- [Android] Improved native player latency for live streams (by @francislavoie on GitHub).

### Bug Fixes

- Fixed the video player getting stuck paused with a play button that did nothing after leaving and returning to a stream.
- Fixed long-presses missing in fast-moving chat (by @francislavoie on GitHub).

---

## v5.1.0

June 13, 2026

### New Features

- Added a new experimental native video player option with quality selection, audio-only playback, Picture-in-Picture support, and improved latency recovery.
- Added merged chat mode for multi-tab chat, so messages from active tabs can be viewed together.
- Added new chat settings for keeping the screen on and showing timestamps on historical messages.
- Added support for linking your Twitch web session so the native player can use authenticated playback on eligible channels.

### Improvements

- Improved chat send reliability, especially when chat delay is enabled.
- Improved chat delay sync so control messages, acknowledgements, and reconnect notices are not delayed with chat messages.
- Improved video stability around refreshes, stalls, high latency, Picture-in-Picture, fullscreen, and ad breaks.
- Redesigned chat tabs with unread indicators, connection state styling, and disconnect options.

### Bug Fixes

- Fixed recent messages failing on valueless or escaped IRC tags.
- Fixed shared chat badges and emotes lingering after leaving shared chat.
- Fixed recent searches not saving from type-to-search.
- Fixed auto-synced chat delay not applying when toggled on mid-session.
- Fixed long chat inputs overlapping the message list.
- Fixed a video refresh race that could leave a black screen with only the play button visible.
- Fixed fullscreen button and system UI state getting out of sync.
- Fixed landscape safe area and iPad gesture padding issues.
- Fixed Twitch/API auth requests that could hang instead of failing cleanly.

---

## v5.0.5

January 9, 2026

### Bug Fixes

- Fixed lag/frame drops in overlay chat mode.
- Fixed draggable divider still interactable in fullscreen mode.
- Fixed landscape bottom padding in chat bottom bar.
- [iOS] Fixed user agent breaking login.

#### See all release notes at [https://github.com/tommyxchow/frosty/releases](https://github.com/tommyxchow/frosty/releases)
