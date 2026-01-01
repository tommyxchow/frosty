import 'package:frosty/apis/bttv_api.dart';
import 'package:frosty/apis/ffz_api.dart';
import 'package:frosty/apis/seventv_api.dart';
import 'package:frosty/apis/twitch_api.dart';
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
  factory PersistedChatTab.fromChatTabInfo(ChatTabInfo info) => PersistedChatTab(
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

/// Store that manages multiple chat tabs.
class ChatTabsStore = ChatTabsStoreBase with _$ChatTabsStore;

abstract class ChatTabsStoreBase with Store {
  /// Maximum number of tabs allowed.
  static const maxTabs = 10;

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

  /// Public getter for the tabs list.
  List<ChatTabInfo> get tabs => _tabs;

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
    WakelockPlus.enable();

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
    final existingIndex = _tabs.indexWhere(
      (tab) => tab.channelId == channelId,
    );
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

    // Sync to settings for persistence
    _syncSecondaryTabsToSettings();

    return true;
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

    // Dispose the ChatStore before removing (if activated)
    _tabs[index].chatStore?.dispose();

    // Remove the tab
    _tabs.removeAt(index);

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

    // ReorderableListView passes newIndex as if item was already removed
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
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

  /// Sets the active tab to the given index.
  @action
  void setActiveTab(int index) {
    if (index >= 0 && index < _tabs.length) {
      // Clear text input and emote menu when switching tabs
      if (index != activeTabIndex) {
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

      activeTabIndex = index;
    }
  }

  /// Disposes all ChatStores and cleans up resources.
  void dispose() {
    for (final tab in _tabs) {
      tab.chatStore?.dispose();
    }
    _tabs.clear();

    // Disable wakelock once after all tabs disposed
    WakelockPlus.disable();
  }
}
