import 'package:flutter/material.dart';
import 'package:frosty/models/irc.dart';

class ChatModes extends StatelessWidget {
  final ROOMSTATE roomState;

  const ChatModes({Key? key, required this.roomState}) : super(key: key);

  String pluralize(String str, String count) => count == '1' ? str : '${str}s';

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Tooltip(
          preferBelow: false,
          triggerMode: TooltipTriggerMode.tap,
          showDuration: const Duration(seconds: 3),
          message:
              'Emote-only mode ${roomState.emoteOnly != '0' ? 'on' : 'off'}',
          child: Icon(
            roomState.emoteOnly != '0'
                ? Icons.emoji_emotions_rounded
                : Icons.emoji_emotions_outlined,
            color: roomState.emoteOnly != '0' ? Colors.yellow : Colors.grey,
          ),
        ),
        Tooltip(
          preferBelow: false,
          triggerMode: TooltipTriggerMode.tap,
          showDuration: const Duration(seconds: 3),
          message: roomState.followersOnly == '-1'
              ? 'Followers-only mode off'
              : roomState.followersOnly == '0'
                  ? 'Followers-only mode on'
                  : 'Followers-only mode on (${roomState.followersOnly} ${pluralize('minute', roomState.followersOnly)})',
          child: Icon(
            roomState.followersOnly != '-1'
                ? Icons.favorite_rounded
                : Icons.favorite_outline_rounded,
            color: roomState.followersOnly != '-1' ? Colors.red : Colors.grey,
          ),
        ),
        Tooltip(
          preferBelow: false,
          triggerMode: TooltipTriggerMode.tap,
          showDuration: const Duration(seconds: 3),
          message:
              'R9K (unique-chat) mode ${roomState.r9k != '0' ? 'on' : 'off'}',
          child: Text(
            'R9K',
            style: TextStyle(
              color: roomState.r9k != '0' ? Colors.purple : Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Tooltip(
          preferBelow: false,
          triggerMode: TooltipTriggerMode.tap,
          showDuration: const Duration(seconds: 3),
          message:
              'Slow mode ${roomState.slowMode != '0' ? 'on (${roomState.slowMode} ${pluralize('second', roomState.slowMode)})' : 'off'}',
          child: Icon(
            roomState.slowMode != '0'
                ? Icons.hourglass_top_rounded
                : Icons.hourglass_empty_rounded,
            color: roomState.slowMode != '0' ? Colors.blue : Colors.grey,
          ),
        ),
        Tooltip(
          preferBelow: false,
          triggerMode: TooltipTriggerMode.tap,
          showDuration: const Duration(seconds: 3),
          message: 'Subs-only mode ${roomState.subMode != '0' ? 'on' : 'off'}',
          child: Icon(
            roomState.subMode != '0'
                ? Icons.monetization_on_rounded
                : Icons.monetization_on_outlined,
            color: roomState.subMode != '0' ? Colors.green : Colors.grey,
          ),
        ),
      ],
    );
  }
}
