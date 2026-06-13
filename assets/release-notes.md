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

---

## v5.0.4

January 8, 2026

### Improvements

- Swipe down to PiP gesture now works in landscape mode.
- The rotate button now adjusts to your device's physical orientation instead of always rotating to the same direction.
- Replaced "Fill notch side" setting with "Fill all edges" and made edge padding auto-adjust based on device rotation.

### Bug Fixes

- Fixed Google login not working.
- [iOS] Fixed bottom safe area in landscape mode.

---

## v5.0.3

January 6, 2026

### Improvements

- Reconnection messages now update in place instead of spamming chat.
- Chat now shows sending status and relevant error notifications when messages fail to send.
- [Android] The "Enhanced rendering" video setting has been renamed to "Fast video rendering" and reset to enabled for all users.

### Bug Fixes

- Fixed send button not working in landscape mode.
- Fixed text field input being cleared before server confirmation.

---

## v5.0.2

January 4, 2026

### Improvements

- Inline emote support in the chat text field.
- Search page now uses type-to-search for faster navigation.
- Restored ability to send messages while chat delay is active.
- Restored chat delay input indicator.
- Redesigned the reply bar.

### Bug Fixes

- Fixed reply bar and autocomplete bar blocking the bottom of chat.
- Fixed clear recent emotes button sizing.
- Fixed black screen when logging in.

---

## v5.0.1

January 2, 2026

### Improvements

- [Android] Enhanced video rendering is now enabled by default for better performance. Disable in settings if you experience crashes.
- [Android] Re-enabled Flutter Impeller rendering engine for better performance.
- Restored the "Show latency" setting in video overlay options.

### Bug Fixes

- [Android] Potentially fixed crash on app startup related to secure storage.

---

## v5.0.0

January 1, 2026

### New Features

- Open multiple chat tabs for different channels with drag-to-reorder. Tabs are saved between sessions by default (configurable in settings).
- Resize the chat and video areas in landscape mode by dragging the divider.
- A new section in the Following tab shows which of your followed channels are currently offline.
- Change your chat username color from the chat details menu.
- A new randomize button for the accent color theme in settings.
- View emotes and stream thumbnails in full resolution with swipe-to-dismiss gestures.
- [Android] Open Twitch channel links directly in Frosty instead of the browser or Twitch app (by @micahmo on GitHub).

### Improvements

- Swipe down to enter Picture-in-Picture mode, and press the PiP button again to exit.
- Redesigned the video overlay and added stream details to the app bar in chat-only mode.
- Networking and data handling have been completely rewritten to be faster and more reliable.
- Improved formatting for chat replies, quick copy-to-input for messages, and a clearer countdown for chat delays.

### Bug Fixes

- Fixed chat text input not unfocusing when tapping outside of it (by @zeykafx on GitHub).
- Fixed missing badges and emotes in historical messages upon initial connection.
- Fixed accidental chat scrolling when accessing system UI gestures in landscape mode.
- Fixed chat reconnection issues when a chat delay was active.
- Fixed duplicate message cases and various UI stability issues.

#### See all release notes at [https://github.com/tommyxchow/frosty/releases](https://github.com/tommyxchow/frosty/releases)
