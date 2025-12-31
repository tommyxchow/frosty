import 'package:frosty/apis/bttv_api.dart';
import 'package:frosty/apis/ffz_api.dart';
import 'package:frosty/apis/seventv_api.dart';
import 'package:frosty/apis/twitch_api.dart';
import 'package:frosty/screens/channel/chat/details/chat_details_store.dart';
import 'package:frosty/screens/channel/chat/stores/chat_assets_store.dart';
import 'package:frosty/screens/channel/chat/stores/chat_store.dart';
import 'package:frosty/screens/settings/stores/auth_store.dart';
import 'package:frosty/screens/settings/stores/settings_store.dart';
import 'package:mobx/mobx.dart';

part 'chat_tabs_store.g.dart';

/// Data class holding information about a chat tab.
class ChatTabInfo {
  final String channelId;
  final String channelLogin;
  final String displayName;
  final ChatStore chatStore;

  /// Whether this is the primary tab (first tab, cannot be removed).
  final bool isPrimary;

  const ChatTabInfo({
    required this.channelId,
    required this.channelLogin,
    required this.displayName,
    required this.chatStore,
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
  @computed
  ChatStore get activeChatStore => _tabs[activeTabIndex].chatStore;

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
    required String primaryChannelId,
    required String primaryChannelLogin,
    required String primaryDisplayName,
  }) {
    // Initialize with the primary channel tab
    _addPrimaryTab(
      channelId: primaryChannelId,
      channelLogin: primaryChannelLogin,
      displayName: primaryDisplayName,
    );
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
      ),
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
      activeTabIndex = existingIndex;
      return false;
    }

    // Create and add the new tab
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
        isPrimary: false,
      ),
    );

    // Switch to the new tab
    activeTabIndex = _tabs.length - 1;
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

    // Dispose the ChatStore before removing
    _tabs[index].chatStore.dispose();

    // Remove the tab
    _tabs.removeAt(index);

    // Adjust active index if necessary
    if (activeTabIndex >= _tabs.length) {
      activeTabIndex = _tabs.length - 1;
    } else if (activeTabIndex > index) {
      activeTabIndex--;
    }

    return true;
  }

  /// Sets the active tab to the given index.
  @action
  void setActiveTab(int index) {
    if (index >= 0 && index < _tabs.length) {
      // Clear text input and emote menu when switching tabs
      if (index != activeTabIndex) {
        // Close emote menu if open
        _tabs[activeTabIndex].chatStore.assetsStore.showEmoteMenu = false;
        // Unfocus input
        _tabs[activeTabIndex].chatStore.unfocusInput();
        // Clear text input
        _tabs[activeTabIndex].chatStore.textController.clear();
        // Clear reply state
        _tabs[activeTabIndex].chatStore.replyingToMessage = null;
      }
      activeTabIndex = index;
    }
  }

  /// Disposes all ChatStores and cleans up resources.
  void dispose() {
    for (final tab in _tabs) {
      tab.chatStore.dispose();
    }
    _tabs.clear();
  }
}
