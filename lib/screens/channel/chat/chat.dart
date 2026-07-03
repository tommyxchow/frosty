import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/models/irc.dart';
import 'package:frosty/models/user.dart';
import 'package:frosty/screens/channel/chat/emote_menu/emote_menu_panel.dart';
import 'package:frosty/screens/channel/chat/emote_menu/recent_emotes_panel.dart';
import 'package:frosty/screens/channel/chat/stores/chat_store.dart';
import 'package:frosty/screens/channel/chat/stores/chat_tabs_store.dart';
import 'package:frosty/screens/channel/chat/widgets/chat_bottom_bar.dart';
import 'package:frosty/screens/channel/chat/widgets/chat_message.dart';
import 'package:frosty/utils.dart';
import 'package:frosty/utils/context_extensions.dart';
import 'package:frosty/widgets/frosty_page_view.dart';
import 'package:frosty/widgets/frosty_scrollbar.dart';

/// ~2x default to keep richer message widgets (emotes, badges, replies) built
/// ahead of fast scroll-back without holding the entire history.
const _chatCacheExtent = ScrollCacheExtent.pixels(500.0);

/// Cached [ChatMessage] instances keyed by message identity. Returning the
/// identical widget instance across list rebuilds lets the framework skip the
/// row's build entirely (`Element.updateChild` short-circuits on identical
/// widgets), so a batch flush only builds the genuinely new messages instead
/// of regenerating every visible row's spans. Entries are GC'd together with
/// their messages; [IRCMessage.renderRevision] invalidates rows the moderation
/// handlers mutate in place. MobX reactivity is unaffected — each row's
/// Observer subscription lives on its element, not its widget instance.
final _messageWidgetCache = Expando<_CachedMessageWidget>();

/// Merged-mode cache, kept separate because merged rows carry per-active-tab
/// parameters that must invalidate the cached widget when they change.
final _mergedMessageWidgetCache = Expando<_CachedMessageWidget>();

class _CachedMessageWidget {
  const _CachedMessageWidget(this.widget, this.revision);

  final ChatMessage widget;
  final int revision;
}

class Chat extends StatelessWidget {
  final ChatStore chatStore;
  final EdgeInsetsGeometry? listPadding;

  /// Callback to add a new chat tab.
  /// Passes this to ChatBottomBar for the ChatDetails menu.
  final VoidCallback onAddChat;

  /// When set, the widget operates in merged mode: messages come from all tabs
  /// and the active tab determines the send target.
  final ChatTabsStore? chatTabsStore;

  const Chat({
    super.key,
    required this.chatStore,
    this.listPadding,
    required this.onAddChat,
    this.chatTabsStore,
  });

