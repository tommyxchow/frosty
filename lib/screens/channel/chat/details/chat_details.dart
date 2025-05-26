import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/main.dart';
import 'package:frosty/screens/channel/chat/details/chat_details_store.dart';
import 'package:frosty/screens/channel/chat/details/chat_modes.dart';
import 'package:frosty/screens/channel/chat/details/chat_users_list.dart';
import 'package:frosty/screens/channel/chat/stores/chat_store.dart';
import 'package:frosty/screens/settings/settings.dart';
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
      return '${hours}h ${minutes}m left';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s left';
    } else {
      return '${seconds}s left';
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

    return showModalBottomSheet(
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
                        title: Text(
                          'Turn off (${formatTimeLeft(widget.chatStore.timeRemaining)})',
                          style: const TextStyle(
                            fontFeatures: [FontFeature.tabularFigures()],
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

  Future<void> _showClearDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog.adaptive(
        title: const Text('Clear recent emotes'),
        content:
            const Text('Are you sure you want to clear your recent emotes?'),
        actions: [
          TextButton(
            onPressed: Navigator.of(context).pop,
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              widget.chatStore.assetsStore.recentEmotes.clear();

              Navigator.pop(context);
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final children = [
      const SectionHeader(
        'Chat modes',
        padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
        isFirst: true,
      ),
      ListTile(
        title: ChatModes(roomState: widget.chatDetailsStore.roomState),
      ),
      const SectionHeader(
        'More',
      ),
      ListTile(
        leading: const Icon(Icons.people_outline),
        title: const Text('Chatters'),
        onTap: () => showModalBottomSheet(
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
          return ListTile(
            leading: const Icon(Icons.timer_outlined),
            title: Text(
              'Sleep timer ${widget.chatStore.timeRemaining.inSeconds > 0 ? 'on (${formatTimeLeft(widget.chatStore.timeRemaining)})' : ''}',
              style: const TextStyle(
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
            onTap: () => _showSleepTimer(context),
          );
        },
      ),
      ListTile(
        leading: const Icon(Icons.delete_outline_rounded),
        title: const Text('Clear recent emotes'),
        onTap: () => _showClearDialog(context),
      ),
      ListTile(
        leading: const Icon(Icons.refresh_rounded),
        title: const Text('Reconnect to chat'),
        onTap: () {
          widget.chatStore.updateNotification('Reconnecting to chat...');

          widget.chatStore.connectToChat();
        },
      ),
      ListTile(
        leading: const Icon(Icons.refresh_rounded),
        title: const Text('Refresh badges and emotes'),
        onTap: () async {
          await widget.chatStore.getAssets();

          widget.chatStore.updateNotification('Badges and emotes refreshed');
        },
      ),
      ListTile(
        leading: const Icon(Icons.chat_outlined),
        title: Observer(
          builder: (context) {
            return Text(
              '${widget.chatStore.settings.showVideo ? 'Enter' : 'Exit'} chat-only mode',
            );
          },
        ),
        onTap: () => widget.chatStore.settings.showVideo =
            !widget.chatStore.settings.showVideo,
      ),
      ListTile(
        leading: const Icon(Icons.settings_outlined),
        title: const Text('Settings'),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                Settings(settingsStore: widget.chatStore.settings),
          ),
        ),
      ),
    ];

    return ListView(
      shrinkWrap: true,
      primary: false,
      children: children,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
