import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/main.dart';
import 'package:frosty/screens/channel/chat/details/chat_details_store.dart';
import 'package:frosty/screens/channel/chat/details/chat_modes.dart';
import 'package:frosty/screens/channel/chat/details/chat_users_list.dart';
import 'package:frosty/screens/channel/chat/stores/chat_store.dart';
import 'package:frosty/screens/settings/settings.dart';
import 'package:frosty/widgets/section_header.dart';
import 'package:intl/intl.dart';

class ChatDetails extends StatelessWidget {
  final ChatDetailsStore chatDetailsStore;
  final ChatStore chatStore;
  final String userLogin;

  const ChatDetails({
    Key? key,
    required this.chatDetailsStore,
    required this.chatStore,
    required this.userLogin,
  }) : super(key: key);

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
            padding: EdgeInsets.symmetric(horizontal: 16),
          ),
          Expanded(
            child: ListView(
              children: [
                if (chatStore.sleepTimer?.isActive == true)
                  Observer(
                    builder: (context) {
                      return ListTile(
                        leading: const Icon(Icons.close_rounded),
                        title: Text(
                          'Turn off (${formatTimeLeft(chatStore.timeRemaining)})',
                          style: const TextStyle(
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),
                        onTap: () {
                          chatStore.cancelSleepTimer();

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
                      chatStore.updateSleepTimer(
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
            onPressed: Navigator.of(context).pop,
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
        padding: EdgeInsets.symmetric(horizontal: 16),
      ),
      ListTile(
        title: ChatModes(roomState: chatDetailsStore.roomState),
      ),
      const SectionHeader(
        'More',
        padding: EdgeInsets.symmetric(horizontal: 16),
      ),
      ListTile(
        leading: const Icon(Icons.people_outline),
        title: const Text('Chatters'),
        onTap: () => showModalBottomSheet(
          isScrollControlled: true,
          context: context,
          builder: (context) => SizedBox(
            height: MediaQuery.of(context).size.height * 0.8,
            child: GestureDetector(
              onTap: FocusScope.of(context).unfocus,
              child: ChattersList(
                chatDetailsStore: chatDetailsStore,
                chatStore: chatStore,
                userLogin: userLogin,
              ),
            ),
          ),
        ),
      ),
      Observer(
        builder: (context) {
          return ListTile(
            leading: const Icon(Icons.timer_outlined),
            title: Text(
              'Sleep timer ${chatStore.timeRemaining.inSeconds > 0 ? 'on (${formatTimeLeft(chatStore.timeRemaining)})' : ''}',
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
          chatStore.updateNotification('Reconnecting to chat...');

          chatStore.connectToChat();
        },
      ),
      ListTile(
        leading: const Icon(Icons.refresh_rounded),
        title: const Text('Refresh badges and emotes'),
        onTap: () async {
          await chatStore.getAssets();

          chatStore.updateNotification('Badges and emotes refreshed');
        },
      ),
      ListTile(
        leading: const Icon(Icons.settings_outlined),
        title: const Text('Settings'),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Settings(settingsStore: chatStore.settings),
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
}
