import 'package:flutter/material.dart';
import 'package:frosty/models/irc.dart';
import 'package:heroicons/heroicons.dart';

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
          message: 'Emote-only mode ${roomState.emoteOnly != '0' ? 'on' : 'off'}',
          child: HeroIcon(
            HeroIcons.faceSmile,
            color: roomState.emoteOnly != '0' ? Colors.yellow : Colors.grey,
            style: roomState.emoteOnly != '0' ? HeroIconStyle.solid : null,
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
          child: HeroIcon(
            HeroIcons.heart,
            color: roomState.followersOnly != '-1' ? Colors.red : Colors.grey,
            style: roomState.followersOnly != '-1' ? HeroIconStyle.solid : null,
          ),
        ),
        Tooltip(
          preferBelow: false,
          triggerMode: TooltipTriggerMode.tap,
          showDuration: const Duration(seconds: 3),
          message: 'R9K (unique-chat) mode ${roomState.r9k != '0' ? 'on' : 'off'}',
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
          child: HeroIcon(
            HeroIcons.clock,
            color: roomState.slowMode != '0' ? Colors.blue : Colors.grey,
            style: roomState.slowMode != '0' ? HeroIconStyle.solid : null,
          ),
        ),
        Tooltip(
          preferBelow: false,
          triggerMode: TooltipTriggerMode.tap,
          showDuration: const Duration(seconds: 3),
          message: 'Subs-only mode ${roomState.subMode != '0' ? 'on' : 'off'}',
          child: HeroIcon(
            HeroIcons.banknotes,
            color: roomState.subMode != '0' ? Colors.green : Colors.grey,
            style: roomState.subMode != '0' ? HeroIconStyle.solid : null,
          ),
        ),
      ],
    );
  }
}
