import 'package:frosty/models/irc_message.dart';

class Irc {
  static IrcMessage parse(String whole) {
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

    return IrcMessage(tags: mappedTags, command: splitMessage[1], user: user, message: message);
  }

  static clearChat() {}

  static clearMsg() {}

  static globalUserState() {}

  static privmsg() {}

  static roomState() {}

  static userNotice() {}

  static userState() {}
}
