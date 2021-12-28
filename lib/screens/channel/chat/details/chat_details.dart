import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/screens/channel/chat/details/chat_details_store.dart';
import 'package:frosty/screens/channel/chat/details/chat_modes.dart';
import 'package:frosty/screens/channel/chat/details/chat_users_list.dart';

class ChatDetails extends StatelessWidget {
  final ChatDetailsStore chatDetails;
  final String userLogin;

  const ChatDetails({
    Key? key,
    required this.chatDetails,
    required this.userLogin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.5,
      child: Center(
        child: Observer(
          builder: (_) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: ChatModes(roomState: chatDetails.roomState),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => chatDetails.updateChatters(userLogin),
                    child: ChattersList(
                      chatUsers: chatDetails.chatters,
                    ),
                  ),
                )
              ],
            );
          },
        ),
      ),
    );
  }
}