import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/screens/channel/chat/chat.dart';
import 'package:frosty/screens/channel/chat/stores/chat_tabs_store.dart';
import 'package:frosty/screens/channel/chat/widgets/add_chat_dialog.dart';
import 'package:frosty/utils.dart';

/// Widget that displays multiple chat tabs with a tab bar.
/// Wraps the existing Chat widget and manages tab switching.
class ChatTabs extends StatelessWidget {
  final ChatTabsStore chatTabsStore;
  final EdgeInsetsGeometry? listPadding;

  const ChatTabs({super.key, required this.chatTabsStore, this.listPadding});

  Future<void> _handleAddChat(BuildContext context) async {
    if (!chatTabsStore.canAddTab) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Maximum 10 chats open'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final result = await AddChatSheet.show(context, chatTabsStore.twitchApi);

    if (result != null) {
      final added = chatTabsStore.addTab(
        channelId: result.channelId,
        channelLogin: result.channelLogin,
        displayName: result.displayName,
      );

      if (!added && context.mounted) {
        // If not added, it means the channel already exists (switched to it)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Channel already open, switched to it'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) {
        final tabs = chatTabsStore.tabs;
        final activeIndex = chatTabsStore.activeTabIndex;
        final showTabBar = chatTabsStore.showTabBar;

        // Calculate extra top padding for tab bar when visible
        final tabBarHeight = showTabBar ? 48.0 : 0.0;

        // Get the top inset from listPadding (e.g., for AppBar in chat-only mode)
        final topInset = listPadding?.resolve(TextDirection.ltr).top ?? 0;

        // Adjust list padding to account for tab bar
        final adjustedPadding = listPadding != null
            ? listPadding!.add(EdgeInsets.only(top: tabBarHeight))
            : EdgeInsets.only(top: tabBarHeight);

        return PopScope(
          canPop: Platform.isIOS,
          onPopInvokedWithResult: (didPop, _) {
            if (didPop) return;

            // If pressing the back button on Android while the emote menu
            // is open, close it instead of going back to the streams list.
            final activeStore = chatTabsStore.activeChatStore;
            if (activeStore.assetsStore.showEmoteMenu) {
              activeStore.assetsStore.showEmoteMenu = false;
            } else {
              Navigator.of(context).pop();
            }
          },
          child: Stack(
            children: [
              // Chat content with IndexedStack to preserve state
              Positioned.fill(
                child: IndexedStack(
                  index: activeIndex,
                  children: tabs.map((tabInfo) {
                    // Show placeholder for non-activated tabs
                    if (tabInfo.chatStore == null) {
                      return const SizedBox.shrink();
                    }
                    return Chat(
                      key: ValueKey(tabInfo.channelId),
                      chatStore: tabInfo.chatStore!,
                      listPadding: adjustedPadding,
                      onAddChat: () => _handleAddChat(context),
                    );
                  }).toList(),
                ),
              ),
              // Tab bar (only visible when more than 1 tab)
              if (showTabBar)
                Positioned(
                  top: topInset,
                  left: 0,
                  right: 0,
                  child: SizedBox(
                    height: 48,
                    child: Row(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: tabs.length,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 6,
                            ),
                            itemBuilder: (context, index) {
                              return _buildTab(context, index);
                            },
                          ),
                        ),
                        if (chatTabsStore.canAddTab)
                          IconButton(
                            icon: const Icon(Icons.add),
                            tooltip: 'Add chat',
                            onPressed: () => _handleAddChat(context),
                          ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _confirmRemoveTab(
    BuildContext context,
    int index,
    String displayName,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Remove $displayName?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      HapticFeedback.lightImpact();
      chatTabsStore.removeTab(index);
    }
  }

  Widget _buildTab(BuildContext context, int index) {
    final tabInfo = chatTabsStore.tabs[index];
    final isActive = index == chatTabsStore.activeTabIndex;
    final isActivated = tabInfo.isActivated;
    final displayName = getReadableName(
      tabInfo.displayName,
      tabInfo.channelLogin,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: InputChip(
        label: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 100),
          child: Text(
            displayName,
            overflow: TextOverflow.ellipsis,
            style: isActivated
                ? null
                : TextStyle(
                    color: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.color
                        ?.withValues(alpha: 0.5),
                  ),
          ),
        ),
        selected: isActive,
        showCheckmark: false,
        visualDensity: VisualDensity.compact,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        onPressed: () {
          if (!isActive) {
            HapticFeedback.selectionClick();
            chatTabsStore.setActiveTab(index);
          }
        },
        onDeleted: tabInfo.isPrimary
            ? null
            : () => _confirmRemoveTab(context, index, displayName),
        deleteButtonTooltipMessage: 'Close chat',
      ),
    );
  }
}
