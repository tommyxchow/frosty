import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/models/stream.dart';
import 'package:frosty/screens/channel/chat/chat.dart';
import 'package:frosty/screens/channel/chat/stores/chat_tabs_store.dart';
import 'package:frosty/screens/channel/chat/widgets/add_chat_dialog.dart';
import 'package:frosty/utils.dart';
import 'package:frosty/widgets/frosty_cached_network_image.dart';
import 'package:frosty/widgets/profile_picture.dart';
import 'package:intl/intl.dart' show NumberFormat;

const _chipAnimationDuration = Duration(milliseconds: 200);
const _avatarRadius = 12.0;
const _activeChipRadius = 16.0;

/// Widget that displays multiple chat tabs with a tab bar.
/// Wraps the existing Chat widget and manages tab switching.
class ChatTabs extends StatefulWidget {
  final ChatTabsStore chatTabsStore;
  final EdgeInsetsGeometry? listPadding;

  const ChatTabs({super.key, required this.chatTabsStore, this.listPadding});

  @override
  State<ChatTabs> createState() => _ChatTabsState();
}

class _ChatTabsState extends State<ChatTabs> {
  bool _isReordering = false;

  ChatTabsStore get _store => widget.chatTabsStore;

  Future<void> _handleAddChat() async {
    if (!_store.canAddTab) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Maximum 10 chats open'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final result = await AddChatSheet.show(context, _store.twitchApi);

    if (result != null) {
      final added = _store.addTab(
        channelId: result.channelId,
        channelLogin: result.channelLogin,
        displayName: result.displayName,
      );

      if (!added && mounted) {
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
        final tabs = _store.tabs;
        final activeIndex = _store.activeTabIndex;
        final showTabBar = _store.showTabBar;
        final showMerge = tabs.where((t) => t.isActivated).length >= 2;

        // Calculate extra top padding for tab bar when visible
        final tabBarHeight = showTabBar ? 48.0 : 0.0;

        // Get the top inset from listPadding (e.g., for AppBar in chat-only mode)
        final topInset =
            widget.listPadding?.resolve(TextDirection.ltr).top ?? 0;

        // Adjust list padding to account for tab bar
        final adjustedPadding = widget.listPadding != null
            ? widget.listPadding!.add(EdgeInsets.only(top: tabBarHeight))
            : EdgeInsets.only(top: tabBarHeight);

        return PopScope(
          canPop: Platform.isIOS,
          onPopInvokedWithResult: (didPop, _) {
            if (didPop) return;

            // On Android back gesture, close overlays first before navigating back
            final activeStore = _store.activeChatStore;

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
                child: _store.mergedMode
                    ? Chat(
                        chatStore: _store.activeChatStore,
                        chatTabsStore: _store,
                        listPadding: adjustedPadding,
                        onAddChat: _handleAddChat,
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
                            onAddChat: _handleAddChat,
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
                            onReorderStart: (_) =>
                                setState(() => _isReordering = true),
                            onReorderEnd: (_) =>
                                setState(() => _isReordering = false),
                            onReorderItem: (oldIndex, newIndex) {
                              HapticFeedback.lightImpact();
                              _store.reorderTab(oldIndex, newIndex);
                            },
                            proxyDecorator: (child, index, animation) {
                              return Material(
                                color: Colors.transparent,
                                child: child,
                              );
                            },
                            itemBuilder: (context, index) {
                              final tabInfo = _store.tabs[index];
                              return Padding(
                                key: ValueKey(tabInfo.channelId),
                                padding: EdgeInsets.only(
                                  right: index < tabs.length - 1 ? 4 : 0,
                                ),
                                child: Center(child: _buildTab(context, index)),
                              );
                            },
                          ),
                        ),
                        if (showMerge)
                          Positioned(
                            right: 12,
                            top: 0,
                            bottom: 0,
                            child: Center(
                              child: _buildMoreActionsMenu(context),
                            ),
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

  Widget _buildMoreActionsMenu(BuildContext context) {
    final settings = _store.activeChatStore.settings;

    return MenuAnchor(
      menuChildren: [
        Observer(
          builder: (_) => CheckboxMenuButton(
            value: _store.mergedMode,
            onChanged: (_) {
              HapticFeedback.selectionClick();
              _store.toggleMergedMode();
            },
            child: const Text('Merge chats'),
          ),
        ),
        Observer(
          builder: (_) => CheckboxMenuButton(
            value: settings.focusCurrentChannel,
            onChanged: (newValue) {
              HapticFeedback.selectionClick();
              settings.focusCurrentChannel = newValue ?? false;
            },
            child: const Text('Focus current channel'),
          ),
        ),
      ],
      builder: (context, controller, child) {
        return IconButton.filledTonal(
          icon: const Icon(Icons.more_vert, size: 18),
          tooltip: 'Chat options',
          visualDensity: VisualDensity.compact,
          style: IconButton.styleFrom(
            minimumSize: const Size(42, 42),
            backgroundColor:
                Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
          onPressed: () {
            HapticFeedback.selectionClick();
            controller.isOpen ? controller.close() : controller.open();
          },
        );
      },
    );
  }

  Widget _buildTab(BuildContext context, int index) {
    final tabInfo = _store.tabs[index];
    final isActive = index == _store.activeTabIndex;
    final isSecondary = !tabInfo.isPrimary;
    final displayName = getReadableName(
      tabInfo.displayName,
      tabInfo.channelLogin,
    );

    return Observer(
      builder: (context) {
        final isActivated = tabInfo.isActivated;
        final isLive = _store.isTabLive(tabInfo.channelId);
        final hasUnread = _store.hasUnreadMessages(index);
        final streamInfo = _store.getStreamInfo(tabInfo.channelId);

        // Primary + offline → empty popover (no header value, no actions);
        // skip opening entirely.
        final canOpenPopover = isSecondary || isLive;

        return MenuAnchor(
          menuChildren: _buildPopoverChildren(
            context: context,
            index: index,
            isPrimary: tabInfo.isPrimary,
            isActivated: isActivated,
            isLive: isLive,
            displayName: displayName,
            streamInfo: streamInfo,
          ),
          builder: (context, controller, child) {
            void openPopover() {
              if (!canOpenPopover) return;
              HapticFeedback.lightImpact();
              controller.open();
            }

            return Semantics(
              button: true,
              selected: isActive,
              label: [
                displayName,
                if (!isLive) 'offline',
                if (hasUnread) 'unread messages',
                if (!isActivated) 'disconnected',
              ].join(', '),
              excludeSemantics: true,
              child: _ChipShell(
                isActive: isActive,
                animationDuration:
                    _isReordering ? Duration.zero : _chipAnimationDuration,
                onTap: () {
                  if (isActive) return;
                  HapticFeedback.selectionClick();
                  _store.setActiveTab(index);
                },
                onLongPress: openPopover,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Opacity(
                      opacity: isActivated ? 1.0 : 0.5,
                      child: Badge(
                        smallSize: 8,
                        backgroundColor:
                            Theme.of(context).colorScheme.primary,
                        isLabelVisible: hasUnread,
                        child: ProfilePicture(
                          userLogin: tabInfo.channelLogin,
                          radius: _avatarRadius,
                          isGrayscale: !isLive,
                        ),
                      ),
                    ),
                    if (isActive) ...[
                      const SizedBox(width: 6),
                      Text(
                        displayName,
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
                      if (isSecondary) ...[
                        const SizedBox(width: 4),
                        InkResponse(
                          radius: 14,
                          onTap: openPopover,
                          child: Icon(
                            Icons.close_rounded,
                            size: 16,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  List<Widget> _buildPopoverChildren({
    required BuildContext context,
    required int index,
    required bool isPrimary,
    required bool isActivated,
    required bool isLive,
    required String displayName,
    required StreamTwitch? streamInfo,
  }) {
    final isSecondary = !isPrimary;
    final hasActions = isSecondary;

    return [
      _PopoverHeader(
        displayName: displayName,
        streamInfo: isLive ? streamInfo : null,
      ),
      if (hasActions) const Divider(height: 1),
      if (isSecondary && isActivated)
        MenuItemButton(
          leadingIcon: const Icon(Icons.power_off_rounded, size: 18),
          child: const Text('Disconnect'),
          onPressed: () {
            HapticFeedback.lightImpact();
            _store.deactivateTab(index);
          },
        ),
      if (isSecondary)
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
            _store.removeTab(index);
          },
        ),
    ];
  }
}

/// Animated container shell for a chat tab chip — pill background when active,
/// transparent when not. Drives the avatar↔pill morph via [AnimatedSize].
class _ChipShell extends StatelessWidget {
  final bool isActive;
  final Duration animationDuration;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final Widget child;

  const _ChipShell({
    required this.isActive,
    required this.animationDuration,
    required this.onTap,
    required this.onLongPress,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: isActive ? theme.colorScheme.surfaceContainerHigh : Colors.transparent,
      borderRadius: BorderRadius.circular(_activeChipRadius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: BorderRadius.circular(_activeChipRadius),
        onTap: onTap,
        onLongPress: onLongPress,
        child: AnimatedSize(
          duration: animationDuration,
          curve: Curves.easeOut,
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isActive ? 8 : 4,
              vertical: 4,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Header widget for the long-press popover. Renders stream details when
/// [streamInfo] is non-null, otherwise an "Offline" label.
class _PopoverHeader extends StatelessWidget {
  final String displayName;
  final StreamTwitch? streamInfo;

  const _PopoverHeader({required this.displayName, this.streamInfo});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final info = streamInfo;

    if (info == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Text(
          'Offline',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    final headerName = getReadableName(info.userName, info.userLogin);
    final viewers = '${NumberFormat().format(info.viewerCount)} viewers';
    final title = info.title.trim();
    final game = info.gameName.trim();

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 280),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: FrostyCachedNetworkImage(
                  imageUrl: info.thumbnailUrl.replaceFirst(
                    '-{width}x{height}',
                    '-240x135',
                  ),
                  placeholder: (context, url) => ColoredBox(
                    color: theme.colorScheme.surfaceContainer,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$headerName  ·  $viewers',
              style: theme.textTheme.titleSmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (title.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                title,
                style: theme.textTheme.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (game.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                game,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
