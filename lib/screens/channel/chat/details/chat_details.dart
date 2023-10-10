import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/main.dart';
import 'package:frosty/screens/channel/chat/details/chat_details_store.dart';
import 'package:frosty/screens/channel/chat/details/chat_modes.dart';
import 'package:frosty/screens/channel/chat/details/chat_users_list.dart';
import 'package:frosty/screens/channel/chat/stores/chat_store.dart';
import 'package:frosty/screens/settings/settings.dart';
import 'package:frosty/widgets/button.dart';
import 'package:frosty/widgets/dialog.dart';
import 'package:frosty/widgets/list_tile.dart';

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

  Future<void> _showSleepTimerDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => FrostyDialog(
        title: 'Sleep Timer',
        content: Observer(
          builder: (context) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Opacity(
                opacity: chatStore.sleepTimer != null &&
                        chatStore.sleepTimer!.isActive
                    ? 1.0
                    : 0.5,
                child: Row(
                  children: [
                    const Icon(Icons.timer_rounded),
                    Text(
                      ' ${chatStore.timeRemaining.toString().split('.')[0]}',
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontFeatures: [FontFeature.tabularFigures()]),
                    ),
                    const Spacer(),
                    IconButton(
                      tooltip: 'Cancel sleep timer',
                      onPressed: chatStore.cancelSleepTimer,
                      icon: const Icon(Icons.cancel_rounded),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  DropdownButton(
                    value: chatStore.sleepHours,
                    items: List.generate(24, (index) => index)
                        .map((e) => DropdownMenuItem(
                            value: e, child: Text(e.toString())))
                        .toList(),
                    onChanged: (int? hours) => chatStore.sleepHours = hours!,
                    menuMaxHeight: 200,
                  ),
                  const SizedBox(width: 10.0),
                  const Text('Hours'),
                ],
              ),
              Row(
                children: [
                  DropdownButton(
                    value: chatStore.sleepMinutes,
                    items: List.generate(60, (index) => index)
                        .map((e) => DropdownMenuItem(
                            value: e, child: Text(e.toString())))
                        .toList(),
                    onChanged: (int? minutes) =>
                        chatStore.sleepMinutes = minutes!,
                    menuMaxHeight: 200,
                  ),
                  const SizedBox(width: 10.0),
                  const Text('Minutes'),
                ],
              ),
            ],
          ),
        ),
        actions: [
          Observer(
            builder: (context) => Button(
              onPressed:
                  chatStore.sleepHours == 0 && chatStore.sleepMinutes == 0
                      ? null
                      : () => chatStore.updateSleepTimer(
                            onTimerFinished: () => navigatorKey.currentState
                                ?.popUntil((route) => route.isFirst),
                          ),
              child: const Text('Set timer'),
            ),
          ),
          Button(
            onPressed: Navigator.of(context).pop,
            color: Colors.grey,
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _showClearDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => FrostyDialog(
        title: 'Clear Recent Emotes',
        message: 'Are you sure you want to clear your recent emotes?',
        actions: [
          Button(
            onPressed: Navigator.of(context).pop,
            child: const Text('Yes'),
          ),
          Button(
            onPressed: Navigator.of(context).pop,
            color: Colors.grey,
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final children = [
      ListTile(
        title: ChatModes(roomState: chatDetailsStore.roomState),
      ),
      FrostyListTile(
        leading: const Icon(Icons.people_outline),
        title: 'Chatters',
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
      FrostyListTile(
        leading: const Icon(Icons.timer_outlined),
        title: 'Sleep timer',
        onTap: () => _showSleepTimerDialog(context),
      ),
      FrostyListTile(
        leading: const Icon(Icons.delete_outline_rounded),
        title: 'Clear recent emotes',
        onTap: () => _showClearDialog(context),
      ),
      FrostyListTile(
        leading: const Icon(Icons.refresh_rounded),
        title: 'Reconnect to chat',
        onTap: () {
          chatStore.updateNotification('Reconnecting to chat...');

          chatStore.connectToChat();
        },
      ),
      FrostyListTile(
        leading: const Icon(Icons.refresh_rounded),
        title: 'Refresh badges and emotes',
        onTap: () async {
          await chatStore.getAssets();

          chatStore.updateNotification('Badges and emotes refreshed');
        },
      ),
      FrostyListTile(
        leading: const Icon(Icons.settings_outlined),
        title: 'Settings',
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
