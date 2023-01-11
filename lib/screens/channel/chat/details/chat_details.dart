import 'package:flutter/material.dart';
import 'package:frosty/screens/channel/chat/details/chat_details_store.dart';
import 'package:frosty/screens/channel/chat/details/chat_modes.dart';
import 'package:frosty/screens/channel/chat/details/chat_users_list.dart';
import 'package:frosty/screens/channel/chat/stores/chat_store.dart';
import 'package:frosty/widgets/bottom_sheet.dart';
import 'package:frosty/widgets/button.dart';
import 'package:frosty/widgets/dialog.dart';
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
  Future<void> _showClearDialog() {
    return showDialog(
      context: context,
      builder: (context) => FrostyDialog(
        title: 'Clear Recent Emotes',
        content: const Text('Are you sure you want to clear your recent emotes?'),
        actions: [
          Button(
            onPressed: () {
              setState(widget.chatStore.assetsStore.recentEmotes.clear);
              Navigator.pop(context);
            },
            child: const Text('Yes'),
          ),
          Button(
            fill: true,
            onPressed: Navigator.of(context).pop,
            color: Colors.red.shade700,
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
    return FrostyBottomSheet(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader('Chat modes'),
          ListTile(
            title: ChatModes(roomState: widget.chatDetailsStore.roomState),
          ),
          const SectionHeader('Other'),
          ListTile(
            leading: const HeroIcon(HeroIcons.users),
            title: const Text('Chatters'),
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
          ListTile(
            leading: const HeroIcon(HeroIcons.trash),
            title: const Text('Clear recent emotes'),
            onTap: _showClearDialog,
          ),
          ListTile(
            leading: const HeroIcon(HeroIcons.arrowPath),
            title: const Text('Reconnect to chat'),
            onTap: () {
              widget.chatStore.updateNotification('Reconnecting to chat...');

              widget.chatStore.connectToChat();
            },
          ),
          ListTile(
            leading: const HeroIcon(HeroIcons.arrowPath),
            title: const Text('Refresh badges and emotes'),
            onTap: () async {
              await widget.chatStore.getAssets();

              widget.chatStore.updateNotification('Badges and emotes refreshed');
            },
          ),
        ],
      ),
    );
  }
}
