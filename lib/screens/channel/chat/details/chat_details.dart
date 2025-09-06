import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/constants.dart';
import 'package:frosty/main.dart';
import 'package:frosty/models/irc.dart';
import 'package:frosty/screens/channel/chat/details/chat_details_store.dart';
import 'package:frosty/screens/channel/chat/details/chat_modes.dart';
import 'package:frosty/screens/channel/chat/details/chat_users_list.dart';
import 'package:frosty/screens/channel/chat/stores/chat_store.dart';
import 'package:frosty/screens/settings/settings.dart';
import 'package:frosty/utils.dart';
import 'package:frosty/utils/modal_bottom_sheet.dart';
import 'package:frosty/widgets/animated_scroll_border.dart';
import 'package:frosty/widgets/section_header.dart';
import 'package:intl/intl.dart';

class ChatDetails extends StatefulWidget {
  final ChatDetailsStore chatDetailsStore;
  final ChatStore chatStore;
  final String userLogin;

  const ChatDetails({
    super.key,
    required this.chatDetailsStore,
    required this.chatStore,
    required this.userLogin,
  });

  @override
  State<ChatDetails> createState() => _ChatDetailsState();
}

class _ChatDetailsState extends State<ChatDetails> {
  late final _scrollController = ScrollController();

  String formatDuration(Duration duration) {
    if (duration.inMinutes < 60) {
      return '${duration.inMinutes} ${Intl.plural(duration.inMinutes, one: 'minute', other: 'minutes')}';
    }

    return '${duration.inHours} ${Intl.plural(duration.inHours, one: 'hour', other: 'hours')}';
  }