  bool get _isMerged => chatTabsStore != null;

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) {
        return Column(
          children: [
            Expanded(
              child: Stack(
                alignment: AlignmentDirectional.bottomCenter,
                children: [
                  // Wrap only the message list with GestureDetector
                  // so taps on ChatBottomBar don't trigger unfocus
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      if (chatStore.assetsStore.showEmoteMenu) {
                        chatStore.assetsStore.showEmoteMenu = false;
                      } else if (chatStore.textFieldFocusNode.hasFocus) {
                        chatStore.unfocusInput();
                      }
                    },
                    child: MediaQuery(
                      data: MediaQuery.of(context).copyWith(
                        textScaler: chatStore.settings.messageScale.textScaler,
                      ),
                      child: DefaultTextStyle(
                        style: context.defaultTextStyle.copyWith(
                          fontSize: chatStore.settings.fontSize,
                        ),
                        child: Builder(
                          builder: (context) {
                            // Don't add bottom padding in horizontal landscape
                            // (immersive mode with home indicator on side).
                            // landscapeForceVerticalChat uses portrait layout
                            // with normal system UI, so still needs padding.
                            final isHorizontalLandscape =
                                context.isLandscape &&
                                !chatStore.settings.landscapeForceVerticalChat;
                            final bottomPadding =
                                chatStore.assetsStore.showEmoteMenu ||
                                    isHorizontalLandscape
                                ? 0.0
                                : MediaQuery.of(context).padding.bottom;

                            final scrollController = _isMerged
                                ? chatTabsStore!.mergedScrollController
                                : chatStore.scrollController;

                            // Freeze the message list while a finger rests on a
                            // message so a long-press target can't scroll out
                            // from under it (which would dispose its recognizer
                            // mid-press). The store resumes flowing as soon as
                            // the pointer moves like a scroll, so scrolling is
                            // never interrupted — only a stationary hold pauses.
                            void onDown(PointerDownEvent e) => _isMerged
                                ? chatTabsStore!.onMessageListPointerDown(
                                    e.pointer,
                                    e.position,
                                  )
                                : chatStore.onMessageListPointerDown(
                                    e.pointer,
                                    e.position,
                                  );
                            void onMove(PointerMoveEvent e) => _isMerged
                                ? chatTabsStore!.onMessageListPointerMove(
                                    e.pointer,
                                    e.position,
                                  )
                                : chatStore.onMessageListPointerMove(
                                    e.pointer,
                                    e.position,
                                  );
                            void onUp(int pointer) => _isMerged
                                ? chatTabsStore!.onMessageListPointerUp(pointer)
                                : chatStore.onMessageListPointerUp(pointer);

                            return Listener(
                              onPointerDown: onDown,
                              onPointerMove: onMove,
                              onPointerUp: (e) => onUp(e.pointer),
                              onPointerCancel: (e) => onUp(e.pointer),
                              child: FrostyScrollbar(
                                controller: scrollController,
                                padding: EdgeInsets.only(
                                  top: MediaQuery.of(context).padding.top,
                                  bottom:
                                      chatStore.bottomBarHeight + bottomPadding,
                                ),
                                child: Observer(
                                  builder: (context) {
                                    return _isMerged
                                        ? _buildMergedList(
                                            scrollController,
                                            bottomPadding,
                                          )
                                        : _buildNormalList(
                                            scrollController,
                                            bottomPadding,
                                          );
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: ChatBottomBar(
                      chatStore: chatStore,
                      onAddChat: onAddChat,
                      channelDisplayName: _isMerged
                          ? getReadableName(
                              chatTabsStore!.activeTab.displayName,
                              chatTabsStore!.activeTab.channelLogin,
                            )
                          : null,
                    ),
                  ),
                  _buildResumeScrollButton(),
                ],
              ),
            ),
            _buildEmoteMenu(context),
          ],
        );
      },
    );
  }

  Widget _buildNormalList(
    ScrollController scrollController,
    double bottomPadding,
  ) {
    final messages = chatStore.renderMessages;
    // Built lazily on the first keyed-child lookup of a rebuild.
    Map<IRCMessage, int>? sliverIndexByMessage;

    return ListView.builder(
      reverse: true,
      padding: (listPadding ?? EdgeInsets.zero).add(
        EdgeInsets.only(bottom: chatStore.bottomBarHeight + bottomPadding),
      ),
      addAutomaticKeepAlives: false,
      scrollCacheExtent: _chatCacheExtent,
      controller: scrollController,
      itemCount: messages.length,
      // Every appended batch shifts all sliver indices (the list is reversed,
      // so new messages land at index 0). Mapping a row's key back to its new
      // index here lets the framework *move* the existing element — without
      // it, the key mismatch at each shifted index would deactivate and
      // re-inflate every built row on every flush.
      findChildIndexCallback: (key) {
        final lookup = sliverIndexByMessage ??= {
          for (var i = 0; i < messages.length; i++)
            messages[messages.length - 1 - i]: i,
        };
        return lookup[(key as ObjectKey).value];
      },
      itemBuilder: (context, index) {
        final ircMessage = messages[messages.length - 1 - index];
        return _cachedChatMessage(ircMessage);
      },
    );
  }

  /// Returns the (cached) widget for [ircMessage], building it on first
  /// render. Keyed by message identity so the list reconciles by message
  /// rather than by slot — this keeps each message's element (and its gesture
  /// recognizers) bound to the same message when new messages arrive
  /// mid-interaction, fixing long-press landing on the wrong message.
  Widget _cachedChatMessage(IRCMessage ircMessage) {
    final cached = _messageWidgetCache[ircMessage];
    if (cached != null &&
        cached.revision == ircMessage.renderRevision &&
        identical(cached.widget.chatStore, chatStore)) {
      return cached.widget;
    }

    final widget = ChatMessage(
      key: ObjectKey(ircMessage),
      ircMessage: ircMessage,
      chatStore: chatStore,
    );
    _messageWidgetCache[ircMessage] = _CachedMessageWidget(
      widget,
      ircMessage.renderRevision,
    );
    return widget;
  }

  Widget _buildMergedList(
    ScrollController scrollController,
    double bottomPadding,
  ) {
    final mergedMessages = chatTabsStore!.mergedMessages;
    final channelIdToUserTwitch = chatTabsStore!.mergedChannelIdToUserTwitch;
    final currentChannelId = chatTabsStore!.activeTab.channelId;
    // Built lazily on the first keyed-child lookup of a rebuild.
    Map<IRCMessage, int>? sliverIndexByMessage;

    return ListView.builder(
      reverse: true,
      padding: (listPadding ?? EdgeInsets.zero).add(
        EdgeInsets.only(bottom: chatStore.bottomBarHeight + bottomPadding),
      ),
      addAutomaticKeepAlives: false,
      scrollCacheExtent: _chatCacheExtent,
      controller: scrollController,
      itemCount: mergedMessages.length,
      // See _buildNormalList — moves existing elements across index shifts.
      findChildIndexCallback: (key) {
        final lookup = sliverIndexByMessage ??= {
          for (var i = 0; i < mergedMessages.length; i++)
            mergedMessages[mergedMessages.length - 1 - i].ircMessage: i,
        };
        return lookup[(key as ObjectKey).value];
      },
      itemBuilder: (context, index) {
        final merged = mergedMessages[mergedMessages.length - 1 - index];
        return _cachedMergedChatMessage(
          merged,
          channelIdToUserTwitch,
          currentChannelId,
        );
      },
    );
  }

  /// Merged-mode variant of [_cachedChatMessage]. The extra identity checks
  /// invalidate the cached widget when the active tab (send target) or the
  /// combined channel-profile map changes.
  Widget _cachedMergedChatMessage(
    MergedMessage merged,
    Map<String, UserTwitch> channelIdToUserTwitch,
    String currentChannelId,
  ) {
    final ircMessage = merged.ircMessage;
    final cached = _mergedMessageWidgetCache[ircMessage];
    final cachedWidget = cached?.widget;
    if (cached != null &&
        cachedWidget != null &&
        cached.revision == ircMessage.renderRevision &&
        identical(cachedWidget.chatStore, merged.chatStore) &&
        identical(cachedWidget.inputChatStore, chatStore) &&
        identical(
          cachedWidget.overrideChannelIdToUserTwitch,
          channelIdToUserTwitch,
        ) &&
        cachedWidget.overrideCurrentChannelId == currentChannelId) {
      return cachedWidget;
    }

    final widget = ChatMessage(
      key: ObjectKey(ircMessage),
      ircMessage: ircMessage,
      chatStore: merged.chatStore,
      inputChatStore: chatStore,
      onActivateSourceTab: () {
        final tabs = chatTabsStore!.tabs;
        final idx = tabs.indexWhere(
          (t) => t.channelId == merged.chatStore.channelId,
        );
        if (idx != -1 && idx != chatTabsStore!.activeTabIndex) {
          chatTabsStore!.setActiveTab(idx, silent: true);
        }
      },
      overrideChannelIdToUserTwitch: channelIdToUserTwitch,
      overrideCurrentChannelId: currentChannelId,
    );
    _mergedMessageWidgetCache[ircMessage] = _CachedMessageWidget(
      widget,
      ircMessage.renderRevision,
    );
    return widget;
  }

  Widget _buildResumeScrollButton() {
    return Builder(
      builder: (context) {
        final isHorizontalLandscape =
            context.isLandscape &&
            !chatStore.settings.landscapeForceVerticalChat;
        return AnimatedPadding(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.only(
            left: 4,
            top: 4,
            right: 4,
            bottom:
                chatStore.bottomBarHeight +
                (chatStore.assetsStore.showEmoteMenu || isHorizontalLandscape
                    ? 0
                    : MediaQuery.of(context).padding.bottom),
          ),
          child: Observer(
            builder: (_) {
              final isAutoScrolling = _isMerged
                  ? chatTabsStore!.mergedAutoScroll
                  : chatStore.autoScroll;
              final bufferCount = _isMerged
                  ? chatTabsStore!.mergedBufferCount
                  : chatStore.messageBuffer.length;
              final onResume = _isMerged
                  ? chatTabsStore!.resumeMergedScroll
                  : chatStore.resumeScroll;

              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                child: isAutoScrolling
                    ? null
                    : ElevatedButton.icon(
                        onPressed: onResume,
                        icon: const Icon(Icons.arrow_downward_rounded),
                        label: Text(
                          bufferCount > 0
                              ? '$bufferCount new ${bufferCount == 1 ? 'message' : 'messages'}'
                              : 'Resume scroll',
                          style: const TextStyle(
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),
                      ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildEmoteMenu(BuildContext context) {
    final menuHeight = context.screenHeight / (context.isPortrait ? 3 : 2);
    return AnimatedContainer(
      curve: Curves.ease,
      duration: const Duration(milliseconds: 200),
      height: chatStore.assetsStore.showEmoteMenu ? menuHeight : 0,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 100),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        child: chatStore.assetsStore.showEmoteMenu
            ? ClipRect(
                // Lay the content out at its full target height regardless of
                // the animated container's current height, then clip — the
                // Column would otherwise overflow (RenderFlex error) as the
                // height tweens toward zero and can no longer fit the Divider.
                child: OverflowBox(
                  minHeight: 0,
                  maxHeight: menuHeight,
                  alignment: Alignment.topCenter,
                  child: Column(
                    children: [
                      const Divider(),
                      Expanded(
                        child: FrostyPageView(
                          headers: [
                            'Recent',
                            if (chatStore.settings.showTwitchEmotes) 'Twitch',
                            if (chatStore.settings.show7TVEmotes) '7TV',
                            if (chatStore.settings.showBTTVEmotes) 'BTTV',
                            if (chatStore.settings.showFFZEmotes) 'FFZ',
                          ],
                          tabActions: {
                            if (chatStore.assetsStore.recentEmotes.isNotEmpty)
                              0: IconButton(
                                onPressed: () {
                                  chatStore.assetsStore.recentEmotes.clear();
                                  chatStore.updateNotification(
                                    'Recent emotes cleared',
                                  );
                                },
                                icon: const Icon(Icons.delete_outline_rounded),
                                tooltip: 'Clear recent emotes',
                                iconSize: 20,
                              ),
                          },
                          children: [
                            RecentEmotesPanel(chatStore: chatStore),
                            if (chatStore.settings.showTwitchEmotes)
                              EmoteMenuPanel(
                                chatStore: chatStore,
                                twitchEmotes: chatStore
                                    .assetsStore
                                    .userEmoteSectionToEmotes,
                              ),
                            ...[
                              if (chatStore.settings.show7TVEmotes)
                                chatStore.assetsStore.sevenTVEmotes,
                              if (chatStore.settings.showBTTVEmotes)
                                chatStore.assetsStore.bttvEmotes,
                              if (chatStore.settings.showFFZEmotes)
                                chatStore.assetsStore.ffzEmotes,
                            ].map(
                              (emotes) => EmoteMenuPanel(
                                chatStore: chatStore,
                                emotes: emotes,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : null,
      ),
    );
  }
}
