import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:frosty/models/badges.dart';
import 'package:frosty/models/emotes.dart';
import 'package:intl/intl.dart';

/// The object representation of a Twitch IRC message.
class IRCMessage {
  final String raw;
  final bool action;
  final Map<String, String> tags;
  final String? user;
  final Map<String, Emote> localEmotes;
  Command command;
  String? message;

  IRCMessage({
    required this.raw,
    required this.action,
    required this.tags,
    required this.command,
    required this.user,
    required this.localEmotes,
    required this.message,
  });

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
    final targetId = ircMessage.tags['target-msg-id'];

    // Search for the message associated with the ID and mark the message for deletion.
    for (var i = 0; i < messages.length; i++) {
      if (messages[i].tags['id'] == targetId) {
        messages[i].command = Command.clearMessage;
        break;
      }
    }

    return messages;
  }

  /// Returns an [InlineSpan] list that corresponds to the badges, username, words, and emotes of the given [IRCMessage].
  List<InlineSpan> generateSpan({
    required TextStyle? style,
    required Map<String, Emote> emoteToObject,
    required Map<String, BadgeInfoTwitch> twitchBadgeToObject,
    required Map<String, List<BadgeInfoFFZ>> ffzUserToBadges,
    required Map<String, List<BadgeInfo7TV>> sevenTVUserToBadges,
    RoomFFZ? ffzRoomInfo,
    bool hideMessage = false,
    bool zeroWidthEnabled = false,
    Timestamp timestamp = Timestamp.none,
  }) {
    // The span list that will be used to render the chat message
    final span = <InlineSpan>[];

    if (timestamp != Timestamp.none) {
      final time = tags['tmi-sent-ts'] ?? DateTime.now().millisecondsSinceEpoch.toString();
      final parsedTime = DateTime.fromMillisecondsSinceEpoch(int.parse(time));

      if (timestamp == Timestamp.twentyFour) {
        span.add(
          TextSpan(
            text: '${DateFormat.Hm().format(parsedTime)} ',
            style: style?.copyWith(color: style.color?.withOpacity(0.5)),
          ),
        );
      }

      if (timestamp == Timestamp.twelve) {
        span.add(
          TextSpan(
            text: '${DateFormat('h:mm').format(parsedTime)} ',
            style: style?.copyWith(color: style.color?.withOpacity(0.5)),
          ),
        );
      }
    }

    // Add any badges to the span.
    // mod/bot/vip -> developer -> supporter -> twitch
    var skipMod = false;
    var skipVip = false;

    final twitchBadges = tags['badges']?.split(',');
    final ffzUserBadges = ffzUserToBadges[tags['user-id']];

    // If there are FFZ badges for the user, parse them first.
    // Bot and vip/mod badges come first, and bot badges replace mod badges.
    if (ffzUserBadges != null) {
      var skipBot = false;

      var isMod = false;
      var isVip = false;

      BadgeInfoFFZ? botBadge;

      if (twitchBadges != null) {
        isMod = twitchBadges.contains('moderator/1');
        isVip = twitchBadges.contains('vip/1');

        botBadge = ffzUserBadges.firstWhereOrNull((element) => element.id == 2);
      }

      // If there is a VIP badge, add it.
      if (isVip) {
        // Mark vip badges for skip so that when parsing the Twitch badges later they won't appear twice.
        skipVip = true;

        String? vipBadgeUrl;
        if (ffzRoomInfo != null && ffzRoomInfo.vipBadge != null) {
          vipBadgeUrl = 'https:' + (ffzRoomInfo.vipBadge?.url4x ?? ffzRoomInfo.vipBadge?.url2x ?? ffzRoomInfo.vipBadge!.url1x);
        } else {
          vipBadgeUrl = twitchBadgeToObject['vip/1']?.imageUrl4x;
        }

        if (vipBadgeUrl != null) {
          span.add(
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Tooltip(
                message: 'VIP',
                preferBelow: false,
                child: CachedNetworkImage(
                  imageUrl: vipBadgeUrl,
                  placeholder: (context, url) => const SizedBox(),
                  fadeInDuration: const Duration(seconds: 0),
                  height: 20,
                ),
              ),
            ),
          );
          span.add(const TextSpan(text: ' '));
        }
      }

      if (isMod) {
        skipMod = true;

        String? modBadgeUrl;

        // If user is a mod but a bot, use the bot badge.
        // Otherwise, use the channel's custom mod badge if it exists.
        // Else, use the default Twitch mod badge if no custom badge exists.
        if (botBadge != null) {
          skipBot = true;
          modBadgeUrl = 'https:' + botBadge.urls.url4x;
        } else if (ffzRoomInfo != null && ffzRoomInfo.modUrls != null) {
          modBadgeUrl = 'https:' + (ffzRoomInfo.modUrls?.url4x ?? ffzRoomInfo.modUrls?.url2x ?? ffzRoomInfo.modUrls!.url1x);
        } else {
          modBadgeUrl = twitchBadgeToObject['moderator/1']?.imageUrl4x;
        }

        if (modBadgeUrl != null) {
          span.add(
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Tooltip(
                message: botBadge != null ? 'Moderator (Bot)' : 'Moderator',
                preferBelow: false,
                child: ColoredBox(
                  color: const Color(0xFF00AD03),
                  child: CachedNetworkImage(
                    imageUrl: modBadgeUrl,
                    placeholder: (context, url) => const SizedBox(),
                    fadeInDuration: const Duration(seconds: 0),
                    height: 20,
                  ),
                ),
              ),
            ),
          );
          span.add(const TextSpan(text: ' '));
        }
      }

      // Add the rest of the FFZ badges that the user has.
      for (final ffzBadge in ffzUserBadges) {
        // Skip the bot badge if already accounted for previously by the moderator+bot badge.
        if (ffzBadge.id == 2 && skipBot) continue;
        span.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Tooltip(
              message: ffzBadge.title,
              preferBelow: false,
              child: ColoredBox(
                color: HexColor.fromHex(ffzBadge.color),
                child: CachedNetworkImage(
                  imageUrl: 'https:' + ffzBadge.urls.url4x,
                  placeholder: (context, url) => const SizedBox(),
                  fadeInDuration: const Duration(seconds: 0),
                  height: 20,
                ),
              ),
            ),
          ),
        );
        span.add(const TextSpan(text: ' '));
      }
    }

    // Pasrse and add the Twitch badges to the span if they exist.
    if (twitchBadges != null) {
      for (final badge in twitchBadges) {
        final badgeInfo = twitchBadgeToObject[badge];
        if (badgeInfo != null) {
          var badgeUrl = badgeInfo.imageUrl4x;

          // Add custom FFZ mod badge if it exists
          if (badgeInfo.title == 'Moderator') {
            // If the mod badge was already accounted for in the earler FFZ badge check, skip.
            if (skipMod) continue;
            if (ffzRoomInfo != null && ffzRoomInfo.modUrls != null) {
              span.add(
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: Tooltip(
                    message: 'Moderator',
                    preferBelow: false,
                    child: ColoredBox(
                      color: const Color(0xFF00AD03),
                      child: CachedNetworkImage(
                        imageUrl: 'https:' + (ffzRoomInfo.modUrls?.url4x ?? ffzRoomInfo.modUrls?.url2x ?? ffzRoomInfo.modUrls!.url1x),
                        placeholder: (context, url) => const SizedBox(),
                        fadeInDuration: const Duration(seconds: 0),
                        height: 20,
                      ),
                    ),
                  ),
                ),
              );
              span.add(const TextSpan(text: ' '));
              continue;
            }
          }

          // Add custom FFZ vip badge if it exists
          if (badgeInfo.title == 'VIP') {
            // If the vip badge was already accounted for in the earler FFZ badge check, skip.
            if (skipVip) continue;
            if (ffzRoomInfo != null && ffzRoomInfo.vipBadge != null) {
              badgeUrl = 'https:' + (ffzRoomInfo.vipBadge?.url4x ?? ffzRoomInfo.vipBadge?.url2x ?? ffzRoomInfo.vipBadge!.url1x);
            }
          }

          span.add(
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Tooltip(
                message: badgeInfo.title,
                preferBelow: false,
                child: CachedNetworkImage(
                  imageUrl: badgeUrl,
                  placeholder: (context, url) => const SizedBox(),
                  fadeInDuration: const Duration(seconds: 0),
                  height: 20,
                ),
              ),
            ),
          );
          span.add(const TextSpan(text: ' '));
        }
      }
    }

    // Add 7TV badges to end of badges span
    final user7TVBadges = sevenTVUserToBadges[tags['user-id']];
    if (user7TVBadges != null) {
      for (final badge in user7TVBadges) {
        span.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Tooltip(
              message: badge.tooltip,
              preferBelow: false,
              child: CachedNetworkImage(
                imageUrl: badge.urls[2][1],
                placeholder: (context, url) => const SizedBox(),
                fadeInDuration: const Duration(seconds: 0),
                height: 20,
              ),
            ),
          ),
        );
        span.add(const TextSpan(text: ' '));
      }
    }

    // Add the username to the span.
    span.add(
      TextSpan(
        text: tags['display-name']!,
        style: TextStyle(
          color: HexColor.fromHex(tags['color'] ?? '#868686'),
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    // Add the colon separator between the username and their message to the span.
    span.add(
      const TextSpan(text: ':'),
    );

    // Italicize the text it was called with an IRC Action i.e., "/me".
    final textStyle = action == true ? const TextStyle(fontStyle: FontStyle.italic) : null;

    if (hideMessage) {
      span.add(const TextSpan(text: ' <message deleted>'));
    } else {
      // Add the message and any emotes to the span.
      final chatMessage = message;
      if (chatMessage != null) {
        final words = chatMessage.split(' ');
        words.removeWhere((element) => element == '');

        if (zeroWidthEnabled) {
          final localSpan = <InlineSpan>[];

          var index = words.length - 1;
          while (index != -1) {
            final word = words[index];
            final emote = emoteToObject[word] ?? localEmotes[word];

            if (emote != null) {
              // Handle zero width emotes
              if (emote.zeroWidth && index != 0) {
                final emoteStack = <Emote>[];

                var nextEmote = emoteToObject[word];
                while (nextEmote != null && nextEmote.zeroWidth && index != 0) {
                  emoteStack.add(nextEmote);
                  index--;
                  nextEmote = emoteToObject[words[index]];
                }

                if (nextEmote != null) emoteStack.add(nextEmote);

                final message = emoteStack.reversed.map((emote) => emote.name).join(', ');
                final stack = emoteStack.reversed
                    .map((emote) => CachedNetworkImage(
                          imageUrl: emote.url,
                          placeholder: (context, url) => const SizedBox(),
                          fadeInDuration: const Duration(seconds: 0),
                          height: 30,
                        ))
                    .toList();

                // Regex from dart_emoji package
                final regexEmoji = RegExp(
                  r'[\u{1f300}-\u{1f5ff}\u{1f900}-\u{1f9ff}\u{1f600}-\u{1f64f}'
                  r'\u{1f680}-\u{1f6ff}\u{2600}-\u{26ff}\u{2700}'
                  r'-\u{27bf}\u{1f1e6}-\u{1f1ff}\u{1f191}-\u{1f251}'
                  r'\u{1f004}\u{1f0cf}\u{1f170}-\u{1f171}\u{1f17e}'
                  r'-\u{1f17f}\u{1f18e}\u{3030}\u{2b50}\u{2b55}'
                  r'\u{2934}-\u{2935}\u{2b05}-\u{2b07}\u{2b1b}'
                  r'-\u{2b1c}\u{3297}\u{3299}\u{303d}\u{00a9}'
                  r'\u{00ae}\u{2122}\u{23f3}\u{24c2}\u{23e9}'
                  r'-\u{23ef}\u{25b6}\u{23f8}-\u{23fa}\u{200d}]+',
                  unicode: true,
                );

                var nextWordIsEmoji = false;
                if (regexEmoji.hasMatch(words[index])) nextWordIsEmoji = true;

                localSpan.add(
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: Tooltip(
                      message: nextWordIsEmoji ? words[index] + ', ' + message : message,
                      preferBelow: false,
                      child: Stack(
                        alignment: AlignmentDirectional.center,
                        children: nextWordIsEmoji ? [Text(words[index]), ...stack] : stack,
                      ),
                    ),
                  ),
                );

                if (nextEmote == null && !nextWordIsEmoji) {
                  localSpan.add(const TextSpan(text: ' '));
                  localSpan.add(TextSpan(text: words[index], style: textStyle));
                }
              } else {
                localSpan.add(
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: Tooltip(
                      message: emote.name,
                      preferBelow: false,
                      child: CachedNetworkImage(
                        imageUrl: emote.url,
                        placeholder: (context, url) => const SizedBox(),
                        fadeInDuration: const Duration(seconds: 0),
                        height: 30,
                      ),
                    ),
                  ),
                );
              }
            } else {
              localSpan.add(TextSpan(text: word, style: textStyle));
            }
            localSpan.add(const TextSpan(text: ' '));
            index--;
          }
          span.addAll(localSpan.reversed);
        } else {
          // Use a string buffer to minimize TextSpan widgets.
          // Instead of one TextSpan widget per word, we can have one TextSpan widget across multiple.
          final buffer = StringBuffer();

          for (final word in words) {
            buffer.write(' ');

            final emote = emoteToObject[word] ?? localEmotes[word];
            if (emote != null) {
              span.add(TextSpan(text: buffer.toString(), style: textStyle));

              buffer.clear();

              span.add(
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: Tooltip(
                    message: emote.name,
                    preferBelow: false,
                    child: CachedNetworkImage(
                      imageUrl: emote.url,
                      placeholder: (context, url) => const SizedBox(),
                      fadeInDuration: const Duration(seconds: 0),
                      height: 30,
                    ),
                  ),
                ),
              );
            } else {
              buffer.write(word);
            }
          }

          if (buffer.isNotEmpty) {
            span.add(TextSpan(text: buffer.toString(), style: textStyle));
          }
        }
      }
    }

    return span;
  }

  /// Parses an IRC string and returns its corresponding [IRCMessage] object.
  factory IRCMessage.fromString(String whole) {
    // We have three parts:
    // 1. The tags of the IRC message.
    // 2. The metadata (user, command, and channel).
    // 3. The message itself.

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
    // tmi.twitch.tv means the message was sent by Twitch rather than a user, so will be irrelevant.
    final String? user = splitMessage[0] == 'tmi.twitch.tv' ? null : splitMessage[0].substring(0, splitMessage[0].indexOf('!'));

    // If there is an associated message, set it.
    //
    // Also remove any "INVALID/UNDEFINED" Unicode characters.
    // Rendering this character on iOS shows a question mark inside a square.
    // This character is used by some clients to bypass restrictions on repeating message.
    var message = splitMessage.length > 3 ? splitMessage.sublist(3).join(' ').substring(1).replaceAll('\u{E0000}', '').trim() : null;

    // Check if IRC actions like "/me" were called.
    var action = false;
    if (message != null && message.startsWith('\x01') && message.endsWith('\x01')) {
      action = true;
      message = message.substring(8, message.length - 1);
    }

    // Now process any Twitch emotes contained in the message tags.
    // The map containing emotes from the user's tags to their URL.
    // This may include sub emotes that they can access but other users cannot.
    final localEmotes = <String, Emote>{};

    final emoteTags = mappedTags['emotes'];
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

        final emoteWord = message!.substring(startIndex, endIndex + 1);

        // Store the emote word and its associated URL for later use.
        localEmotes[emoteWord] = Emote(
          id: emoteId,
          name: emoteWord,
          zeroWidth: false,
          url: 'https://static-cdn.jtvnw.net/emoticons/v2/$emoteId/default/dark/3.0',
          type: EmoteType.bttvChannel,
        );
      }
    }

    // Check and parse the command.
    // The majority of messages will be PRIVMSG, so check that first.
    final Command messageCommand;
    switch (splitMessage[1]) {
      case 'PRIVMSG':
        messageCommand = Command.privateMessage;
        break;
      case 'CLEARCHAT':
        messageCommand = Command.clearChat;
        break;
      case 'CLEARMSG':
        messageCommand = Command.clearMessage;
        break;
      case 'NOTICE':
        messageCommand = Command.notice;
        break;
      case 'USERNOTICE':
        messageCommand = Command.userNotice;
        break;
      case 'ROOMSTATE':
        messageCommand = Command.roomState;
        break;
      case 'USERSTATE':
        messageCommand = Command.userState;
        break;
      case 'GLOBALUSERSTATE':
        messageCommand = Command.globalUserState;
        break;
      default:
        debugPrint('Unknown command: $splitMessage[1]');
        messageCommand = Command.none;
    }

    return IRCMessage(
      raw: whole,
      action: action,
      tags: mappedTags,
      command: messageCommand,
      localEmotes: localEmotes,
      user: user,
      message: message,
    );
  }

  factory IRCMessage.createNotice({required String message}) => IRCMessage(
        raw: '',
        action: false,
        tags: {},
        localEmotes: {},
        command: Command.notice,
        user: null,
        message: message,
      );
}

