# Chat performance backlog

Findings from a chat-rendering performance audit (2026-07), verified against the pinned Flutter 3.44.2 SDK source and installed package sources. The top-ranked confirmed items were fixed on `tc/chat-perf`; this file tracks what remains, ranked by expected impact. Line references are to the SDK/package versions pinned at audit time.

## Fixed in the initial pass (for context)

- `findChildIndexCallback` on both chat ListViews. Per-item `ObjectKey`s without it forced deactivate + re-inflate of every built row on every 200 ms flush (`SliverMultiBoxAdaptorElement.performRebuild` matches purely by position when `findIndexByKey` returns null; key mismatch at each shifted index lands in the remount branch of `Element.updateChild`, framework.dart:4047).
- Per-message widget caching (`Expando` in `chat.dart`). Identical widget instances short-circuit `Element.updateChild` (framework.dart:4014), so a flush only builds genuinely new messages instead of re-running `generateSpan` for every visible row. Invalidated via `IRCMessage.renderRevision` (bumped by the in-place CLEARCHAT/CLEARMSG mutations).
- `memCacheHeight` for emotes and badges (decode at display size instead of the CDN's 3x-4x intrinsic size; verified animation-safe: `ResizeImage` applies the target size to the codec, all frames included).
- `TickerMode(enabled: false)` on inactive `IndexedStack` tabs (the `Image` widget pauses animated codecs when TickerMode is off, image.dart:1151; IndexedStack's own `Visibility(maintainAnimation: true)` wrapper never disables tickers).
- Flush timers pause while the app is backgrounded (`onAppPaused`/`onAppResumed` through `ChatTabsStore` -> each tab's `ChatStore` + the merged render timer). Frames stop when paused (`SchedulerBinding.framesEnabled`) but Dart timers don't, so the 5 Hz wakeups were pure battery cost.
- Startup orphaned-cache sweep switched from `listSync` (synchronous I/O on the UI isolate, up to ~10k files) to async `list()`.
- `adjustChatNameColor` memoized keyed by (color, background, target contrast).

## Remaining items, ranked

### 1. "Animate emotes" setting (first-frame / static mode)

The biggest remaining battery lever. Every mounted animated emote keeps a decode -> `scheduleFrameCallback` loop running indefinitely while any listener is attached (cached_network_image ships its own copy of the SDK's `MultiFrameImageStreamCompleter` with identical behavior: `multi_image_stream_completer.dart:165`). "Mounted" includes rows inside the 500 px `scrollCacheExtent`, not just visible ones. The engine never idles at vsync while a busy chat is on screen. OS reduce-motion already pauses this (Image honors `MediaQuery.disableAnimations`), and inactive tabs now pause via TickerMode, but the visible tab still animates dozens of emotes continuously.

Options: a setting that requests static CDN variants (7TV/BTTV/FFZ all serve static URLs), or a one-frame custom ImageProvider. Effort: M-L. User-visible setting.

### 2. Disconnect IRC while backgrounded (Android)

Flush timers now pause, but every IRC line is still received and parsed while backgrounded (50+ msg/s in busy channels = continuous CPU + radio with zero visible output; on iOS the OS suspends the runtime anyway, so this is Android + iOS-PiP). Twitch's own app disconnects chat in background. Disconnect after a grace period, reconnect on resume, optionally backfill via recent-messages when the setting is on. Behavior-visible: a scrollback gap while backgrounded. Effort: M.

### 3. Skip flushing inactive tabs

Offstage IndexedStack tabs still lay out and rebuild their lists on every 200 ms flush (builds are cheap now with widget caching, but `RenderStack.performLayout` is O(N) over all children, stack.dart:678, and each offstage viewport lays out its cache-extent rows). Gate `addMessages` for non-active tabs; the buffer overflow drain already bounds growth. Must keep flushing when `mergedMode` is on (merged view reads each tab's `messages`), and `hasUnreadMessages` should read the buffer too. Effort: M.

### 4. BTTV badge SVGs bypass the disk cache

`SvgPicture.network` (irc.dart `_createBadgeWidget`) uses plain http with a ref-counted in-memory picture cache (flutter_svg 2.3.0 loaders.dart:436; vector_graphics `_livePictureCache` evicts when the last widget goes away). Badges re-download every session and can re-fetch within a session. Route bytes through `CustomCacheManager` and feed `SvgPicture.string`/a bytes loader. Effort: S-M.

### 5. Merged-mode dirty check

`_refreshMergedMessages` collects + sorts up to tabs x 100 items and assigns a new list identity every 200 ms tick even when no new messages arrived, re-firing the merged list observer at a constant 5 Hz. Track per-tab message counts and short-circuit when unchanged. Effort: S.

### 6. Trim IRCMessage memory (drop `raw` retention)

Each message retains the full raw IRC line (0.5-1 KB) plus substring copies in `tags`, the `split` word list, and an unconditionally allocated (usually empty) `localEmotes` map: roughly 1.5-3 KB per message, ~8-15 MB per tab at the 5000 cap, ~100 MB order across 10 busy tabs. Verify nothing consumes `raw` after parse and drop or lazily derive it; skip allocating empty `localEmotes`. Effort: S-M.

### 7. Dispose TapGestureRecognizers from generateSpan

`TextSpan.recognizer` contract says the owner must dispose (text_span.dart:124), and nothing does. Verified low severity: an idle recognizer holds no timers, arena entries, or router routes (those attach on pointer-down only), so undisposed ones are plain GC-able garbage, and widget caching now creates them once per message instead of per rebuild. Remaining real defect: a row rebuild between pointer-down and up swaps recognizers and silently drops that tap. Proper fix needs recognizer ownership with a dispose hook (stateful row or registry keyed to message eviction). Effort: M.

### 8. Lighter tap targets than per-emote InkWell

Each emote/badge InkWell eagerly builds ~7 widgets, a FocusNode, and a global focus-highlight listener (ink_well.dart:929, build at :1386); Tooltips on historical/shared-chat badges each add a global pointer route consulted on every pointer event (raw_tooltip.dart:793). Mostly a first-build cost now that rows are cached; if profiling still shows element bloat, swap emotes to `GestureDetector` (loses the ripple, which never realistically fires in chat). Effort: S.

### 9. memCache sizing for remaining image sites

Not yet covered: the shared-chat source avatar (raw `CachedNetworkImage` with `imageBuilder` in irc.dart, needs verification of how memCacheWidth interacts with imageBuilder's provider), `ProfilePicture`, and the emote menu panels. Effort: S.

### 10. Adaptive CDN density selection

Emote URLs still request max density (Twitch `3.0`, BTTV `3x`, FFZ `4x`, 7TV largest non-AVIF) and rely on decode-time downscaling. Picking the 2x variant when DPR x display-size allows would also save bandwidth and disk. Tradeoff: cache churn when `emoteScale` changes. 7TV note: dims come from `files.first` (1x) while the URL is the largest file; that is intentional (layout at 1x size), keep it. Effort: M.

### 11. Parse-path micro-optimizations

All parse-time (once per message, not per frame), verified minor: per-grapheme `regexEmoji.hasMatch` loop in `IRCMessage.fromString` (single-pass scan instead), blocked-users linear list scan per message (use a Set of user ids), muted-words O(words x patterns). Effort: S.

### 12. errorWidget for failed images

No `errorWidget`/`errorBuilder` anywhere in lib; failed emote/badge/avatar loads render as silent blanks. Hygiene + debuggability. Effort: S.

### 13. Screen-reader story for the chat list

With a screen reader on, a 5 Hz-updating list of WidgetSpan-heavy rows is a semantics hazard (each emote is an unlabeled node; constant re-announcement). Semantics are compiled only when assistive tech is active (object.dart:1397), so this costs nothing today, but consider per-row `Semantics(label:)` flattening and update throttling when semantics are enabled. Effort: M-L.

### 14. Measurement follow-ups

- Profile-mode DevTools timeline during a busy raid chat: UI thread (span builds should now be flat between new messages) and raster thread (animated emote layers).
- Memory view: ImageCache pressure before/after memCacheHeight (entry count is the binding cap: 1000 images / 100 MiB defaults, image_cache.dart:18).
- Android `dumpsys batterystats` / Xcode Energy gauge for the background and animated-emote items.
- A benchmark harness feeding recorded IRC traffic through `ChatStore` would make regressions visible in CI; nothing covers chat rendering today.

## Existing optimizations: verified verdicts (do not relitigate)

| Optimization | Verdict |
| --- | --- |
| 200 ms flush batching | KEEP (right pattern; interval fine) |
| Render cap 100 while autoscrolling, 5000 buffer + 20% trim | KEEP (trim realloc is per-event, cheap; see item 6 for the per-message footprint) |
| `ObjectKey(ircMessage)` on rows | KEEP, now paired with `findChildIndexCallback` (alone it was actively harmful: forced remounts) |
| `addAutomaticKeepAlives: false` | KEEP (micro; known tradeoff: in-flight ink splash can be culled, SelectionArea rows lose keep-alive) |
| `scrollCacheExtent: 500 px` | KEEP (default is 250, applied both sides; revisit only alongside item 1 since it doubles the live animated-emote set) |
| Disk cache 10k objects / 30 d | KEEP (cleanup is lazy, debounced, SQL-side, bounded to 200 deletes per pass) |
| `useFade: false` + const placeholders on emotes | KEEP |
| `cacheKey` on FrostyCachedNetworkImage | KEEP (live for stream thumbnails' 5-min busting; unused in chat paths by design) |
| ProfilePicture static URL cache | KEEP (unbounded but tiny; known staleness until app restart) |
| IndexedStack tab keep-alive | KEEP, now paired with TickerMode gating |
| Per-message `Opacity` fades | KEEP (compositing layer, not saveLayer; static opacity is cheap and adds a repaint boundary) |
| Muted-word pre-normalization, interaction pause, delayed-callback queue, 60 s socket ping | KEEP |
