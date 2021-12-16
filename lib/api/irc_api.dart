import 'package:flutter/material.dart';
import 'package:frosty/models/irc_message.dart';

class IRC {
  /// Returns a list of messages where the gievn CLEARCHAT message is applied.
  static List<IRCMessage> clearChat({required List<IRCMessage> messages, required IRCMessage ircMessage}) {
    // If there is no message, it means that entire chat was cleared.
    if (ircMessage.message == null) {
      messages.clear();
      messages.add(IRCMessage.createNotice(message: 'Chat was cleared by a moderator'));
      return messages;
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

    return messages;
  }

  /// Returns a list of messages where the gievn CLEARMSG message is applied.
  static List<IRCMessage> clearMessage({required List<IRCMessage> messages, required IRCMessage ircMessage}) {
    // final targetUser = ircMessage.tags['login'];
    final targetId = ircMessage.tags['target-msg-id'];

    // Search for the message associated with the ID and indicate the the message was deleted.
    for (var i = 0; i < messages.length; i++) {
      if (messages[i].tags['id'] == targetId) {
        messages[i].command = Command.clearMessage;
        break;
      }
    }

    return messages;
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
