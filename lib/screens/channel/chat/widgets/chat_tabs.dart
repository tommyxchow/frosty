import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/screens/channel/chat/chat.dart';
import 'package:frosty/screens/channel/chat/stores/chat_tabs_store.dart';
import 'package:frosty/screens/channel/chat/widgets/add_chat_dialog.dart';
import 'package:frosty/utils.dart';
import 'package:frosty/widgets/profile_picture.dart';

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
        final showMerge =
            tabs.where((t) => t.isActivated).length >= 2;

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

            // On Android back gesture, close overlays first before navigating back
            final activeStore = chatTabsStore.activeChatStore;

            // Priority 1: Close emote menu
            if (activeStore.assetsStore.showEmoteMenu) {
              activeStore.assetsStore.showEmoteMenu = false;
              return;
            }

            // Priority 2: Unfocus keyboard
            if (activeStore.textFieldFocusNode.hasFocus) {
              activeStore.unfocusInput();
              return;
            }

            // Priority 3: Navigate back
            Navigator.of(context).pop();
          },
          child: Stack(
            children: [
              // Chat content: merged view or IndexedStack
              Positioned.fill(
                child: chatTabsStore.mergedMode
                    ? Chat(
                        chatStore: chatTabsStore.activeChatStore,
                        chatTabsStore: chatTabsStore,
                        listPadding: adjustedPadding,
                        onAddChat: () => _handleAddChat(context),
                      )
                    : IndexedStack(
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
                    child: Stack(
                      children: [
                        // When merge button is visible, clips at its center
                        // so chips slide under its left half then disappear.
                        Positioned(
                          left: 0,
                          top: 0,
                          bottom: 0,
                          right: showMerge ? 33 : 0,
                          child: ReorderableListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: tabs.length,
                            padding: EdgeInsets.only(
                              left: 12,
                              right: showMerge ? 32 : 12,
                            ),
                            onReorderItem: (oldIndex, newIndex) {
                              HapticFeedback.lightImpact();
                              chatTabsStore.reorderTab(oldIndex, newIndex);
                            },
                            proxyDecorator: (child, index, animation) {
                              return Material(
                                color: Colors.transparent,
                                child: child,
                              );
                            },
                            itemBuilder: (context, index) {
                              final tabInfo = chatTabsStore.tabs[index];
                              return Padding(
                                key: ValueKey(tabInfo.channelId),
                                padding: EdgeInsets.only(
                                  right: index < tabs.length - 1 ? 4 : 0,
                                ),
                                child: _buildTab(context, index),
                              );
                            },
                          ),
                        ),
                        if (showMerge)
                          Positioned(
                            right: 12,
                            top: 0,
                            bottom: 0,
                            child: Center(child: _buildMergeToggle(context)),
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

  Widget _buildMergeToggle(BuildContext context) {
    final isMerged = chatTabsStore.mergedMode;
    return IconButton.filledTonal(
      icon: const Icon(Icons.call_merge, size: 18),
      tooltip: isMerged ? 'Split chats' : 'Merge loaded chats',
      visualDensity: VisualDensity.compact,
      isSelected: isMerged,
      style: IconButton.styleFrom(
        minimumSize: const Size(42, 42),
        backgroundColor: isMerged
            ? null
            : Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      onPressed: () {
        HapticFeedback.selectionClick();
        chatTabsStore.toggleMergedMode();
      },
    );
  }

  Widget _buildTab(BuildContext context, int index) {
    final tabInfo = chatTabsStore.tabs[index];
    final isActive = index == chatTabsStore.activeTabIndex;
    final isActivated = tabInfo.isActivated;
    final displayName = getReadableName(
      tabInfo.displayName,
      tabInfo.channelLogin,
    );

    final avatar = ProfilePicture(userLogin: tabInfo.channelLogin, radius: 12);

    if (tabInfo.isPrimary) {
      return InputChip(
        avatar: avatar,
        label: Text(displayName),
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
      );
    }

    return MenuAnchor(
      menuChildren: [
        if (isActivated)
          MenuItemButton(
            leadingIcon: const Icon(Icons.power_off_rounded, size: 18),
            child: const Text('Disconnect'),
            onPressed: () {
              HapticFeedback.lightImpact();
              chatTabsStore.deactivateTab(index);
            },
          ),
        MenuItemButton(
          leadingIcon: Icon(
            Icons.delete_outline_rounded,
            size: 18,
            color: Theme.of(context).colorScheme.error,
          ),
          child: Text(
            'Remove',
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
          onPressed: () {
            HapticFeedback.lightImpact();
            chatTabsStore.removeTab(index);
          },
        ),
      ],
      builder: (context, controller, child) {
        return InputChip(
          avatar:
              isActivated ? avatar : Opacity(opacity: 0.5, child: avatar),
          label: Text(
            displayName,
            style: isActivated
                ? null
                : TextStyle(
                    color: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
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
          onDeleted: () => controller.open(),
          deleteButtonTooltipMessage: 'Tab options',
        );
      },
    );
  }
}
