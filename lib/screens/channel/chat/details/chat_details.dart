import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/screens/channel/chat/details/chat_details_store.dart';
import 'package:frosty/screens/channel/chat/details/chat_modes.dart';
import 'package:frosty/screens/channel/chat/details/chat_users_list.dart';
import 'package:frosty/screens/channel/chat/stores/chat_store.dart';
import 'package:frosty/screens/settings/settings.dart';
import 'package:frosty/widgets/modal.dart';

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
  @override
  void initState() {
    super.initState();
    widget.chatDetailsStore.updateChatters();
  }

  @override
  Widget build(BuildContext context) {
    return FrostyModal(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: ChatModes(roomState: widget.chatDetailsStore.roomState),
          ),
          ListTile(
            leading: const Icon(Icons.app_settings_alt),
            title: const Text('App settings'),
            onTap: () => showModalBottomSheet(
              backgroundColor: Colors.transparent,
              isScrollControlled: true,
              context: context,
              builder: (context) => FrostyModal(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.8,
                  child: Settings(settingsStore: widget.chatStore.settings),
                ),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Chatters'),
            onTap: () => showModalBottomSheet(
              backgroundColor: Colors.transparent,
              isScrollControlled: true,
              context: context,
              builder: (context) => FrostyModal(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.8,
                  child: GestureDetector(
                    onTap: FocusScope.of(context).unfocus,
                    child: Observer(
                      builder: (_) => ChattersList(
                        chatDetailsStore: widget.chatDetailsStore,
                        chatStore: widget.chatStore,
                        userLogin: widget.userLogin,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.refresh),
            title: const Text('Reconnect to chat'),
            onTap: () {
              widget.chatStore.updateNotification('Reconnecting to chat...');

              widget.chatStore.connectToChat();
            },
          ),
          ListTile(
            leading: const Icon(Icons.refresh),
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
