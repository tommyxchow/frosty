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
