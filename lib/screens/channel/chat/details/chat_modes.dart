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
          message: 'Emote-Only Mode: ${roomState.emoteOnly != '0' ? 'On' : 'Off'}',
          child: Icon(
            Icons.emoji_emotions_outlined,
            color: roomState.emoteOnly != '0' ? Colors.yellow : Colors.grey,
          ),
        ),
        Tooltip(
          preferBelow: false,
          message: roomState.followersOnly == '-1'
              ? 'Followers-Only Mode: Off'
              : roomState.followersOnly == '0'
                  ? 'Followers-Only Mode: On'
                  : roomState.followersOnly == '1'
                      ? 'Followers-Only Mode: On, ${roomState.followersOnly} minute'
                      : 'Followers-Only Mode: On, ${roomState.followersOnly} minutes',
          child: Icon(
            Icons.favorite,
            color: roomState.followersOnly != '-1' ? Colors.red : Colors.grey,
          ),
        ),
        Tooltip(
          preferBelow: false,
          message: 'R9K Mode: ${roomState.r9k != '0' ? 'On' : 'Off'}',
          child: Text(
            'R9K',
            style: TextStyle(color: roomState.r9k != '0' ? Colors.purple : Colors.grey),
          ),
        ),
        Tooltip(
          preferBelow: false,
          message: 'Slow Mode: ${roomState.slowMode != '0' ? 'On, ${roomState.slowMode} seconds' : 'Off'}',
          child: Icon(
            Icons.history_toggle_off,
            color: roomState.slowMode != '0' ? Colors.blue : Colors.grey,
          ),
        ),
        Tooltip(
          preferBelow: false,
          message: 'Subs-Only Mode: ${roomState.subMode != '0' ? 'On' : 'Off'}',
          child: Icon(
            Icons.attach_money,
            color: roomState.subMode != '0' ? Colors.green : Colors.grey,
          ),
        ),
      ],
    );
  }
}
