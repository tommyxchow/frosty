import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/core/settings/settings_store.dart';
import 'package:frosty/models/irc_message.dart';
import 'package:frosty/screens/channel/chat/chat_assets_store.dart';

class ChatMessage extends StatelessWidget {
  final IRCMessage ircMessage;
  final ChatAssetsStore assetsStore;
  final SettingsStore settingsStore;

  const ChatMessage({Key? key, required this.ircMessage, required this.assetsStore, required this.settingsStore}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const padding = EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0);

    return Observer(
      builder: (context) {
        final timeStamps = settingsStore.timeStampsEnabled
            ? settingsStore.twelveHourTimeStamp
                ? Timestamp.twelve
                : Timestamp.twentyFour
            : Timestamp.none;

        switch (ircMessage.command) {
          case Command.privateMessage:
          case Command.userState:
            // Render normal chat message (PRIVMSG).
            return Padding(
              padding: padding,
              child: Text.rich(
                TextSpan(
                  children: ircMessage.generateSpan(
                    style: DefaultTextStyle.of(context).style,
                    emoteToObject: assetsStore.emoteToObject,
                    twitchBadgeToObject: assetsStore.twitchBadgesToObject,
                    ffzUserToBadges: assetsStore.userToFFZBadges,
                    sevenTVUserToBadges: assetsStore.userTo7TVBadges,
                    bttvUserToBadge: assetsStore.userToBTTVBadges,
                    ffzRoomInfo: assetsStore.ffzRoomInfo,
                    zeroWidthEnabled: settingsStore.zeroWidthEnabled,
                    timestamp: timeStamps,
                  ),
                ),
              ),
            );
          case Command.clearChat:
          case Command.clearMessage:
            // Render timeouts and bans
            final banDuration = ircMessage.tags['ban-duration'];
            return Padding(
              padding: padding,
              child: Opacity(
                opacity: 0.50,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(
                      TextSpan(
                        children: ircMessage.generateSpan(
                          style: DefaultTextStyle.of(context).style,
                          emoteToObject: assetsStore.emoteToObject,
                          twitchBadgeToObject: assetsStore.twitchBadgesToObject,
                          ffzUserToBadges: assetsStore.userToFFZBadges,
                          sevenTVUserToBadges: assetsStore.userTo7TVBadges,
                          bttvUserToBadge: assetsStore.userToBTTVBadges,
                          ffzRoomInfo: assetsStore.ffzRoomInfo,
                          hideMessage: settingsStore.hideBannedMessages,
                          zeroWidthEnabled: settingsStore.zeroWidthEnabled,
                          timestamp: timeStamps,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5.0),
                    if (banDuration == null)
                      if (ircMessage.command == Command.clearMessage)
                        const Text('Message Deleted', style: TextStyle(fontWeight: FontWeight.bold))
                      else
                        const Text('User Permanently Banned', style: TextStyle(fontWeight: FontWeight.bold))
                    else
                      Text(
                        int.parse(banDuration) > 1 ? 'Timed out for $banDuration seconds' : 'Timed out for $banDuration second',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      )
                  ],
                ),
              ),
            );
          case Command.notice:
            return Padding(
              padding: padding,
              child: Text.rich(
                TextSpan(
                  text: ircMessage.message,
                ),
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyText2?.color?.withOpacity(0.5),
                ),
              ),
            );
          case Command.userNotice:
            return Container(
              padding: padding,
              color: const Color(0xFF673AB7).withOpacity(0.25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(ircMessage.tags['system-msg']!),
                  const SizedBox(height: 5.0),
                  if (ircMessage.message != null)
                    Text.rich(
                      TextSpan(
                        children: ircMessage.generateSpan(
                          style: DefaultTextStyle.of(context).style,
                          emoteToObject: assetsStore.emoteToObject,
                          twitchBadgeToObject: assetsStore.twitchBadgesToObject,
                          ffzUserToBadges: assetsStore.userToFFZBadges,
                          sevenTVUserToBadges: assetsStore.userTo7TVBadges,
                          bttvUserToBadge: assetsStore.userToBTTVBadges,
                          ffzRoomInfo: assetsStore.ffzRoomInfo,
                          zeroWidthEnabled: settingsStore.zeroWidthEnabled,
                          timestamp: timeStamps,
                        ),
                      ),
                    ),
                ],
              ),
            );
          default:
            return const SizedBox();
        }
      },
    );
  }
}
