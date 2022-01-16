import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/models/irc.dart';
import 'package:frosty/screens/channel/stores/chat_assets_store.dart';
import 'package:frosty/screens/settings/stores/settings_store.dart';

class ChatMessage extends StatelessWidget {
  final IRCMessage ircMessage;
  final ChatAssetsStore assetsStore;
  final SettingsStore settingsStore;

  const ChatMessage({
    Key? key,
    required this.ircMessage,
    required this.assetsStore,
    required this.settingsStore,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const highlightPadding = EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0);
    const messagePadding = EdgeInsets.symmetric(horizontal: 10.0);

    switch (ircMessage.command) {
      case Command.privateMessage:
      case Command.userState:
        // Render normal chat message (PRIVMSG).
        final child = Observer(
          builder: (context) => Text.rich(
            TextSpan(
              children: ircMessage.generateSpan(
                style: DefaultTextStyle.of(context).style,
                assetsStore: assetsStore,
                emoteHeight: settingsStore.emoteHeight,
                badgeHeight: settingsStore.badgeHeight,
                useZeroWidth: settingsStore.showZeroWidth,
                useReadableColors: settingsStore.useReadableColors,
                isLightTheme: Theme.of(context).brightness == Brightness.light,
                timestamp: settingsStore.timestampType,
              ),
            ),
          ),
        );

        if (ircMessage.mention == true) {
          return Container(
            padding: highlightPadding,
            color: const Color(0x4DFF0000),
            child: child,
          );
        }
        return Padding(
          padding: messagePadding,
          child: child,
        );
      case Command.clearChat:
      case Command.clearMessage:
        // Render timeouts and bans
        final banDuration = ircMessage.tags['ban-duration'];
        return Padding(
          padding: highlightPadding,
          child: Opacity(
            opacity: 0.50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Observer(
                  builder: (context) => Text.rich(
                    TextSpan(
                      children: ircMessage.generateSpan(
                        style: DefaultTextStyle.of(context).style,
                        assetsStore: assetsStore,
                        emoteHeight: settingsStore.emoteHeight,
                        badgeHeight: settingsStore.badgeHeight,
                        showMessage: settingsStore.showDeletedMessages,
                        useZeroWidth: settingsStore.showZeroWidth,
                        useReadableColors: settingsStore.useReadableColors,
                        isLightTheme: Theme.of(context).brightness == Brightness.light,
                        timestamp: settingsStore.timestampType,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 5.0),
                if (banDuration == null)
                  if (ircMessage.command == Command.clearMessage)
                    const Text(
                      'Message Deleted',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )
                  else
                    const Text(
                      'User Permanently Banned',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )
                else
                  Text(
                    'Timed out for $banDuration ${int.parse(banDuration) > 1 ? 'seconds' : 'second'}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  )
              ],
            ),
          ),
        );
      case Command.notice:
        return Padding(
          padding: messagePadding,
          child: Text.rich(
            TextSpan(text: ircMessage.message),
            style: TextStyle(color: Theme.of(context).textTheme.bodyText2?.color?.withOpacity(0.5)),
          ),
        );
      case Command.userNotice:
        return Container(
          padding: highlightPadding,
          color: const Color(0x339146FF),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(ircMessage.tags['system-msg']!),
              const SizedBox(height: 5.0),
              if (ircMessage.message != null)
                Observer(
                  builder: (context) => Text.rich(
                    TextSpan(
                      children: ircMessage.generateSpan(
                        style: DefaultTextStyle.of(context).style,
                        assetsStore: assetsStore,
                        emoteHeight: settingsStore.emoteHeight,
                        badgeHeight: settingsStore.badgeHeight,
                        useZeroWidth: settingsStore.showZeroWidth,
                        useReadableColors: settingsStore.useReadableColors,
                        isLightTheme: Theme.of(context).brightness == Brightness.light,
                        timestamp: settingsStore.timestampType,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      default:
        return const SizedBox();
    }
  }
}
