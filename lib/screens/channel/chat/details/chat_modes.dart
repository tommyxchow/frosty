import 'package:flutter/material.dart';
import 'package:frosty/models/irc.dart';
import 'package:intl/intl.dart';

class ChatModes extends StatelessWidget {
  final ROOMSTATE roomState;

  const ChatModes({Key? key, required this.roomState}) : super(key: key);

  String pluralize(String str, String count) => count == '1' ? str : '${str}s';

  @override
  Widget build(BuildContext context) {
    final test = Intl.plural(2, other: 'test');

    debugPrint(test);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Tooltip(
          preferBelow: false,
          message: 'Emote-only mode ${roomState.emoteOnly != '0' ? 'on' : 'off'}',
          child: Icon(
            Icons.emoji_emotions_outlined,
            color: roomState.emoteOnly != '0' ? Colors.yellow : Colors.grey,
          ),
        ),
        Tooltip(
          preferBelow: false,
          message: roomState.followersOnly == '-1'
              ? 'Followers-only mode off'
              : roomState.followersOnly == '0'
                  ? 'Followers-only mode on'
                  : 'Followers-only mode on (${roomState.followersOnly} ${pluralize('minute', roomState.followersOnly)})',
          child: Icon(
            Icons.favorite,
            color: roomState.followersOnly != '-1' ? Colors.red : Colors.grey,
          ),
        ),
        Tooltip(
          preferBelow: false,
          message: 'R9K mode ${roomState.r9k != '0' ? 'on' : 'off'}',
          child: Text(
            'R9K',
            style: TextStyle(color: roomState.r9k != '0' ? Colors.purple : Colors.grey),
          ),
        ),
        Tooltip(
          preferBelow: false,
          message: 'Slow mode ${roomState.slowMode != '0' ? 'on (${roomState.slowMode} ${pluralize('second', roomState.slowMode)})' : 'off'}',
          child: Icon(
            Icons.history_toggle_off,
            color: roomState.slowMode != '0' ? Colors.blue : Colors.grey,
          ),
        ),
        Tooltip(
          preferBelow: false,
          message: 'Subs-only mode ${roomState.subMode != '0' ? 'on' : 'off'}',
          child: Icon(
            Icons.attach_money,
            color: roomState.subMode != '0' ? Colors.green : Colors.grey,
          ),
        ),
      ],
    );
  }
}
