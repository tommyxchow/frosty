import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
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
const _chatCacheExtent = 500.0;

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

                            return FrostyScrollbar(
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
    return ListView.builder(
      reverse: true,
      padding: (listPadding ?? EdgeInsets.zero).add(
        EdgeInsets.only(
          bottom: chatStore.bottomBarHeight + bottomPadding,
        ),
      ),
      addAutomaticKeepAlives: false,
      cacheExtent: _chatCacheExtent,
      controller: scrollController,
      itemCount: chatStore.renderMessages.length,
      itemBuilder: (context, index) => ChatMessage(
        ircMessage: chatStore.renderMessages[
            chatStore.renderMessages.length - 1 - index],
        chatStore: chatStore,
      ),
    );
  }

  Widget _buildMergedList(
    ScrollController scrollController,
    double bottomPadding,
  ) {
    final mergedMessages = chatTabsStore!.mergedMessages;
    final channelIdToUserTwitch =
        chatTabsStore!.mergedChannelIdToUserTwitch;
    final currentChannelId = chatTabsStore!.activeTab.channelId;

    return ListView.builder(
      reverse: true,
      padding: (listPadding ?? EdgeInsets.zero).add(
        EdgeInsets.only(
          bottom: chatStore.bottomBarHeight + bottomPadding,
        ),
      ),
      addAutomaticKeepAlives: false,
      cacheExtent: _chatCacheExtent,
      controller: scrollController,
      itemCount: mergedMessages.length,
      itemBuilder: (context, index) {
        final merged =
            mergedMessages[mergedMessages.length - 1 - index];
        return ChatMessage(
          ircMessage: merged.ircMessage,
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
      },
    );
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
                (chatStore.assetsStore.showEmoteMenu ||
                        isHorizontalLandscape
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
                        icon: const Icon(
                          Icons.arrow_downward_rounded,
                        ),
                        label: Text(
                          bufferCount > 0
                              ? '$bufferCount new ${bufferCount == 1 ? 'message' : 'messages'}'
                              : 'Resume scroll',
                          style: const TextStyle(
                            fontFeatures: [
                              FontFeature.tabularFigures(),
                            ],
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
    return AnimatedContainer(
      curve: Curves.ease,
      duration: const Duration(milliseconds: 200),
      height: chatStore.assetsStore.showEmoteMenu
          ? context.screenHeight / (context.isPortrait ? 3 : 2)
          : 0,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 100),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        child: chatStore.assetsStore.showEmoteMenu
            ? ClipRect(
                child: Column(
                  children: [
                    const Divider(),
                    Expanded(
                      child: FrostyPageView(
                        headers: [
                          'Recent',
                          if (chatStore.settings.showTwitchEmotes)
                            'Twitch',
                          if (chatStore.settings.show7TVEmotes) '7TV',
                          if (chatStore.settings.showBTTVEmotes) 'BTTV',
                          if (chatStore.settings.showFFZEmotes) 'FFZ',
                        ],
                        tabActions: {
                          if (chatStore
                              .assetsStore
                              .recentEmotes
                              .isNotEmpty)
                            0: IconButton(
                              onPressed: () {
                                chatStore.assetsStore.recentEmotes.clear();
                                chatStore.updateNotification(
                                  'Recent emotes cleared',
                                );
                              },
                              icon: const Icon(
                                Icons.delete_outline_rounded,
                              ),
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
              )
            : null,
      ),
    );
  }
}