/// The object representation of the IRC ROOMSTATE message.
class ROOMSTATE {
  final String emoteOnly;
  final String followersOnly;
  final String r9k;
  final String slowMode;
  final String subMode;

  const ROOMSTATE({
    this.emoteOnly = '0',
    this.followersOnly = '-1',
    this.r9k = '0',
    this.slowMode = '0',
    this.subMode = '0',
  });

  /// Create a new copy with the parameters from the provided [IRCMessage]
  ROOMSTATE fromIRCMessage(IRCMessage ircMessage) => ROOMSTATE(
        emoteOnly: ircMessage.tags['emote-only'] ?? emoteOnly,
        followersOnly: ircMessage.tags['followers-only'] ?? followersOnly,
        r9k: ircMessage.tags['r9k'] ?? r9k,
        slowMode: ircMessage.tags['slow'] ?? slowMode,
        subMode: ircMessage.tags['subs-only'] ?? subMode,
      );
}

class USERSTATE {
  final String? raw;
  final String color;
  final String displayName;
  final bool mod;
  final bool subscriber;

  const USERSTATE({
    this.raw,
    this.color = '',
    this.displayName = '',
    this.mod = false,
    this.subscriber = false,
  });

  USERSTATE fromIRCMessage(IRCMessage ircMessage) => USERSTATE(
        raw: ircMessage.raw,
        color: ircMessage.tags['color'] ?? color,
        displayName: ircMessage.tags['display-name'] ?? displayName,
        mod: ircMessage.tags['mod'] == '0' ? false : true,
        subscriber: ircMessage.tags['subscriber'] == '0' ? false : true,
      );
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

enum Timestamp {
  none,
  twelve,
  twentyFour,
}