  String formatTimeLeft(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  Future<void> _showSleepTimer(BuildContext context) {
    const durations = [
      Duration(minutes: 5),
      Duration(minutes: 10),
      Duration(minutes: 15),
      Duration(minutes: 30),
      Duration(hours: 1),
      Duration(hours: 2),
      Duration(hours: 3),
      Duration(hours: 4),
      Duration(hours: 5),
      Duration(hours: 6),
      Duration(hours: 7),
      Duration(hours: 8),
      Duration(hours: 9),
      Duration(hours: 10),
      Duration(hours: 11),
      Duration(hours: 12),
    ];

    return showModalBottomSheetWithProperFocus(
      context: context,
      builder: (context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            'Sleep timer',
            padding: EdgeInsets.fromLTRB(16, 0, 16, 4),
            isFirst: true,
          ),
          AnimatedScrollBorder(scrollController: _scrollController),
          Expanded(
            child: ListView(
              controller: _scrollController,
              children: [
                if (widget.chatStore.sleepTimer?.isActive == true)
                  Observer(
                    builder: (context) {
                      return ListTile(
                        leading: const Icon(Icons.close_rounded),
                        title: Text.rich(
                          TextSpan(
                            text: 'Cancel   ',
                            children: [
                              TextSpan(
                                text: formatTimeLeft(
                                  widget.chatStore.timeRemaining,
                                ),
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.color
                                      ?.withValues(alpha: 0.6),
                                  fontFeatures: [FontFeature.tabularFigures()],
                                ),
                              ),
                            ],
                          ),
                        ),
                        onTap: () {
                          widget.chatStore.cancelSleepTimer();

                          Navigator.of(context).pop();
                        },
                      );
                    },
                  ),
                ...durations.map(
                  (duration) => ListTile(
                    leading: const Icon(Icons.hourglass_top_rounded),
                    title: Text(formatDuration(duration)),
                    onTap: () {
                      widget.chatStore.updateSleepTimer(
                        duration: duration,
                        onTimerFinished: () => navigatorKey.currentState
                            ?.popUntil((route) => route.isFirst),
                      );

                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Converts a hex color string to a color name if it matches one of our predefined chat colors.
  /// Returns null if no match is found.
  String? _hexToColorName(String hexColor) {
    // Remove # if present
    final cleanHex =
        hexColor.startsWith('#') ? hexColor.substring(1) : hexColor;

    // Convert to uppercase for comparison
    final upperHex = cleanHex.toUpperCase();

    // Find matching color name
    for (final entry in chatColorValues.entries) {
      final colorValue = entry.value.toARGB32().toRadixString(16).toUpperCase();
      // Remove alpha channel (first 2 characters) for comparison
      if (colorValue.length >= 6) {
        final colorHex = colorValue.substring(2);
        if (colorHex == upperHex) {
          return entry.key;
        }
      }
    }

    return null;
  }

  Future<void> _showChatColorPicker(BuildContext context) async {
    final selectedColor = await _getCurrentUserColor();
    if (!context.mounted) return;

    showModalBottomSheetWithProperFocus(
      context: context,
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.5,
        child: _ChatColorPickerModal(
          initialColor: selectedColor,
          scrollController: _scrollController,
          onColorSelected: _handleColorUpdate,
          chatStore: widget.chatStore,
        ),
      ),
    );
  }

  Future<String?> _getCurrentUserColor() async {
    try {
      final currentColorHex = await widget.chatStore.twitchApi.getUserChatColor(
        userId: widget.chatStore.auth.user.details!.id,
      );

      if (currentColorHex.isNotEmpty) {
        return _hexToColorName(currentColorHex);
      }
    } catch (e) {
      // Ignore errors when fetching current color
    }
    return null;
  }

  Future<void> _handleColorUpdate(BuildContext context, String color) async {
    final success = await widget.chatStore.twitchApi.updateUserChatColor(
      userId: widget.chatStore.auth.user.details!.id,
      color: color,
    );

    if (!context.mounted) return;
    Navigator.of(context).pop();

    final message = success
        ? 'Chat color updated successfully!'
        : 'Failed to update chat color. Please try again.';
    _showMessage(context, message);
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  bool _hasActiveModes() {
    final roomState = widget.chatDetailsStore.roomState;
    return roomState.subMode != '0' ||
        roomState.followersOnly != '-1' ||
        roomState.emoteOnly != '0' ||
        roomState.slowMode != '0' ||
        roomState.r9k != '0';
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) {
        final hasActiveModes = _hasActiveModes();

        final children = [
          if (hasActiveModes) ...[
            const SectionHeader(
              'Active chat modes',
              padding: EdgeInsets.symmetric(horizontal: 16),
              isFirst: true,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ChatModes(roomState: widget.chatDetailsStore.roomState),
            ),
            const Divider(
              height: 16,
              indent: 16,
              endIndent: 16,
            ),
          ],
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: GridView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 16 / 9,
              ),
              children: [
                _buildActionCard(
                  icon: Icons.people_outline,
                  label: 'Chatters',
                  onTap: () => showModalBottomSheetWithProperFocus(
                    isScrollControlled: true,
                    context: context,
                    builder: (context) => GestureDetector(
                      onTap: FocusScope.of(context).unfocus,
                      child: ChattersList(
                        chatDetailsStore: widget.chatDetailsStore,
                        chatStore: widget.chatStore,
                        userLogin: widget.userLogin,
                      ),
                    ),
                  ),
                ),
                Observer(
                  builder: (context) {
                    final hasTimer =
                        widget.chatStore.timeRemaining.inSeconds > 0;
                    final label = hasTimer
                        ? formatTimeLeft(widget.chatStore.timeRemaining)
                        : 'Sleep timer';
                    return _buildActionCard(
                      icon: Icons.timer_outlined,
                      label: label,
                      labelStyle: hasTimer
                          ? const TextStyle(
                              fontFeatures: [FontFeature.tabularFigures()],
                            )
                          : null,
                      onTap: () => _showSleepTimer(context),
                    );
                  },
                ),
                if (widget.chatStore.auth.isLoggedIn)
                  _buildActionCard(
                    icon: Icons.palette_outlined,
                    label: 'Username color',
                    onTap: () => _showChatColorPicker(context),
                  ),
                _buildActionCard(
                  icon: Icons.refresh_rounded,
                  label: 'Reconnect to chat',
                  onTap: () {
                    widget.chatStore
                        .updateNotification('Reconnecting to chat...');
                    widget.chatStore.connectToChat();
                  },
                ),
                _buildActionCard(
                  icon: Icons.refresh_rounded,
                  label: 'Refresh badges and emotes',
                  onTap: () async {
                    await widget.chatStore.getAssets();
                    widget.chatStore.updateNotification(
                      'Badges and emotes refreshed',
                    );
                  },
                ),
                Observer(
                  builder: (context) {
                    final showVideo = widget.chatStore.settings.showVideo;
                    final label =
                        '${showVideo ? 'Enter' : 'Exit'} chat-only mode';
                    return _buildActionCard(
                      icon: Icons.chat_outlined,
                      label: label,
                      onTap: () => widget.chatStore.settings.showVideo =
                          !widget.chatStore.settings.showVideo,
                    );
                  },
                ),
                _buildActionCard(
                  icon: Icons.settings_outlined,
                  label: 'Settings',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Settings(
                        settingsStore: widget.chatStore.settings,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ];

        return ListView(
          shrinkWrap: true,
          primary: false,
          children: children,
        );
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}

extension on _ChatDetailsState {
  Widget _buildActionCard({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
    TextStyle? labelStyle,
  }) {
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: const AspectRatio(
          aspectRatio: 16 / 9,
          child: _CardContents(),
        )._withIconAndLabel(icon, label, labelStyle: labelStyle),
      ),
    );
  }
}

class _CardContents extends StatelessWidget {
  const _CardContents({
    this.icon,
    this.label,
    this.labelStyle,
  });

  final IconData? icon;
  final String? label;
  final TextStyle? labelStyle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) Icon(icon),
          if (label != null) ...[
            const SizedBox(height: 8),
            Text(
              label!,
              textAlign: TextAlign.center,
              style: labelStyle,
            ),
          ],
        ],
      ),
    );
  }
}

extension on Widget {
  Widget _withIconAndLabel(
    IconData icon,
    String label, {
    TextStyle? labelStyle,
  }) {
    return _CardContents(icon: icon, label: label, labelStyle: labelStyle);
  }
}

class _ChatColorPickerModal extends StatefulWidget {
  const _ChatColorPickerModal({
    required this.initialColor,
    required this.scrollController,
    required this.onColorSelected,
    required this.chatStore,
  });

  final String? initialColor;
  final ScrollController scrollController;
  final Future<void> Function(BuildContext context, String color)
      onColorSelected;
  final ChatStore chatStore;

  @override
  State<_ChatColorPickerModal> createState() => _ChatColorPickerModalState();
}

class _ChatColorPickerModalState extends State<_ChatColorPickerModal> {
  String? selectedColor;

  @override
  void initState() {
    super.initState();
    selectedColor = widget.initialColor;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        _buildPreview(),
        AnimatedScrollBorder(scrollController: widget.scrollController),
        _buildColorList(),
        _buildBottomBar(),
      ],
    );
  }

  Widget _buildHeader() {
    return const SectionHeader(
      'Username color',
      isFirst: true,
    );
  }

  Widget _buildPreview() {
    if (selectedColor == null) return const SizedBox.shrink();

    // Create a realistic preview using the current user's chat state and badges
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: _buildRealisticChatPreview(),
    );
  }

  Widget _buildRealisticChatPreview() {
    final userDetails = widget.chatStore.auth.user.details!;
    final userState = widget.chatStore.userState;

    // Create a mock IRC message with the user's current state
    final mockTags = <String, String>{
      'display-name': userDetails.displayName,
      'color':
          '#${chatColorValues[selectedColor!]!.toARGB32().toRadixString(16).substring(2)}',
      'user-id': userDetails.id,
      'mod': userState.mod ? '1' : '0',
      'subscriber': userState.subscriber ? '1' : '0',
      'id': 'preview-message',
      'tmi-sent-ts': DateTime.now().millisecondsSinceEpoch.toString(),
    };

    // Copy any badges from the current user state
    if (userState.raw != null) {
      final userStateMessage = IRCMessage.fromString(userState.raw!);
      if (userStateMessage.tags['badges'] != null) {
        mockTags['badges'] = userStateMessage.tags['badges']!;
      }
      if (userStateMessage.tags['badge-info'] != null) {
        mockTags['badge-info'] = userStateMessage.tags['badge-info']!;
      }
    }

    final mockMessage = IRCMessage(
      raw: '',
      command: Command.privateMessage,
      tags: mockTags,
      user: userDetails.login,
      message: 'How it will look in chat',
      split: [
        'How',
        'it',
        'will',
        'look',
        'in',
        'chat',
      ],
      action: false,
      mention: false,
    );

    return Text.rich(
      TextSpan(
        children: mockMessage.generateSpan(
          context,
          assetsStore: widget.chatStore.assetsStore,
          emoteScale: widget.chatStore.settings.emoteScale,
          badgeScale: widget.chatStore.settings.badgeScale,
          launchExternal: false, // Disable launching for preview
          style: DefaultTextStyle.of(context).style,
        ),
      ),
    );
  }

  Widget _buildColorList() {
    return Expanded(
      child: Scrollbar(
        controller: widget.scrollController,
        child: ListView(
          padding: EdgeInsets.zero,
          controller: widget.scrollController,
          children: chatColorNames
              .map((colorName) => _buildColorTile(colorName))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildColorTile(String colorName) {
    final isSelected = selectedColor == colorName;
    final displayName = colorName
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');

    // Apply the same color adjustment for consistent preview
    final rawColor = chatColorValues[colorName]!;
    final adjustedColor = adjustChatNameColor(context, rawColor);

    return ListTile(
      leading: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: adjustedColor,
          shape: BoxShape.circle,
        ),
      ),
      title: Text(displayName),
      trailing: isSelected
          ? Icon(
              Icons.check,
              color: Theme.of(context).colorScheme.primary,
            )
          : null,
      onTap: () => setState(() => selectedColor = colorName),
    );
  }

  Widget _buildBottomBar() {
    return Column(
      children: [
        AnimatedScrollBorder(
          scrollController: widget.scrollController,
          position: ScrollBorderPosition.bottom,
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: selectedColor == null
                        ? null
                        : () => widget.onColorSelected(context, selectedColor!),
                    child: const Text('Save'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
