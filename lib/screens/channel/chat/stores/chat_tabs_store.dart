import 'dart:async';

import 'package:flutter/material.dart';
import 'package:frosty/apis/bttv_api.dart';
import 'package:frosty/apis/ffz_api.dart';
import 'package:frosty/apis/seventv_api.dart';
import 'package:frosty/apis/twitch_api.dart';
import 'package:frosty/models/irc.dart';
import 'package:frosty/models/stream.dart';
import 'package:frosty/models/user.dart';
import 'package:frosty/screens/channel/chat/details/chat_details_store.dart';
import 'package:frosty/screens/channel/chat/stores/chat_assets_store.dart';
import 'package:frosty/screens/channel/chat/stores/chat_store.dart';
import 'package:frosty/screens/settings/stores/auth_store.dart';
import 'package:frosty/screens/settings/stores/settings_store.dart';
import 'package:frosty/stores/global_assets_store.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mobx/mobx.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

part 'chat_tabs_store.g.dart';

/// Lightweight data class for persisting chat tab info to settings.
/// Does NOT include ChatStore since WebSocket connections cannot be persisted.
@JsonSerializable()
class PersistedChatTab {
  final String channelId;
  final String channelLogin;
  final String displayName;

  const PersistedChatTab({
    required this.channelId,
    required this.channelLogin,
    required this.displayName,
  });

  factory PersistedChatTab.fromJson(Map<String, dynamic> json) =>
      _$PersistedChatTabFromJson(json);
  Map<String, dynamic> toJson() => _$PersistedChatTabToJson(this);

  /// Create from a ChatTabInfo (for syncing current tabs to settings).
  factory PersistedChatTab.fromChatTabInfo(ChatTabInfo info) =>
      PersistedChatTab(
        channelId: info.channelId,
        channelLogin: info.channelLogin,
        displayName: info.displayName,
      );
}

/// Data class holding information about a chat tab.
class ChatTabInfo {
  final String channelId;
  final String channelLogin;
  final String displayName;

  /// The ChatStore for this tab. Null until the tab is activated (lazy loading).
  ChatStore? chatStore;

  /// The id of the most recent message visible the last time the user viewed
  /// this tab. Used to compute unread state — null means "no baseline yet".
  String? lastSeenMessageId;

  /// Whether this is the primary tab (first tab, cannot be removed).
  final bool isPrimary;

  /// Whether this tab has been activated (chatStore created).
  bool get isActivated => chatStore != null;

  ChatTabInfo({
    required this.channelId,
    required this.channelLogin,
    required this.displayName,
    this.chatStore,
    required this.isPrimary,
  });
}

/// A message paired with its source ChatStore for merged view rendering.
class MergedMessage {
  final IRCMessage ircMessage;
  final ChatStore chatStore;

  const MergedMessage({required this.ircMessage, required this.chatStore});
}

/// Store that manages multiple chat tabs.
class ChatTabsStore = ChatTabsStoreBase with _$ChatTabsStore;

abstract class ChatTabsStoreBase with Store {
  /// Maximum number of tabs allowed.
  static const maxTabs = 10;

  /// Max messages to render in merged view when autoscrolling.
  static const _mergedRenderLimit = 100;

  /// API services needed for creating ChatStore instances.
  final TwitchApi twitchApi;
  final BTTVApi bttvApi;
  final FFZApi ffzApi;
  final SevenTVApi sevenTVApi;

  /// Global stores passed to each ChatStore.
  final AuthStore authStore;
  final SettingsStore settingsStore;
  final GlobalAssetsStore globalAssetsStore;

  /// The list of open chat tabs.
  @readonly
  var _tabs = ObservableList<ChatTabInfo>();

  /// The index of the currently active tab.
  @observable
  var activeTabIndex = 0;

  /// Returns the currently active tab info.
  @computed
  ChatTabInfo get activeTab => _tabs[activeTabIndex];

  /// Returns the ChatStore of the currently active tab.
  /// The active tab is always activated, so this should never be null.
  @computed
  ChatStore get activeChatStore => _tabs[activeTabIndex].chatStore!;

  /// Whether we can add more tabs (under the limit).
  @computed
  bool get canAddTab => _tabs.length < maxTabs;

  /// Whether the tab bar should be visible (more than 1 tab).
  @computed
  bool get showTabBar => _tabs.length > 1;

  /// Whether merged chat mode is active (session-only, not persisted).
  @observable
  var mergedMode = false;

