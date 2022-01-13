import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/screens/channel/chat/details/chat_modes.dart';
import 'package:frosty/screens/channel/chat/details/chat_users_list.dart';
import 'package:frosty/screens/channel/stores/chat_details_store.dart';

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
    return SafeArea(
      bottom: false,
      child: Observer(
        builder: (_) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15.0),
              child: ChatModes(roomState: chatDetails.roomState),
            ),
            Expanded(
              child: ChattersList(
                chatDetails: chatDetails,
                userLogin: userLogin,
              ),
            )
          ],
        ),
      ),
    );
  }
}
