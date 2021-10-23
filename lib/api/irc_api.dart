import 'package:flutter/foundation.dart';
import 'package:frosty/models/irc.dart';

class IRC {
  // Applies the given CLEARCHAT message to a list and returns the result.
  static void clearChat({required List<IRCMessage> messages, required IRCMessage ircMessage}) {
    debugPrint('CLEARCHAT');

    // If there is no message, it means that entire chat was cleared.
    if (ircMessage.message == null) {
      // messages.clear();
      return;
    }

    final bannedUser = ircMessage.message;
    final banDuration = ircMessage.tags['ban-duration'];

    messages.asMap().forEach((i, message) {
      if (message.user == bannedUser) {
        messages[i].command = 'CLEARCHAT';

        if (banDuration != null) {
          messages[i].tags['ban-duration'] = banDuration;
        }
      }
    });
  }

  // Applies the given CLEARMSG message to a list and returns the result.
  static void clearMsg({required List<IRCMessage> messages, required IRCMessage ircMessage}) {
    // final targetUser = ircMessage.tags['login'];
    final targetId = ircMessage.tags['target-msg-id'];

    // Search for the message associated with the ID and indicate the the message was deleted.
    for (var i = 0; i < messages.length; i++) {
      if (messages[i].tags['id'] == targetId) {
        messages[i].command = 'CLEARMSG';
        break;
      }
    }
  }

  static void userNotice({required List<IRCMessage> messages, required IRCMessage ircMessage}) {
    debugPrint('USERNOTICE');
  }
}
