import 'package:mobx/mobx.dart';

/// Tracks user-driven spotlight/hide selections for participant channels in
/// a Twitch shared chat session (multiple broadcasters merged onto one IRC
/// connection). Pure state so it can be unit-tested without the chat store.
///
/// [ObservableSet] is reactive on its own, so [Observer] widgets reading
/// [focusedChannelIds]/[hiddenChannelIds] rebuild without any MobX codegen.
class SharedChatBubbleState {
  /// Channel ids the user has spotlighted (kept unfaded). Empty means no
  /// spotlight is active and nothing is faded.
  final focusedChannelIds = ObservableSet<String>();

  /// Channel ids whose messages are filtered out of the feed entirely.
  final hiddenChannelIds = ObservableSet<String>();

  /// Adds/removes [channelId] from the spotlight set.
  void toggleFocus(String channelId) {
    if (!focusedChannelIds.remove(channelId)) {
      focusedChannelIds.add(channelId);
    }
  }

  /// Hides [channelId]'s messages and drops it from the spotlight set.
  void hide(String channelId) {
    hiddenChannelIds.add(channelId);
    focusedChannelIds.remove(channelId);
  }

  /// Un-hides [channelId]'s messages.
  void show(String channelId) => hiddenChannelIds.remove(channelId);

  bool isFocused(String channelId) => focusedChannelIds.contains(channelId);

  bool isHidden(String channelId) => hiddenChannelIds.contains(channelId);

  /// Clears both sets (e.g. when a shared chat session ends).
  void reset() {
    focusedChannelIds.clear();
    hiddenChannelIds.clear();
  }
}
