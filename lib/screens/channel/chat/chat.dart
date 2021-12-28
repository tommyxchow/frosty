import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/core/auth/auth_store.dart';
import 'package:frosty/core/settings/settings_store.dart';
import 'package:frosty/screens/channel/chat/chat_bottom_bar.dart';
import 'package:frosty/screens/channel/chat/chat_message.dart';
import 'package:frosty/screens/channel/chat/chat_store.dart';
import 'package:frosty/screens/channel/chat/emote_menu/emote_menu.dart';
import 'package:provider/provider.dart';

class Chat extends StatefulWidget {
  final ChatStore chatStore;

  const Chat({Key? key, required this.chatStore}) : super(key: key);

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    widget.chatStore.handleAppStateChange(state);
  }

  @override
  Widget build(BuildContext context) {
    final chatStore = widget.chatStore;

    return Observer(
      builder: (context) => Column(
        children: [
          Expanded(
            child: Stack(
              alignment: AlignmentDirectional.bottomCenter,
              children: [
                GestureDetector(
                  onTap: () {
                    // If tapping chat, hide the keyboard and emote menu.
                    FocusManager.instance.primaryFocus?.unfocus();
                    if (chatStore.assetsStore.showEmoteMenu) chatStore.assetsStore.showEmoteMenu = false;
                  },
                  child: Observer(
                    builder: (context) => ListView.separated(
                      addAutomaticKeepAlives: false,
                      addRepaintBoundaries: false,
                      padding: const EdgeInsets.all(10.0),
                      itemCount: chatStore.messages.length,
                      controller: chatStore.scrollController,
                      separatorBuilder: (context, index) => const SizedBox(height: 10.0),
                      itemBuilder: (context, index) => Observer(
                        builder: (context) => ChatMessage(
                          ircMessage: chatStore.messages[index],
                          assetsStore: chatStore.assetsStore,
                          hideMessageIfBanned: chatStore.settings.hideBannedMessages,
                          zeroWidth: chatStore.settings.zeroWidthEnabled,
                        ),
                      ),
                    ),
                  ),
                ),
                Observer(
                  builder: (_) => Visibility(
                    visible: !chatStore.autoScroll,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: chatStore.resumeScroll,
                        child: const Text('Resume Scroll'),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (chatStore.auth.isLoggedIn) ChatBottomBar(chatStore: chatStore),
          if (chatStore.assetsStore.showEmoteMenu)
            Expanded(
              child: EmoteMenu(
                assetsStore: chatStore.assetsStore,
                textController: chatStore.textController,
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    widget.chatStore.dispose();
    super.dispose();
  }
}
