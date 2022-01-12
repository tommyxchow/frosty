import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/collection.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frosty/models/emotes.dart';
import 'package:frosty/screens/channel/stores/chat_assets_store.dart';
import 'package:frosty/screens/settings/stores/settings_store.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

/// The object representation of a Twitch IRC message.
class IRCMessage {
  Command command;
  final Map<String, String> tags;
  final String? user;
  final Map<String, Emote>? localEmotes;
  String? message;
  List<String>? split;
  bool? action;
  bool? mention;

  IRCMessage({
    required this.command,
    required this.tags,
    this.user,
    this.localEmotes,
    this.message,
    this.split,
    this.action,
    this.mention,
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
    required ChatAssetsStore assetsStore,
    required double badgeHeight,
    required double emoteHeight,
    bool showMessage = true,
    bool useZeroWidth = false,
    bool useReadableColors = false,
    bool? isLightTheme,
    TimestampType timestamp = TimestampType.disabled,
  }) {
    final emoteToObject = assetsStore.emoteToObject;
    final twitchBadgeToObject = assetsStore.twitchBadgesToObject;
    final ffzUserToBadges = assetsStore.userToFFZBadges;
    final sevenTVUserToBadges = assetsStore.userTo7TVBadges;
    final bttvUserToBadge = assetsStore.userToBTTVBadges;
    final ffzRoomInfo = assetsStore.ffzRoomInfo;

    // The span list that will be used to render the chat message
    final span = <InlineSpan>[];

    if (timestamp != TimestampType.disabled) {
      final time = tags['tmi-sent-ts'] ?? DateTime.now().millisecondsSinceEpoch.toString();
      final parsedTime = DateTime.fromMillisecondsSinceEpoch(int.parse(time));

      if (timestamp == TimestampType.twentyFour) {
        span.add(
          TextSpan(
            text: '${DateFormat.Hm().format(parsedTime)} ',
            style: style?.copyWith(color: style.color?.withOpacity(0.5)),
          ),
        );
      }

      if (timestamp == TimestampType.twelve) {
        span.add(
          TextSpan(
            text: '${DateFormat('h:mm').format(parsedTime)} ',
            style: style?.copyWith(color: style.color?.withOpacity(0.5)),
          ),
        );
      }
    }

    // Indicator to skip adding the bot badges later when adding the rest of FFZ badges.
    var skipBot = false;

    final ffzUserBadges = ffzUserToBadges[tags['user-id']];
    final twitchBadges = tags['badges']?.split(',');
    // Pasrse and add the Twitch badges to the span if they exist.
    if (twitchBadges != null) {
      for (final badge in twitchBadges) {
        final badgeInfo = twitchBadgeToObject[badge];
        if (badgeInfo != null) {
          var badgeUrl = badgeInfo.url;

          // Add custom FFZ mod badge if it exists.
          if (badgeInfo.name == 'Moderator' && (ffzUserBadges != null || ffzRoomInfo?.modUrls != null)) {
            // Check if mod is bot.
            final botBadge = ffzUserBadges?.firstWhereOrNull((element) => element.name == 'Bot');

            // Check if user has bot badge or room has custom FFZ mod badges
            if (botBadge != null) {
              badgeUrl = 'https:' + botBadge.url;
              skipBot = true;
            } else if (ffzRoomInfo?.modUrls != null) {
              badgeUrl = 'https:' + (ffzRoomInfo!.modUrls?.url4x ?? ffzRoomInfo.modUrls?.url2x ?? ffzRoomInfo.modUrls!.url1x);
            }

            span.add(
              _createEmoteSpan(
                emoteUrl: badgeUrl,
                tooltip: skipBot ? 'Moderator (Bot)' : 'Moderator',
                height: badgeHeight,
                backgroundColor: const Color(0xFF00AD03),
              ),
            );
            span.add(const TextSpan(text: ' '));
            continue;
          }

          // Add custom FFZ vip badge if it exists
          if (badgeInfo.name == 'VIP' && ffzRoomInfo?.vipBadge != null) {
            badgeUrl = 'https:' + (ffzRoomInfo!.vipBadge?.url4x ?? ffzRoomInfo.vipBadge?.url2x ?? ffzRoomInfo.vipBadge!.url1x);
          }

          span.add(
            _createEmoteSpan(
              emoteUrl: badgeUrl,
              tooltip: badgeInfo.name,
              height: badgeHeight,
            ),
          );
          span.add(const TextSpan(text: ' '));
        }
      }
    }

    // Add FFZ badges to span
    if (ffzUserBadges != null) {
      for (final badge in ffzUserBadges) {
        if (badge.name == 'Bot') {
          if (!skipBot) {
            span.insert(
              0,
              _createEmoteSpan(
                emoteUrl: 'https:' + badge.url,
                tooltip: badge.name,
                height: badgeHeight,
                backgroundColor: HexColor.fromHex(badge.color!),
              ),
            );
            span.add(const TextSpan(text: ' '));
          }
        } else {
          span.add(
            _createEmoteSpan(
              emoteUrl: 'https:' + badge.url,
              tooltip: badge.name,
              height: badgeHeight,
              backgroundColor: HexColor.fromHex(badge.color!),
            ),
          );
          span.add(const TextSpan(text: ' '));
        }
      }
    }

    // Add BTTV badges to span
    final userBTTVBadge = bttvUserToBadge[tags['user-id']];
    if (userBTTVBadge != null) {
      span.add(
        _createEmoteSpan(
          emoteUrl: userBTTVBadge.url,
          tooltip: userBTTVBadge.name,
          height: badgeHeight,
          isSvg: true,
        ),
      );
      span.add(const TextSpan(text: ' '));
    }

    // Add 7TV badges to end of badges span
    final user7TVBadges = sevenTVUserToBadges[tags['user-id']];
    if (user7TVBadges != null) {
      for (final badge in user7TVBadges) {
        span.add(
          _createEmoteSpan(
            emoteUrl: badge.url,
            tooltip: badge.name,
            height: badgeHeight,
          ),
        );
        span.add(const TextSpan(text: ' '));
      }
    }

    var color = HexColor.fromHex(tags['color'] ?? '#868686');

    if (useReadableColors) {
      final hsl = HSLColor.fromColor(color);
      if (isLightTheme == true) {
        if (hsl.lightness >= 0.5) color = hsl.withLightness(hsl.lightness + ((0 - hsl.lightness) * 0.5)).toColor();
      } else {
        if (hsl.lightness <= 0.5) color = hsl.withLightness(hsl.lightness + ((1 - hsl.lightness) * 0.5)).toColor();
      }
    }

    // Printing template for debugging purposes.
    // debugPrint('OLD - NAME: ${tags['display-name']!}, HUE: ${hsl.hue}, SATURATION: ${hsl.saturation}, LIGHNTESS: ${hsl.lightness}');
    // debugPrint('NEW - NAME: ${tags['display-name']!}, HUE: ${hsl.hue}, SATURATION: ${hsl.saturation}, LIGHNTESS: ${hsl.lightness}');

    span.add(
      TextSpan(
        text: tags['display-name']!,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    // Add the colon separator between the username and their message to the span.
    if (action == false) {
      span.add(const TextSpan(text: ':'));
    }

    // Italicize the text it was called with an IRC Action i.e., "/me".
    final textStyle = action == true ? const TextStyle(fontStyle: FontStyle.italic) : style;

    if (!showMessage) {
      span.add(const TextSpan(text: ' <message deleted>'));
    } else {
      // Add the message and any emotes to the span.
      final words = split;
      if (words != null) {
        if (useZeroWidth) {
          final localSpan = <InlineSpan>[];

          var index = words.length - 1;
          while (index != -1) {
            final word = words[index];
            final emote = emoteToObject[word] ?? localEmotes?[word];

            if (emote != null) {
              // Handle zero width emotes
              if (emote.zeroWidth && index != 0) {
                final emoteStack = <Emote>[];

                Emote? nextEmote = emote;
                while (nextEmote != null && nextEmote.zeroWidth && index != 0) {
                  emoteStack.add(nextEmote);
                  index--;
                  nextEmote = emoteToObject[words[index]] ?? localEmotes?[words[index]];
                }

                if (nextEmote != null) emoteStack.add(nextEmote);

                final message = emoteStack.reversed.map((emote) => emote.name).join(', ');
                final stack = emoteStack.reversed
                    .map((emote) => CachedNetworkImage(
                          imageUrl: emote.url,
                          placeholder: (context, url) => const SizedBox(),
                          fadeInDuration: const Duration(seconds: 0),
                          height: emoteHeight,
                        ))
                    .toList();

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
                        children: nextWordIsEmoji
                            ? [
                                Text(
                                  words[index],
                                  style: textStyle?.copyWith(fontSize: emoteHeight),
                                ),
                                ...stack
                              ]
                            : stack,
                      ),
                    ),
                  ),
                );

                if (nextEmote == null && !nextWordIsEmoji) {
                  localSpan.add(const TextSpan(text: ' '));
                  localSpan.add(_createTextSpan(text: words[index], style: textStyle));
                }
              } else {
                localSpan.add(
                  _createEmoteSpan(
                    emoteUrl: emote.url,
                    tooltip: emote.name,
                    height: emoteHeight,
                  ),
                );
              }
            } else {
              if (regexEmoji.hasMatch(word)) {
                localSpan.add(_createTextSpan(text: word, style: textStyle?.copyWith(fontSize: emoteHeight)));
              } else {
                localSpan.add(_createTextSpan(text: word, style: textStyle));
              }
            }
            localSpan.add(const TextSpan(text: ' '));
            index--;
          }
          span.addAll(localSpan.reversed);
        } else {
          for (final word in words) {
            span.add(const TextSpan(text: ' '));

            final emote = emoteToObject[word] ?? localEmotes?[word];
            if (emote != null) {
              span.add(
                _createEmoteSpan(
                  emoteUrl: emote.url,
                  tooltip: emote.name,
                  height: emoteHeight,
                ),
              );
            } else {
              if (regexEmoji.hasMatch(word)) {
                span.add(_createTextSpan(text: word, style: textStyle?.copyWith(fontSize: emoteHeight)));
              } else {
                span.add(_createTextSpan(text: word, style: textStyle));
              }
            }
          }
        }
      }
    }

    return span;
  }

  WidgetSpan _createEmoteSpan({
    required String emoteUrl,
    required String tooltip,
    required double height,
    Color? backgroundColor,
    bool? isSvg,
  }) {
    final Widget child;
    if (backgroundColor != null) {
      child = ColoredBox(
        color: backgroundColor,
        child: CachedNetworkImage(
          imageUrl: emoteUrl,
          placeholder: (context, url) => const SizedBox(),
          fadeInDuration: const Duration(seconds: 0),
          height: height,
        ),
      );
    } else if (isSvg == true) {
      child = SvgPicture.network(
        emoteUrl,
        placeholderBuilder: (context) => const SizedBox(),
        height: height,
      );
    } else {
      child = CachedNetworkImage(
        imageUrl: emoteUrl,
        placeholder: (context, url) => const SizedBox(),
        fadeInDuration: const Duration(seconds: 0),
        height: height,
      );
    }

    return WidgetSpan(
      alignment: PlaceholderAlignment.middle,
      child: Tooltip(
        message: tooltip,
        preferBelow: false,
        child: child,
      ),
    );
  }

  TextSpan _createTextSpan({required String text, TextStyle? style}) {
    if (text.startsWith('@')) {
      return TextSpan(text: text, style: style?.copyWith(fontWeight: FontWeight.bold));
    } else if (RegExp(r'https?:\/\/').hasMatch(text)) {
      return TextSpan(
        text: text,
        style: style?.copyWith(color: Colors.blue),
        recognizer: TapGestureRecognizer()
          ..onTap = () async {
            if (await canLaunch(text)) launch(text);
          },
      );
    } else {
      return TextSpan(text: text, style: style);
    }
  }

  /// Parses an IRC string and returns its corresponding [IRCMessage] object.
  factory IRCMessage.fromString(String whole, {String? userLogin}) {
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
    var message = splitMessage.length > 3 ? splitMessage.sublist(3).join(' ').substring(1) : null;

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
          name: emoteWord,
          zeroWidth: false,
          url: 'https://static-cdn.jtvnw.net/emoticons/v2/$emoteId/default/dark/3.0',
          type: EmoteType.bttvChannel,
        );
      }
    }

    var action = false;
    var mention = false;
    List<String>? split;
    if (message != null) {
      // Check if IRC actions like "/me" were called.
      if (message.startsWith('\x01') && message.endsWith('\x01')) {
        action = true;
        message = message.substring(8, message.length - 1);
      }

      // Check if the message mentions the logged-in user
      if (userLogin != null) mention = message.toLowerCase().contains(userLogin);

      // Escape the message
      message = message.split(' ').map((word) => word.replaceAll('\u{E0000}', '').trim()).where((element) => element != '').join(' ');

      final emojiBuffer = StringBuffer();
      final wordBuffer = StringBuffer();
      split = <String>[];

      for (final character in message.characters) {
        if (regexEmoji.hasMatch(character)) {
          if (wordBuffer.isNotEmpty) {
            split.addAll(wordBuffer.toString().split(' '));
            wordBuffer.clear();
          }
          emojiBuffer.write(character);
        } else {
          if (emojiBuffer.isNotEmpty) {
            split.add(emojiBuffer.toString());
            emojiBuffer.clear();
          }
          wordBuffer.write(character);
        }
      }

      if (wordBuffer.isNotEmpty) split.addAll(wordBuffer.toString().split(' ').where((element) => element != ''));
      if (emojiBuffer.isNotEmpty) split.add(emojiBuffer.toString());
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
      command: messageCommand,
      tags: mappedTags,
      user: user,
      localEmotes: localEmotes,
      message: message,
      split: split,
      action: action,
      mention: mention,
    );
  }

  factory IRCMessage.createNotice({required String message}) => IRCMessage(
        tags: {},
        command: Command.notice,
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

// Regex from dart_emoji package; used for emoji compatibility with zero-width
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
