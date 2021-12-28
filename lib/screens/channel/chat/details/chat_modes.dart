import 'package:flutter/material.dart';
import 'package:frosty/models/irc_message.dart';

class ChatModes extends StatelessWidget {
  final ROOMSTATE roomState;

  const ChatModes({Key? key, required this.roomState}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Tooltip(
          preferBelow: false,
          message: 'Emote-Only: ${roomState.emoteOnly != '0' ? 'Enabled' : 'Disabled'}',
          child: Icon(
            Icons.emoji_emotions_outlined,
            color: roomState.emoteOnly != '0' ? Colors.yellow : Colors.grey,
          ),
        ),
        Tooltip(
          preferBelow: false,
          message: roomState.followersOnly == '-1'
              ? 'Followers-Only: Disabled'
              : roomState.followersOnly == '0'
                  ? 'Followers-Only: Only followed users can chat.'
                  : roomState.followersOnly == '1'
                      ? 'Followers-Only: Users followed for at least ${roomState.followersOnly} minute can chat.'
                      : 'Followers-Only: Users followed for at least ${roomState.followersOnly} minutes can chat',
          child: Icon(
            Icons.favorite,
            color: roomState.followersOnly != '-1' ? Colors.red : Colors.grey,
          ),
        ),
        Tooltip(
          preferBelow: false,
          message: 'Unique Chat Messages: ${roomState.r9k != '0' ? 'Enabled' : 'Disabled'}',
          child: Text(
            'R9K',
            style: TextStyle(color: roomState.r9k != '0' ? Colors.purple : Colors.grey),
          ),
        ),
        Tooltip(
          preferBelow: false,
          message: 'Slow: ${roomState.slowMode == '0' ? 'Disabled' : '${roomState.slowMode} seconds'}',
          child: Icon(
            Icons.history_toggle_off,
            color: roomState.slowMode != '0' ? Colors.blue : Colors.grey,
          ),
        ),
        Tooltip(
          preferBelow: false,
          message: 'Subs-Only: ${roomState.subMode != '0' ? 'Enabled' : 'Disabled'}',
          child: Icon(
            Icons.attach_money,
            color: roomState.subMode != '0' ? Colors.green : Colors.grey,
          ),
        ),
      ],
    );
  }
}