  /// Channel profiles for badge rendering in merged view.
  final _tabChannelProfiles = ObservableMap<String, UserTwitch>();

  /// Scroll controller for the merged chat view.
  final mergedScrollController = ScrollController();

  /// Whether the merged view should auto-scroll.
  @readonly
  var _mergedAutoScroll = true;

  /// Timer-driven rendered messages for merged view.
  /// Updated every 200ms to match normal chat's batched flush cadence,
  /// instead of reacting to each per-tab ObservableList mutation.
  @readonly
  var _mergedRenderedMessages = <MergedMessage>[];

  /// Timer that drives merged message rendering at a fixed cadence.
  Timer? _mergedRenderTimer;

  /// Frozen snapshot of merged messages when user scrolls up.
  /// Prevents new messages from causing scroll jumps while reading.
  List<MergedMessage>? _mergedSnapshot;

  /// Total message count across all tabs when the snapshot was taken.
  int _mergedSnapshotTotalCount = 0;

  /// Combined channel-to-user map for merged view badge rendering.
  @computed
  Map<String, UserTwitch> get mergedChannelIdToUserTwitch {
    final merged = <String, UserTwitch>{};
    for (final tab in _tabs) {
      if (tab.chatStore != null) {
        merged.addAll(tab.chatStore!.assetsStore.channelIdToUserTwitch);
      }
    }
    merged.addAll(_tabChannelProfiles);
    return merged;
  }

  static int _compareByTimestamp(MergedMessage a, MergedMessage b) {
    final aTs = int.tryParse(a.ircMessage.tags['tmi-sent-ts'] ?? '') ?? 0;
    final bTs = int.tryParse(b.ircMessage.tags['tmi-sent-ts'] ?? '') ?? 0;
    return aTs.compareTo(bTs);
  }

  /// Adds messages from [store] to [out], deduplicating by message ID
  /// (handles Twitch shared chat where the same message arrives on multiple
  /// IRC connections). Includes messageBuffer only when the tab's own
  /// autoScroll is off (paused tabs whose timer won't flush).
  void _collectMessages(
    ChatStore store,
    List<MergedMessage> out,
    Set<String> seenIds, {
    int? tailCount,
  }) {
    final msgs = store.messages;
    final start =
        tailCount != null && msgs.length > tailCount ? msgs.length - tailCount : 0;
    for (var i = start; i < msgs.length; i++) {
      final id = msgs[i].tags['id'];
      if (id != null && !seenIds.add(id)) continue;
      out.add(MergedMessage(ircMessage: msgs[i], chatStore: store));
    }
    // Only read messageBuffer for paused tabs — their timer won't flush
    // so these messages would otherwise be invisible in merged view.
    if (!store.autoScroll) {
      for (final msg in store.messageBuffer) {
        final id = msg.tags['id'];
        if (id != null && !seenIds.add(id)) continue;
        out.add(MergedMessage(ircMessage: msg, chatStore: store));
      }
    }
  }

  /// Collects, sorts, and caps all messages from all tabs.
  List<MergedMessage> _computeAllMergedMessages() {
    final allMessages = <MergedMessage>[];
    final seenIds = <String>{};
    for (final tab in _tabs) {
      if (tab.chatStore == null) continue;
      _collectMessages(tab.chatStore!, allMessages, seenIds);
    }
    allMessages.sort(_compareByTimestamp);
    return allMessages;
  }

  /// Fast path: only collects the tail of each tab's messages for autoscroll.
  /// Instead of sorting all 50k messages, sorts at most k*100 items.
  List<MergedMessage> _computeRecentMergedMessages() {
    final recent = <MergedMessage>[];
    final seenIds = <String>{};
    for (final tab in _tabs) {
      if (tab.chatStore == null) continue;
      _collectMessages(tab.chatStore!, recent, seenIds, tailCount: _mergedRenderLimit);
    }
    recent.sort(_compareByTimestamp);
    if (recent.length > _mergedRenderLimit) {
      return recent.sublist(recent.length - _mergedRenderLimit);
    }
    return recent;
  }

  /// Interleaved messages from all activated tabs, sorted by timestamp.
  /// During autoscroll, returns timer-driven [_mergedRenderedMessages] which
  /// updates every 200ms — matching normal chat's batched flush cadence.
  /// When scrolled up, returns a frozen snapshot.
  @computed
  List<MergedMessage> get mergedMessages {
    if (!_mergedAutoScroll && _mergedSnapshot != null) {
      return _mergedSnapshot!;
    }
    return _mergedRenderedMessages;
  }

