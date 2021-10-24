import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/widgets.dart';
import 'package:frosty/models/irc.dart';

class IRC {
  // Applies the given CLEARCHAT message to a list and returns the result.
  static void clearChat({required List<IRCMessage> messages, required IRCMessage ircMessage}) {
    // If there is no message, it means that entire chat was cleared.
    if (ircMessage.message == null) {
      messages.clear();
      // messages.add(IRCMessage(
      //   tags: {},
      //   command: Command.clearChat,
      //   user: null,
      //   message: 'Chat was cleared by a moderator',
      // ));
      return;
    }

    final bannedUser = ircMessage.message;
    final banDuration = ircMessage.tags['ban-duration'];

    messages.asMap().forEach((i, message) {
      if (message.user == bannedUser) {
        messages[i].command = Command.clearChat;

        if (banDuration != null) {
          messages[i].tags['ban-duration'] = banDuration;
        }
      }
    });
  }

  // Applies the given CLEARMSG message to a list and returns the result.
  static void clearMessage({required List<IRCMessage> messages, required IRCMessage ircMessage}) {
    // final targetUser = ircMessage.tags['login'];
    final targetId = ircMessage.tags['target-msg-id'];

    // Search for the message associated with the ID and indicate the the message was deleted.
    for (var i = 0; i < messages.length; i++) {
      if (messages[i].tags['id'] == targetId) {
        messages[i].command = Command.clearMessage;
        break;
      }
    }
  }

  static List<InlineSpan> generateSpan({required IRCMessage ircMessage, required assetToUrl}) {
    // Initialize the span list that will be used to render the chat message
    final span = <InlineSpan>[];

    final localAssetToUrl = <String, String>{};

    // Parse the message's 'emotes' tag if they exist and store them for later use.
    final emoteTags = ircMessage.tags['emotes'];
    if (emoteTags != null) {
      // Emotes and their indices are separated by '/' so split them there.
      final emotes = emoteTags.split('/');

      for (final emoteIdAndPosition in emotes) {
        final indexBetweenIdAndPositions = emoteIdAndPosition.indexOf(':');
        final emoteId = emoteIdAndPosition.substring(0, indexBetweenIdAndPositions);

        // Parse the range in order to extract the associated word.
        // If there are more than one indices, use the first one.
        // Else, use the one provided indices.
        final String range;
        if (emoteIdAndPosition.contains(',')) {
          range = emoteIdAndPosition.substring(indexBetweenIdAndPositions + 1, emoteIdAndPosition.indexOf(','));
        } else {
          range = emoteIdAndPosition.substring(indexBetweenIdAndPositions + 1);
        }

        // Extract the word associated with this emoteId by using the provided indices.
        final indexSplit = range.split('-');
        final startIndex = int.parse(indexSplit[0]);
        final endIndex = int.parse(indexSplit[1]);

        final emoteWord = ircMessage.message!.substring(startIndex, endIndex + 1);

        // Store the emote word and its associated URL for later use.
        localAssetToUrl[emoteWord] = 'https://static-cdn.jtvnw.net/emoticons/v2/$emoteId/default/dark/3.0';
      }
    }

    // Add any badges to the span.
    final badges = ircMessage.tags['badges'];
    if (badges != null) {
      for (final badge in badges.split(',')) {
        final badgeUrl = assetToUrl[badge];
        if (badgeUrl != null) {
          span.add(
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: CachedNetworkImage(
                imageUrl: badgeUrl,
                placeholder: (context, url) => const SizedBox(),
                fadeInDuration: const Duration(seconds: 0),
                height: 20,
              ),
            ),
          );
          span.add(const TextSpan(text: ' '));
        }
      }
    }

    // Add the username to the span.
    span.add(
      TextSpan(
        text: ircMessage.tags['display-name']!,
        style: TextStyle(
          color: HexColor.fromHex(ircMessage.tags['color'] ?? '#868686'),
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    // Add the colon separator between the username and their message to the span.
    span.add(
      const TextSpan(text: ':'),
    );

    // Add the message and any emotes to the span.
    final message = ircMessage.message;
    if (message != null) {
      final words = message.split(' ');
      for (final word in words) {
        span.add(const TextSpan(text: ' '));

        final emoteUrl = assetToUrl[word] ?? localAssetToUrl[word];
        if (emoteUrl != null) {
          span.add(
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: CachedNetworkImage(
                imageUrl: emoteUrl,
                placeholder: (context, url) => const SizedBox(),
                fadeInDuration: const Duration(seconds: 0),
                height: 25,
              ),
            ),
          );
        } else {
          span.add(TextSpan(text: word));
        }
      }
    }

    return span;
  }
}

enum Command {
  privateMessage,
  clearChat,
  clearMessage,
  userNotice,
  roomState,
  userState,
  globalUserState,
  none,
}

// https://stackoverflow.com/questions/50081213/how-do-i-use-hexadecimal-color-strings-in-flutter
extension HexColor on Color {
  /// String is in the format "aabbcc" or "ffaabbcc" with an optional leading "#".
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  /// Prefixes a hash sign if [leadingHashSign] is set to `true` (default is `true`).
  String toHex({bool leadingHashSign = true}) => '${leadingHashSign ? '#' : ''}'
      '${alpha.toRadixString(16).padLeft(2, '0')}'
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';
}
