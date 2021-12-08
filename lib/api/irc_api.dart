import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/widgets.dart';
import 'package:frosty/models/irc.dart';

class IRC {
  /// Applies the given CLEARCHAT message to the given list of messages.
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

    // Search the messages for the banned/timed-out user.
    messages.asMap().forEach((i, message) {
      if (message.user == bannedUser) {
        // Mark the message for removal.
        messages[i].command = Command.clearChat;

        // If timed-out, indicate the duration.
        if (banDuration != null) {
          messages[i].tags['ban-duration'] = banDuration;
        }
      }
    });
  }

  /// Applies the given CLEARMSG message to the given list of messages.
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

  /// Returns an [InlineSpan] list that corresponds to the badges, username, words, and emotes of the given [IRCMessage].
  static List<InlineSpan> generateSpan({required IRCMessage ircMessage, required Map<String, String> assetToUrl, bool hideMessage = false}) {
    // The span list that will be used to render the chat message
    final span = <InlineSpan>[];

    // The map containing emotes from the user's tags to their URL.
    // This may include sub emotes that they can access but other users cannot.
    final localEmoteToUrl = <String, String>{};

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
        localEmoteToUrl[emoteWord] = 'https://static-cdn.jtvnw.net/emoticons/v2/$emoteId/default/dark/3.0';
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

    if (hideMessage) {
      span.add(const TextSpan(text: ' <message deleted>'));
    } else {
      // Add the message and any emotes to the span.
      final message = ircMessage.message;
      if (message != null) {
        final words = message.split(' ');

        // Discard the last word if it is only the INVALID/UNDEFINED Unicode character.
        // Rendering this character on iOS shows a question mark inside a square.
        // This character is used by some clients to bypass restrictions on repeating message.
        if (words.last.contains('\u{E0000}')) words.removeLast();

        final buffer = StringBuffer();

        for (final word in words) {
          buffer.write(' ');

          final emoteUrl = assetToUrl[word] ?? localEmoteToUrl[word];
          if (emoteUrl != null) {
            span.add(TextSpan(text: buffer.toString()));

            buffer.clear();

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
            buffer.write(word);
          }
        }

        if (buffer.isNotEmpty) {
          span.add(TextSpan(text: buffer.toString()));
        }
      }
    }

    return span;
  }
}

/// The possible types of Twitch IRC commands.
enum Command {
  privateMessage,
  clearChat,
  clearMessage,
  notice,
  userNotice,
  roomState,
  userState,
  globalUserState,
  none,
}

/// https://stackoverflow.com/questions/50081213/how-do-i-use-hexadecimal-color-strings-in-flutter
extension HexColor on Color {
  /// String is in the format "aabbcc" or "ffaabbcc" with an optional leading "#".
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}