  /// Refreshes the rendered merged messages. Called by the render timer.
  @action
  void _refreshMergedMessages() {
    if (!_mergedAutoScroll) return;
    _mergedRenderedMessages = _computeRecentMergedMessages();
  }

  /// Count of new messages since the user scrolled up (for "N new messages").
  /// Total messages (messages + messageBuffer) across all tabs.
  int _totalMessageCount() {
    var total = 0;
    for (final tab in _tabs) {
      if (tab.chatStore != null) {
        total +=
            tab.chatStore!.messages.length + tab.chatStore!.messageBuffer.length;
      }
    }
    return total;
  }

  @computed
  int get mergedBufferCount {
    if (!_mergedAutoScroll && _mergedSnapshot != null) {
      final diff = _totalMessageCount() - _mergedSnapshotTotalCount;
      return diff > 0 ? diff : 0;
    }
    return 0;
  }

  /// Public getter for the tabs list.
  List<ChatTabInfo> get tabs => _tabs;

  /// Live stream info keyed by channel userId. Entries only exist for
  /// currently-live channels; offline channels have no entry.
  final _liveStreams = ObservableMap<String, StreamTwitch>();

  /// True once the first live-status fetch has completed. Until then we
  /// treat all channels as live to avoid a grayscale flash on startup.
  bool _liveStatusFetched = false;

  Timer? _liveStatusTimer;
  static const _liveStatusPeriod = Duration(seconds: 90);

  /// Whether [channelId] is currently live according to the latest fetch.
  bool isTabLive(String channelId) {
    if (!_liveStatusFetched) return true;
    return _liveStreams.containsKey(channelId);
  }

  /// Returns live stream info for [channelId], or null if offline / unknown.
  /// Used by the long-press popover to render title / game / viewer count.
  StreamTwitch? getStreamInfo(String channelId) => _liveStreams[channelId];

  ChatTabsStoreBase({
    required this.twitchApi,
    required this.bttvApi,
    required this.ffzApi,
    required this.sevenTVApi,
    required this.authStore,
    required this.settingsStore,
    required this.globalAssetsStore,
    required String primaryChannelId,
    required String primaryChannelLogin,
    required String primaryDisplayName,
  }) {
    // Enable wakelock once for all chat tabs
    if (settingsStore.keepScreenAwake) {
      WakelockPlus.enable();
    }

    // Initialize with the primary channel tab
    _addPrimaryTab(
      channelId: primaryChannelId,
      channelLogin: primaryChannelLogin,
      displayName: primaryDisplayName,
    );

    // Restore persisted secondary tabs if feature is enabled
    if (settingsStore.persistChatTabs) {
      _restoreSecondaryTabs(primaryChannelId: primaryChannelId);
    }

    // Live-status data only powers the tab-chip avatar grayscale and the
    // long-press popover, neither of which renders with a single tab —
    // so skip the radio wake until a second tab is added.
    _syncLiveStatusTimer();

    // Set up merged scroll listener once (reused across toggle cycles)
    mergedScrollController.addListener(() {
      if (!mergedScrollController.hasClients) return;
      runInAction(() {
        if (mergedScrollController.position.pixels <= 0) {
          if (!_mergedAutoScroll) {
            _mergedSnapshot = null;
            _mergedAutoScroll = true;
          }
        } else if (mergedScrollController.position.pixels > 0) {
          if (_mergedAutoScroll) {
            // Capture snapshot so the list stays frozen while scrolling
            _mergedSnapshot = _computeAllMergedMessages();
            _mergedSnapshotTotalCount = _totalMessageCount();
            _mergedAutoScroll = false;
          }
        }
      });
    });
  }

  /// Creates a ChatStore for a given channel.
  ChatStore _createChatStore({
    required String channelId,
    required String channelLogin,
    required String displayName,
  }) {
    return ChatStore(
      twitchApi: twitchApi,
      channelName: channelLogin,
      channelId: channelId,
      displayName: displayName,
      auth: authStore,
      settings: settingsStore,
      chatDetailsStore: ChatDetailsStore(
        twitchApi: twitchApi,
        channelName: channelLogin,
      ),
      assetsStore: ChatAssetsStore(
        twitchApi: twitchApi,
        ffzApi: ffzApi,
        bttvApi: bttvApi,
        sevenTVApi: sevenTVApi,
        globalAssetsStore: globalAssetsStore,
      ),
    );
  }

