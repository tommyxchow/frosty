import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/screens/channel/chat/chat_store.dart';

class ChatStats extends StatelessWidget {
  final ChatStore chatStore;

  const ChatStats({Key? key, required this.chatStore}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.5,
      child: Center(
        child: Observer(
          builder: (_) {
            return ListView(
              children: [
                const ListTile(
                  title: Text('Modes'),
                ),
                ListTile(
                  leading: const Text('Emote-only'),
                  trailing: Text(chatStore.roomState.emoteOnly ? 'Enabled' : 'Disabled'),
                ),
                ListTile(
                  leading: const Text('Followers-only'),
                  trailing: Text(chatStore.roomState.followersOnly == '-1'
                      ? 'Disabled'
                      : chatStore.roomState.followersOnly == '0'
                          ? 'Enabled'
                          : '${chatStore.roomState.followersOnly} minute(s)'),
                ),
                ListTile(
                  leading: const Text('R9K'),
                  trailing: Text(chatStore.roomState.r9k ? 'Enabled' : 'Disabled'),
                ),
                ListTile(
                  leading: const Text('Slow'),
                  trailing: Text(chatStore.roomState.slowMode == '0' ? 'Disabled' : '${chatStore.roomState.slowMode} seconds'),
                ),
                ListTile(
                  leading: const Text('Sub-only'),
                  trailing: Text(chatStore.roomState.subMode ? 'Enabled' : 'Disabled'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
