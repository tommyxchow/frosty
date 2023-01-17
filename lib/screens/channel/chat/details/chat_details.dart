import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/main.dart';
import 'package:frosty/screens/channel/chat/details/chat_details_store.dart';
import 'package:frosty/screens/channel/chat/details/chat_modes.dart';
import 'package:frosty/screens/channel/chat/details/chat_users_list.dart';
import 'package:frosty/screens/channel/chat/stores/chat_store.dart';
import 'package:frosty/screens/settings/settings.dart';
import 'package:frosty/widgets/bottom_sheet.dart';
import 'package:frosty/widgets/button.dart';
import 'package:frosty/widgets/dialog.dart';
import 'package:frosty/widgets/list_tile.dart';
import 'package:frosty/widgets/section_header.dart';
import 'package:heroicons/heroicons.dart';

class ChatDetails extends StatefulWidget {
  final ChatDetailsStore chatDetailsStore;
  final ChatStore chatStore;
  final String userLogin;

  const ChatDetails({
    Key? key,
    required this.chatDetailsStore,
    required this.chatStore,
    required this.userLogin,
  }) : super(key: key);

  @override
  State<ChatDetails> createState() => _ChatDetailsState();
}

class _ChatDetailsState extends State<ChatDetails> {
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
                opacity: widget.chatStore.sleepTimer != null && widget.chatStore.sleepTimer!.isActive ? 1.0 : 0.5,
                child: Row(
                  children: [
                    const HeroIcon(HeroIcons.clock, style: HeroIconStyle.solid),
                    Text(
                      ' ${widget.chatStore.timeRemaining.toString().split('.')[0]}',
                      style: const TextStyle(fontWeight: FontWeight.w600, fontFeatures: [FontFeature.tabularFigures()]),
                    ),
                    const Spacer(),
                    IconButton(
                      tooltip: 'Cancel sleep timer',
                      onPressed: widget.chatStore.cancelSleepTimer,
                      icon: const HeroIcon(HeroIcons.xCircle, style: HeroIconStyle.solid),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  DropdownButton(
                    value: widget.chatStore.sleepHours,
                    items: List.generate(24, (index) => index)
                        .map((e) => DropdownMenuItem(value: e, child: Text(e.toString())))
                        .toList(),
                    onChanged: (int? hours) => widget.chatStore.sleepHours = hours!,
                    menuMaxHeight: 200,
                  ),
                  const SizedBox(width: 10.0),
                  const Text('Hours'),
                ],
              ),
              Row(
                children: [
                  DropdownButton(
                    value: widget.chatStore.sleepMinutes,
                    items: List.generate(60, (index) => index)
                        .map((e) => DropdownMenuItem(value: e, child: Text(e.toString())))
                        .toList(),
                    onChanged: (int? minutes) => widget.chatStore.sleepMinutes = minutes!,
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
              onPressed: widget.chatStore.sleepHours == 0 && widget.chatStore.sleepMinutes == 0
                  ? null
                  : () => widget.chatStore.updateSleepTimer(
                        onTimerFinished: () => navigatorKey.currentState?.popUntil((route) => route.isFirst),
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

  Future<void> _showClearDialog() {
    return showDialog(
      context: context,
      builder: (context) => FrostyDialog(
        title: 'Clear Recent Emotes',
        message: 'Are you sure you want to clear your recent emotes?',
        actions: [
          Button(
            onPressed: () {
              setState(widget.chatStore.assetsStore.recentEmotes.clear);
              Navigator.pop(context);
            },
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
  void initState() {
    super.initState();
    widget.chatDetailsStore.updateChatters();
  }

  @override
  Widget build(BuildContext context) {
    final children = [
      const SectionHeader('Chat modes'),
      ListTile(
        title: ChatModes(roomState: widget.chatDetailsStore.roomState),
      ),
      const SectionHeader('Other'),
      FrostyListTile(
        leading: const HeroIcon(HeroIcons.users),
        title: 'Chatters',
        onTap: () => showModalBottomSheet(
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
          context: context,
          builder: (context) => FrostyBottomSheet(
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.8,
              child: GestureDetector(
                onTap: FocusScope.of(context).unfocus,
                child: ChattersList(
                  chatDetailsStore: widget.chatDetailsStore,
                  chatStore: widget.chatStore,
                  userLogin: widget.userLogin,
                ),
              ),
            ),
          ),
        ),
      ),
      FrostyListTile(
        leading: const HeroIcon(HeroIcons.clock),
        title: 'Sleep timer',
        onTap: () => _showSleepTimerDialog(context),
      ),
      FrostyListTile(
        leading: const HeroIcon(HeroIcons.trash),
        title: 'Clear recent emotes',
        onTap: _showClearDialog,
      ),
      FrostyListTile(
        leading: const HeroIcon(HeroIcons.arrowPath),
        title: 'Reconnect to chat',
        onTap: () {
          widget.chatStore.updateNotification('Reconnecting to chat...');

          widget.chatStore.connectToChat();
        },
      ),
      FrostyListTile(
        leading: const HeroIcon(HeroIcons.arrowPath),
        title: 'Refresh badges and emotes',
        onTap: () async {
          await widget.chatStore.getAssets();

          widget.chatStore.updateNotification('Badges and emotes refreshed');
        },
      ),
      FrostyListTile(
        leading: const HeroIcon(HeroIcons.cog6Tooth),
        title: 'Settings',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Settings(settingsStore: widget.chatStore.settings),
          ),
        ),
      ),
    ];

    return FrostyBottomSheet(
      child: MediaQuery.of(context).orientation == Orientation.landscape
          ? SizedBox(
              height: MediaQuery.of(context).size.height * 0.8,
              child: ListView(
                children: children,
              ),
            )
          : Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }
}