  /// Toggles merged chat mode. Only already-activated tabs are included;
  /// tapping a lazy tab in merged mode activates it and adds it to the merge.
  @action
  void toggleMergedMode() {
    mergedMode = !mergedMode;
    if (mergedMode) {
      // Reset scroll state
      _mergedAutoScroll = true;
      _mergedSnapshot = null;
      // Fetch channel profiles for activated tabs only
      for (final tab in _tabs) {
        if (tab.chatStore != null) {
          _fetchTabChannelProfile(tab);
        }
      }
      // Start render timer — compute immediately then every 200ms
      _refreshMergedMessages();
      _mergedRenderTimer?.cancel();
      _mergedRenderTimer = Timer.periodic(
        const Duration(milliseconds: 200),
        (_) => _refreshMergedMessages(),
      );
    } else {
      _mergedRenderTimer?.cancel();
      _mergedRenderTimer = null;
      _mergedRenderedMessages = [];
    }
  }

  /// Re-enables auto-scroll and jumps to the latest message in merged view.
  @action
  void resumeMergedScroll() {
    _mergedSnapshot = null;
    _mergedAutoScroll = true;
    // Refresh immediately so the list shows latest messages before the
    // next timer tick.
    _refreshMergedMessages();
    mergedScrollController.jumpTo(0);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mergedScrollController.hasClients) {
        mergedScrollController.jumpTo(0);
      }
    });
  }

  /// Fetches the channel profile for badge rendering in merged view.
  Future<void> _fetchTabChannelProfile(ChatTabInfo tab) async {
    if (_tabChannelProfiles.containsKey(tab.channelId)) return;
    try {
      final user = await twitchApi.getUser(id: tab.channelId);
      _tabChannelProfiles[tab.channelId] = user;
    } catch (e) {
      debugPrint('Failed to fetch profile for ${tab.channelLogin}: $e');
    }
  }

  /// Activates a tab by creating its ChatStore if not already activated.
  @action
  void activateTab(int index) {
    if (index < 0 || index >= _tabs.length) return;

    final tab = _tabs[index];
    if (tab.chatStore != null) return; // Already activated

    tab.chatStore = _createChatStore(
      channelId: tab.channelId,
      channelLogin: tab.channelLogin,
      displayName: tab.displayName,
    );
  }

  /// Adds the primary tab (called during initialization).
  void _addPrimaryTab({
    required String channelId,
    required String channelLogin,
    required String displayName,
  }) {
    final chatStore = _createChatStore(
      channelId: channelId,
      channelLogin: channelLogin,
      displayName: displayName,
    );

    _tabs.add(
      ChatTabInfo(
        channelId: channelId,
        channelLogin: channelLogin,
        displayName: displayName,
        chatStore: chatStore,
        isPrimary: true,
      ),
    );
  }

  /// Restores secondary tabs from settings (lazy - no ChatStore created).
  void _restoreSecondaryTabs({required String primaryChannelId}) {
    for (final persisted in settingsStore.secondaryTabs) {
      // Skip if this is the same as the primary tab (already added)
      if (persisted.channelId == primaryChannelId) {
        continue;
      }

      // Skip if at max capacity
      if (_tabs.length >= maxTabs) {
        break;
      }

      // Add tab without ChatStore (lazy loading)
      _tabs.add(
        ChatTabInfo(
          channelId: persisted.channelId,
          channelLogin: persisted.channelLogin,
          displayName: persisted.displayName,
          isPrimary: false,
        ),
      );
    }
  }

  /// Syncs current secondary tabs to settings for persistence.
  void _syncSecondaryTabsToSettings() {
    if (!settingsStore.persistChatTabs) return;

    // Get all non-primary tabs and convert to PersistedChatTab
    final secondaryTabs = _tabs
        .where((tab) => !tab.isPrimary)
        .map(PersistedChatTab.fromChatTabInfo)
        .toList();

    // Update settings (autorun will handle persistence)
    settingsStore.secondaryTabs = secondaryTabs;
  }

  /// Adds a new chat tab for the given channel.
  /// Returns true if the tab was added, false if at limit or duplicate.
  @action
  bool addTab({
    required String channelId,
    required String channelLogin,
    required String displayName,
  }) {
    // Check if at max capacity
    if (_tabs.length >= maxTabs) {
      return false;
    }

    // Check for duplicate channel
    final existingIndex = _tabs.indexWhere((tab) => tab.channelId == channelId);
    if (existingIndex != -1) {
      // Switch to existing tab instead of adding duplicate
      setActiveTab(existingIndex);
      return false;
    }

    // Add the new tab (lazy - no ChatStore yet)
    _tabs.add(
      ChatTabInfo(
        channelId: channelId,
        channelLogin: channelLogin,
        displayName: displayName,
        isPrimary: false,
      ),
    );

    // Switch to the new tab (this will activate it)
    final newIndex = _tabs.length - 1;
    activateTab(newIndex);
    activeTabIndex = newIndex;

    // If in merged mode, fetch the new tab's channel profile
    if (mergedMode) {
      _fetchTabChannelProfile(_tabs[newIndex]);
    }

    _syncLiveStatusTimer();

    // Sync to settings for persistence
    _syncSecondaryTabsToSettings();

    return true;
  }

  /// Deactivates a tab by disposing its ChatStore without removing the tab.
  /// The tab stays in the tab bar but appears dimmed. Tapping reactivates it.
  @action
  void deactivateTab(int index) {
    if (index < 0 || index >= _tabs.length) return;
    final tab = _tabs[index];
    if (tab.isPrimary) return;
    if (tab.chatStore == null) return;

    // If this is the active tab, switch to primary
    if (index == activeTabIndex) {
      activeTabIndex = 0;
    }

    // Clean up merged mode state
    if (mergedMode) {
      _tabChannelProfiles.remove(tab.channelId);
      _mergedSnapshot = null;
    }

    // Dispose the ChatStore (closes IRC connection)
    tab.chatStore!.dispose();
    tab.chatStore = null;

    // Exit merged mode if fewer than 2 tabs remain activated
    if (mergedMode && _tabs.where((t) => t.chatStore != null).length < 2) {
      mergedMode = false;
      _mergedRenderTimer?.cancel();
      _mergedRenderTimer = null;
      _mergedRenderedMessages = [];
    }
  }

  /// Removes the tab at the given index.
  /// Returns true if removed, false if primary tab or invalid index.
  @action
  bool removeTab(int index) {
    // Validate index
    if (index < 0 || index >= _tabs.length) {
      return false;
    }

    // Cannot remove primary tab
    if (_tabs[index].isPrimary) {
      return false;
    }

    // Clean up merged mode state
    _tabChannelProfiles.remove(_tabs[index].channelId);
    // Clear stale snapshot that may reference this tab's disposed ChatStore
    _mergedSnapshot = null;

    // Dispose the ChatStore before removing (if activated)
    _tabs[index].chatStore?.dispose();

    // Remove the tab
    _tabs.removeAt(index);

    _syncLiveStatusTimer();

    // Disable merged mode if only 1 tab remains
    if (_tabs.length <= 1 && mergedMode) {
      mergedMode = false;
      _mergedRenderTimer?.cancel();
      _mergedRenderTimer = null;
      _mergedRenderedMessages = [];
    }

    // Adjust active index if necessary
    if (activeTabIndex >= _tabs.length) {
      activeTabIndex = _tabs.length - 1;
    } else if (activeTabIndex > index) {
      activeTabIndex--;
    }

    // Ensure the new active tab is activated (in case it was lazy)
    activateTab(activeTabIndex);

    // Sync to settings for persistence
    _syncSecondaryTabsToSettings();

    return true;
  }

  /// Reorders a tab from oldIndex to newIndex.
  /// The primary tab (index 0) cannot be moved, and no tab can be placed before it.
  @action
  void reorderTab(int oldIndex, int newIndex) {
    // Primary tab (index 0) cannot be moved, and nothing can move before it
    if (oldIndex == 0 || newIndex == 0) return;

    // onReorderItem already adjusts newIndex for the removed item, so no
    // manual off-by-one correction is needed here.
    if (oldIndex == newIndex) return;

    final tab = _tabs.removeAt(oldIndex);
    _tabs.insert(newIndex, tab);

    // Adjust activeTabIndex to follow the active tab
    if (activeTabIndex == oldIndex) {
      activeTabIndex = newIndex;
    } else if (oldIndex < activeTabIndex && newIndex >= activeTabIndex) {
      activeTabIndex -= 1;
    } else if (oldIndex > activeTabIndex && newIndex <= activeTabIndex) {
      activeTabIndex += 1;
    }

    _syncSecondaryTabsToSettings();
  }

  /// Returns the last message id in [messages] that has a non-null tag id,
  /// or null if no such message exists. Skips system messages without ids.
  String? _latestMessageId(List<IRCMessage> messages) {
    for (var i = messages.length - 1; i >= 0; i--) {
      final id = messages[i].tags['id'];
      if (id != null) return id;
    }
    return null;
  }

  /// True if [index] has unread messages since the user last viewed it.
  /// Always false for the active tab and in merged mode.
  bool hasUnreadMessages(int index) {
    if (mergedMode) return false;
    if (index == activeTabIndex) return false;
    if (index < 0 || index >= _tabs.length) return false;
    final tab = _tabs[index];
    final store = tab.chatStore;
    if (store == null) return false;
    final latest = _latestMessageId(store.messages);
    if (latest == null) return false;
    return latest != tab.lastSeenMessageId;
  }

  /// Sets the active tab to the given index.
  ///
  /// When [silent] is true, the current tab's draft text and reply state are
  /// preserved. Used for programmatic switches (e.g., reply/paste routing in
  /// merged mode) where wiping the draft would lose user work.
  @action
  void setActiveTab(int index, {bool silent = false}) {
    if (index >= 0 && index < _tabs.length) {
      // Snapshot the outgoing tab's most recent message id so the unread
      // dot for that tab clears, and only future messages count as unread.
      if (index != activeTabIndex &&
          activeTabIndex >= 0 &&
          activeTabIndex < _tabs.length) {
        final outgoing = _tabs[activeTabIndex];
        final outStore = outgoing.chatStore;
        if (outStore != null) {
          outgoing.lastSeenMessageId = _latestMessageId(outStore.messages);
        }
      }

      // Clear text input and emote menu when switching tabs.
      // Skip in merged mode — tabs act as send-target selectors, not
      // view switches, so draft/reply state should be preserved.
      if (index != activeTabIndex && !silent && !mergedMode) {
        final currentStore = _tabs[activeTabIndex].chatStore;
        if (currentStore != null) {
          // Close emote menu if open
          currentStore.assetsStore.showEmoteMenu = false;
          // Unfocus input
          currentStore.unfocusInput();
          // Clear text input
          currentStore.textController.clear();
          // Clear reply state
          currentStore.replyingToMessage = null;
        }
      }

      // Activate the target tab if not already activated
      activateTab(index);

      if (mergedMode) {
        _fetchTabChannelProfile(_tabs[index]);
      }

      activeTabIndex = index;
    }
  }

  /// Refreshes the live-status map for all current tabs in one bulk fetch.
  /// Channels not in the response are treated as offline (removed from map).
  @action
  Future<void> _refreshLiveStatuses() async {
    final ids = _tabs.map((t) => t.channelId).toList(growable: false);
    if (ids.isEmpty) return;
    try {
      final result = await twitchApi.getStreamsByIds(userIds: ids);
      final next = <String, StreamTwitch>{
        for (final s in result.data) s.userId: s,
      };
      _liveStreams
        ..clear()
        ..addAll(next);
      _liveStatusFetched = true;
    } catch (e) {
      // Transient errors: keep existing state, don't flicker. Log only.
      debugPrint('Failed to refresh tab live statuses: $e');
    }
  }

  /// Starts the live-status timer (and an immediate fetch) when there are
  /// multiple tabs, stops it when down to one. The data only feeds the tab
  /// chip + popover, so polling at one tab is pure radio wake. Always
  /// refreshes when multi-tab so add/remove drops stale entries.
  void _syncLiveStatusTimer() {
    if (_tabs.length > 1) {
      _refreshLiveStatuses();
      _liveStatusTimer ??= Timer.periodic(
        _liveStatusPeriod,
        (_) => _refreshLiveStatuses(),
      );
    } else {
      _liveStatusTimer?.cancel();
      _liveStatusTimer = null;
      _liveStreams.clear();
      _liveStatusFetched = false;
    }
  }

  /// Disposes all ChatStores and cleans up resources.
  void dispose() {
    _mergedRenderTimer?.cancel();
    _mergedRenderTimer = null;
    _liveStatusTimer?.cancel();
    _liveStatusTimer = null;
    for (final tab in _tabs) {
      tab.chatStore?.dispose();
    }
    _tabs.clear();
    mergedScrollController.dispose();

    // Disable wakelock once after all tabs disposed
    WakelockPlus.disable();
  }
}
