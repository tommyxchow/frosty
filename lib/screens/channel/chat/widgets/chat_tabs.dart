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
        final showMerge = tabs.where((t) => t.isActivated).length >= 2;

        final tabBarHeight = showTabBar ? 48.0 : 0.0;
        final topInset = listPadding?.resolve(TextDirection.ltr).top ?? 0;
        final adjustedPadding = listPadding != null
            ? listPadding!.add(EdgeInsets.only(top: tabBarHeight))
            : EdgeInsets.only(top: tabBarHeight);

        return PopScope(
          canPop: Platform.isIOS,
          onPopInvokedWithResult: (didPop, _) {
            if (didPop) return;

            // Android back gesture: dismiss overlays before navigating away.
            final activeStore = chatTabsStore.activeChatStore;
            if (activeStore.assetsStore.showEmoteMenu) {
              activeStore.assetsStore.showEmoteMenu = false;
              return;
            }
            if (activeStore.textFieldFocusNode.hasFocus) {
              activeStore.unfocusInput();
              return;
            }
            Navigator.of(context).pop();
          },
          child: Stack(
            children: [
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
              if (showTabBar)
                Positioned(
                  top: topInset,
                  left: 0,
                  right: 0,
                  child: SizedBox(
                    height: 48,
                    child: Stack(
                      children: [
                        // Right-clip past the merge button so chips slide
                        // under its left half then disappear.
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
    final settings = chatTabsStore.activeChatStore.settings;

    return _AnchoredPopupMenu(
      itemsBuilder: (close) => [
        Observer(
          builder: (_) => CheckboxMenuButton(
            value: chatTabsStore.mergedMode,
            onChanged: (_) {
              HapticFeedback.selectionClick();
              chatTabsStore.toggleMergedMode();
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
      anchorBuilder: (context, toggle) {
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
            toggle();
          },
        );
      },
    );
  }

  Widget _buildTab(BuildContext context, int index) {
    final tabInfo = chatTabsStore.tabs[index];
    final isActive = index == chatTabsStore.activeTabIndex;
    final isSecondary = !tabInfo.isPrimary;
    final displayName = getReadableName(
      tabInfo.displayName,
      tabInfo.channelLogin,
    );

    return Observer(
      builder: (context) {
        final theme = Theme.of(context);
        final isActivated = tabInfo.isActivated;
        final hasUnread = chatTabsStore.hasUnreadMessages(index);
        final dimmed = !isActivated || !(tabInfo.chatStore?.isConnected ?? false);

        InputChip buildChip({VoidCallback? onDeleted}) => InputChip(
              avatar: Badge(
                smallSize: 8,
                backgroundColor: theme.colorScheme.primary,
                isLabelVisible: hasUnread,
                child: Opacity(
                  opacity: dimmed ? 0.5 : 1.0,
                  child: ProfilePicture(
                    userLogin: tabInfo.channelLogin,
                    radius: 12,
                  ),
                ),
              ),
              label: Text(
                displayName,
                style: dimmed
                    ? TextStyle(
                        color: theme.textTheme.bodyMedium?.color
                            ?.withValues(alpha: 0.5),
                      )
                    : null,
              ),
              selected: isActive,
              showCheckmark: false,
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              onPressed: () {
                if (isActive) return;
                HapticFeedback.selectionClick();
                chatTabsStore.setActiveTab(index);
              },
              onDeleted: onDeleted,
              deleteButtonTooltipMessage:
                  onDeleted != null ? 'Tab options' : null,
            );

        if (!isSecondary) return buildChip();

        return _AnchoredPopupMenu(
          itemsBuilder: (close) => [
            if (isActivated)
              MenuItemButton(
                leadingIcon: const Icon(Icons.power_off_rounded, size: 18),
                child: const Text('Disconnect'),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  close();
                  chatTabsStore.deactivateTab(index);
                },
              ),
            MenuItemButton(
              leadingIcon: Icon(
                Icons.delete_outline_rounded,
                size: 18,
                color: theme.colorScheme.error,
              ),
              child: Text(
                'Remove',
                style: TextStyle(color: theme.colorScheme.error),
              ),
              onPressed: () {
                HapticFeedback.lightImpact();
                close();
                chatTabsStore.removeTab(index);
              },
            ),
          ],
          anchorBuilder: (context, toggle) =>
              buildChip(onDeleted: toggle),
        );
      },
    );
  }
}

/// Lightweight popup menu anchored to a child widget. The menu's top-right
/// aligns to the anchor's bottom-right via [CompositedTransformFollower] and
/// fades + scales in from that corner. [MenuAnchor] doesn't expose an entry
/// animation hook in this Flutter version, so we drive one ourselves.
class _AnchoredPopupMenu extends StatefulWidget {
  final Widget Function(BuildContext context, VoidCallback toggle)
      anchorBuilder;
  final List<Widget> Function(VoidCallback close) itemsBuilder;

  const _AnchoredPopupMenu({
    required this.anchorBuilder,
    required this.itemsBuilder,
  });

  @override
  State<_AnchoredPopupMenu> createState() => _AnchoredPopupMenuState();
}

class _AnchoredPopupMenuState extends State<_AnchoredPopupMenu>
    with SingleTickerProviderStateMixin {
  final _link = LayerLink();
  final _portalCtrl = OverlayPortalController();
  late final _anim = AnimationController(
    duration: const Duration(milliseconds: 150),
    reverseDuration: const Duration(milliseconds: 100),
    vsync: this,
  )..addStatusListener((status) {
      if (status == AnimationStatus.dismissed && _portalCtrl.isShowing) {
        _portalCtrl.hide();
      }
    });
  late final _curve =
      CurvedAnimation(parent: _anim, curve: Curves.easeOut);
  late final _scale = Tween<double>(begin: 0.92, end: 1.0).animate(_curve);

  @override
  void dispose() {
    _curve.dispose();
    _anim.dispose();
    super.dispose();
  }

  void _toggle() {
    if (_portalCtrl.isShowing) {
      _anim.reverse();
    } else {
      _portalCtrl.show();
      _anim.forward();
    }
  }

  void _close() {
    if (_portalCtrl.isShowing) _anim.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _link,
      child: OverlayPortal(
        controller: _portalCtrl,
        overlayChildBuilder: (overlayContext) {
          final theme = Theme.of(overlayContext);
          return Stack(
            children: [
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _close,
                ),
              ),
              CompositedTransformFollower(
                link: _link,
                targetAnchor: Alignment.bottomRight,
                followerAnchor: Alignment.topRight,
                offset: const Offset(0, 4),
                showWhenUnlinked: false,
                child: FadeTransition(
                  opacity: _anim,
                  child: ScaleTransition(
                    scale: _scale,
                    alignment: Alignment.topRight,
                    child: Material(
                      color: theme.colorScheme.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: const BorderRadius.all(
                          Radius.circular(12),
                        ),
                        side: BorderSide(
                          color: theme.colorScheme.outlineVariant
                              .withValues(alpha: 0.5),
                          width: 0.5,
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: IntrinsicWidth(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: widget.itemsBuilder(_close),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
        child: widget.anchorBuilder(context, _toggle),
      ),
    );
  }
}
