// ignore_for_file: non_constant_identifier_names

import 'package:flutter/foundation.dart';
import 'package:frosty/models/irc_message.dart';

class IRC {
  static IRCMessage parse(String whole) {
    // We have three parts:
    // 1. The tags of the IRC message
    // 2. The metadata (user, command, and channel)
    // 3. The message itself

    // First, slice the message tags (1) and set aside the rest for later.
    // Each part is separated by a space, so we'll start off by breaking off the tags and parsing them.

    // Obtain the index to break off the tags.
    final tagAndIrcMessageDivider = whole.indexOf(' ');

    // Get the tags substring and escape characters.
    // IRC messages escape spaces with \s.
    final tags = whole.substring(1, tagAndIrcMessageDivider).replaceAll('\\s', ' ');

    // Next, parse and map the tags.
    final mappedTags = <String, String>{};

    // Loop through each tag and store their key value pairs into the map.
    for (final tag in tags.split(';')) {
      // Skip if the tag has no value.
      if (tag.endsWith('=')) continue;

      final tagSplit = tag.split('=');
      mappedTags[tagSplit[0]] = tagSplit[1];
    }

    // Now we'll parse the message itself.
    // Obtain the entire substring after the tags and excluding the first : (colon)
    final ircMessage = whole.substring(tagAndIrcMessageDivider + 2);

    // Split each section of the message (part 2 and its subparts and part 3).
    // Index 0 contains the username of sender (user) or tmi.twitch.tv depending on the command
    // Index 1 is command type
    // Index 2 is #channel name that we are currently connected to
    // Index 3 and beyond is the :message (word by word) that is sent by the user or empty depending on the command
    final splitMessage = ircMessage.split(' ');

    // If the username exists, set it.
    final String? user = splitMessage[0] == 'tmi.twitch.tv' ? null : splitMessage[0].substring(0, splitMessage[0].indexOf('!'));

    // If there is a message, set it.
    final String? message = splitMessage.length > 3 ? splitMessage.sublist(3).join(' ').substring(1) : null;

    return IRCMessage(tags: mappedTags, command: splitMessage[1], user: user, message: message);
  }

  // Applies the given CLEARCHAT message to a list and returns the result.
  static List<IRCMessage> CLEARCHAT({required List<IRCMessage> messages, required IRCMessage ircMessage}) {
    debugPrint('CLEARCHAT');

    // If there is no message, it means that entire chat was cleared.
    if (ircMessage.message == null) {
      // messages.clear();
      return messages;
    }

    final bannedUser = ircMessage.message;
    final banDuration = ircMessage.tags['ban-duration'];

    // For each message of the user, indicate that they were either permanently banned or timed out.
    messages.asMap().forEach((i, message) {
      if (message.user! == bannedUser) {
        if (banDuration == null) {
          messages[i].message = '<user permabanned>';
        } else {
          messages[i].message = '<user timed out for $banDuration seconds>';
        }
      }
    });

    return messages;
  }

  // Applies the given CLEARMSG message to a list and returns the result.
  static List<IRCMessage> CLEARMSG({required List<IRCMessage> messages, required IRCMessage ircMessage}) {
    // final targetUser = ircMessage.tags['login'];
    final targetId = ircMessage.tags['target-msg-id'];

    // Search for the message associated with the ID and indicate the the message was deleted.
    for (var i = 0; i < messages.length; i++) {
      if (messages[i].tags['id'] == targetId) {
        messages[i].message = '<message deleted>';
        break;
      }
    }

    return messages;
  }

  static GLOBALUSERSTATE({required List<IRCMessage> messages, required IRCMessage ircMessage}) {
    debugPrint('GLOBALUSERSTATE');
  }

  static List<IRCMessage> PRIVMSG({required List<IRCMessage> messages, required IRCMessage ircMessage}) {
    messages.add(ircMessage);
    return messages;
  }

  static ROOMSTATE({required List<IRCMessage> messages, required IRCMessage ircMessage}) {
    debugPrint('ROOMSTATE');
  }

  static USERNOTICE({required List<IRCMessage> messages, required IRCMessage ircMessage}) {
    debugPrint('USERNOTICE');
  }

  static USERSTATE({required List<IRCMessage> messages, required IRCMessage ircMessage}) {
    debugPrint('USERSTATE');
  }
}
