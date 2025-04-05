import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/collection.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frosty/cache_manager.dart';
import 'package:frosty/constants.dart';
import 'package:frosty/models/badges.dart';
import 'package:frosty/models/emotes.dart';
import 'package:frosty/models/user.dart';
import 'package:frosty/screens/channel/chat/stores/chat_assets_store.dart';
import 'package:frosty/screens/settings/stores/settings_store.dart';
import 'package:frosty/utils.dart';
import 'package:frosty/widgets/cached_image.dart';
import 'package:frosty/widgets/photo_view.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

/// The object representation of a Twitch IRC message.
class IRCMessage {
  final String raw;
  Command command;
  final Map<String, String> tags;
  final String? user;
  final Map<String, Emote>? localEmotes;
  String? message;
  List<String>? split;
  bool? action;
  bool? mention;

  IRCMessage({
    required this.raw,
    required this.command,
    required this.tags,
    this.user,
    this.localEmotes,
    this.message,
    this.split,
    this.action,
    this.mention,
  });

  /// Applies the given CLEARCHAT message to the provided messages and buffer.
  static void clearChat({
    required List<IRCMessage> messages,
    required List<IRCMessage> bufferedMessages,
    required IRCMessage ircMessage,
  }) {
    // If there is no message, it means that entire chat was cleared.
    if (ircMessage.message == null) {
      messages.clear();
      bufferedMessages.clear();
      messages.add(
        IRCMessage.createNotice(message: 'Chat was cleared by a moderator'),
      );
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

    // Search the buffered messages for the banned/timed-out user.
    bufferedMessages.asMap().forEach((i, bufferedMessage) {
      if (bufferedMessage.user == bannedUser) {
        // Mark the message for removal.
        bufferedMessages[i].command = Command.clearChat;

        // If timed-out, indicate the duration.
        if (banDuration != null) {
          bufferedMessages[i].tags['ban-duration'] = banDuration;
        }
      }
    });
  }

  /// Applies the given CLEARMSG message to the provided messages and buffer.
  static void clearMessage({
    required List<IRCMessage> messages,
    required List<IRCMessage> bufferedMessages,
    required IRCMessage ircMessage,
  }) {
    final targetId = ircMessage.tags['target-msg-id'];

    // Search for the message associated with the ID and mark the message for deletion.
    for (var i = 0; i < messages.length; i++) {
      if (messages[i].tags['id'] == targetId) {
        messages[i].command = Command.clearMessage;
        break;
      }
    }

    // Search for the buffered message associated with the ID and mark the message for deletion.
    for (var i = 0; i < bufferedMessages.length; i++) {
      if (bufferedMessages[i].tags['id'] == targetId) {
        bufferedMessages[i].command = Command.clearMessage;
        break;
      }
    }
  }

  /// Returns an [InlineSpan] list that corresponds to the badges, username, words, and emotes of the given [IRCMessage].
  List<InlineSpan> generateSpan(
    BuildContext context, {
    TextStyle? style,
    required ChatAssetsStore assetsStore,
    required double badgeScale,
    required double emoteScale,
    required bool launchExternal,
    void Function()? onTapName,
    void Function(String)? onTapPingedUser,
    bool showMessage = true,
    bool useReadableColors = false,
    Map<String, UserTwitch>? channelIdToUserTwitch,
    TimestampType timestamp = TimestampType.disabled,
  }) {
    final isLightTheme = Theme.of(context).brightness == Brightness.light;

    final emoteToObject = assetsStore.emoteToObject;
    final twitchBadgeToObject = assetsStore.twitchBadgesToObject;
    final ffzUserToBadges = assetsStore.userToFFZBadges;
    final sevenTVUserToBadges = assetsStore.userTo7TVBadges;
    final bttvUserToBadge = assetsStore.userToBTTVBadges;
    final ffzRoomInfo = assetsStore.ffzRoomInfo;
    final badgeSize = defaultBadgeSize * badgeScale;
    final emoteSize = defaultEmoteSize * emoteScale;

    // The span list that will be used to render the chat message
    final span = <InlineSpan>[];

    if (timestamp != TimestampType.disabled) {
      final time = tags['tmi-sent-ts'] ??
          DateTime.now().millisecondsSinceEpoch.toString();
      final parsedTime = DateTime.fromMillisecondsSinceEpoch(int.parse(time));

      if (timestamp == TimestampType.twentyFour) {
        span.add(
          TextSpan(
            text: '${DateFormat.Hm().format(parsedTime)} ',
            style: style?.copyWith(
              color: style.color?.withValues(alpha: 0.5),
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        );
      }

      if (timestamp == TimestampType.twelve) {
        span.add(
          TextSpan(
            text: '${DateFormat('h:mm').format(parsedTime)} ',
            style: style?.copyWith(
              color: style.color?.withValues(alpha: 0.5),
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        );
      }
    }

    final isHistorical = tags['historical'] == '1';
    if (isHistorical) {
      span.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Tooltip(
            message: 'Historical message',
            preferBelow: false,
            triggerMode: TooltipTriggerMode.tap,
            child: Icon(Icons.history_rounded, size: badgeSize),
          ),
        ),
      );
      span.add(const TextSpan(text: ' '));
    }

    final sourceChannelId = tags['source-room-id'] ?? tags['room-id'];
    final sourceChannelUser = channelIdToUserTwitch != null
        ? channelIdToUserTwitch[sourceChannelId]
        : null;
    if (sourceChannelUser != null) {
      span.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Tooltip(
            triggerMode: TooltipTriggerMode.tap,
            preferBelow: false,
            message: 'Sent from ${sourceChannelUser.displayName}',
            child: CachedNetworkImage(
              cacheManager: CustomCacheManager.instance,
              imageUrl: sourceChannelUser.profileImageUrl,
              imageBuilder: (context, imageProvider) => Container(
                width: badgeSize,
                height: badgeSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image:
                      DecorationImage(image: imageProvider, fit: BoxFit.cover),
                ),
              ),
              placeholder: (context, url) => Container(
                width: badgeSize,
                height: badgeSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
        ),
      );
      span.add(const TextSpan(text: ' '));
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
          if (badgeInfo.name == 'Moderator' &&
              (ffzUserBadges != null || ffzRoomInfo?.modUrls != null)) {
            // Check if mod is bot.
            final botBadge = ffzUserBadges
                ?.firstWhereOrNull((element) => element.name == 'Bot');

            // Check if user has bot badge or room has custom FFZ mod badges
            if (botBadge != null) {
              badgeUrl = botBadge.url;
              skipBot = true;
            } else if (ffzRoomInfo?.modUrls != null) {
              badgeUrl = ffzRoomInfo!.modUrls?.url4x ??
                  ffzRoomInfo.modUrls?.url2x ??
                  ffzRoomInfo.modUrls!.url1x;
            }

            final newBadge = ChatBadge(
              name: skipBot ? 'Moderator (Bot)' : 'Moderator',
              url: badgeUrl,
              type: BadgeType.twitch,
            );

            span.add(
              _createBadgeSpan(
                context,
                badge: newBadge,
                size: badgeSize,
                backgroundColor: const Color(0xFF00AD03),
                launchExternal: launchExternal,
              ),
            );
            span.add(const TextSpan(text: ' '));
            continue;
          }

          // Add custom FFZ vip badge if it exists
          if (badgeInfo.name == 'VIP' && ffzRoomInfo?.vipBadge != null) {
            badgeUrl = ffzRoomInfo!.vipBadge?.url4x ??
                ffzRoomInfo.vipBadge?.url2x ??
                ffzRoomInfo.vipBadge!.url1x;
          }

          final newBadge = ChatBadge(
            name: badgeInfo.name,
            url: badgeUrl,
            type: BadgeType.twitch,
          );

          span.add(
            _createBadgeSpan(
              context,
              badge: newBadge,
              size: badgeSize,
              launchExternal: launchExternal,
            ),
          );
          span.add(const TextSpan(text: ' '));
        }
      }
    }

    // Add FFZ badges to span
    if (ffzUserBadges != null) {
      for (final badge in ffzUserBadges) {
        final color = Color(int.parse(badge.color!.replaceFirst('#', '0xFF')));

        if (badge.name == 'Bot') {
          if (!skipBot) {
            final indexToInsert = isHistorical ? 2 : 0;
            span.insert(
              indexToInsert,
              _createBadgeSpan(
                context,
                badge: badge,
                size: badgeSize,
                backgroundColor: color,
                launchExternal: launchExternal,
              ),
            );
            span.insert(indexToInsert + 1, const TextSpan(text: ' '));
          }
        } else {
          span.add(
            _createBadgeSpan(
              context,
              badge: badge,
              size: badgeSize,
              backgroundColor: color,
              launchExternal: launchExternal,
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
        _createBadgeSpan(
          context,
          badge: userBTTVBadge,
          size: badgeSize,
          isSvg: true,
          launchExternal: launchExternal,
        ),
      );
      span.add(const TextSpan(text: ' '));
    }

    // Add 7TV badges to end of badges span
    final user7TVBadges = sevenTVUserToBadges[tags['user-id']];
    if (user7TVBadges != null) {
      for (final badge in user7TVBadges) {
        span.add(
          _createBadgeSpan(
            context,
            badge: badge,
            size: badgeSize,
            launchExternal: launchExternal,
          ),
        );
        span.add(const TextSpan(text: ' '));
      }
    }

    var color = Color(
      int.parse((tags['color'] ?? '#868686').replaceFirst('#', '0xFF')),
    );

    if (useReadableColors) {
      final hsl = HSLColor.fromColor(color);
      if (isLightTheme == true) {
        if (hsl.lightness >= 0.5) {
          color = hsl
              .withLightness(hsl.lightness + ((0 - hsl.lightness) * 0.5))
              .toColor();
        }
      } else {
        if (hsl.lightness <= 0.5) {
          color = hsl
              .withLightness(hsl.lightness + ((1 - hsl.lightness) * 0.5))
              .toColor();
        }
      }
    }

    // Add the display name (username) to the span and apply the onLongPressName callback.
    final displayName = tags['display-name']!;
    span.add(
      TextSpan(
        text: user != null ? getReadableName(displayName, user!) : displayName,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
        ),
        recognizer: TapGestureRecognizer()..onTap = onTapName,
      ),
    );

    // Add the colon separator between the username and their message to the span.
    if (action == false) span.add(const TextSpan(text: ':'));

    // Italicize the text if it was called with an IRC Action (e.g., "/me").
    final textStyle =
        action == true ? const TextStyle(fontStyle: FontStyle.italic) : style;

    if (!showMessage) {
      span.add(const TextSpan(text: ' <message deleted>'));
    } else {
      // Check if the message is a reply. If it is, remove the reply username (first word) from the message.
      final words = tags.containsKey('reply-parent-display-name')
          ? split?.sublist(1)
          : split;

      // Add the message and any emotes to the span.
      if (words != null) {
        // Keep a local span which will be reversed and added to the final span.
        final localSpan = <InlineSpan>[];

        // Iterate through the words in reverse-order.
        // Index starts at the last word in the message.
        var index = words.length - 1;

        // Terminate after the first word in the message reached.
        while (index != -1) {
          // Check if current word is a valid emote.
          final word = words[index];
          final emote = emoteToObject[word] ?? localEmotes?[word];

          if (emote != null) {
            // If the emote is zero-width and not the first word, process the stack.
            if (emote.zeroWidth && index != 0) {
              final emoteStack = <Emote>[];

              // Handle stacking consecutive zero-width emotes.
              Emote? nextEmote = emote;
              while (nextEmote != null && nextEmote.zeroWidth && index != 0) {
                emoteStack.add(nextEmote);
                index--;
                nextEmote =
                    emoteToObject[words[index]] ?? localEmotes?[words[index]];
              }

              // If there's one more emote thats NOT zero-width, add it to the base of the stack.
              if (nextEmote != null) emoteStack.add(nextEmote);

              // Check if the next word is an emoji to be added to the stack.
              final nextWordIsEmoji = regexEmoji.hasMatch(words[index]);

              // Create the stack of emotes with the base emoji if there is one.
              // Will be used as the children of the Stack widget.
              final children = [
                if (nextWordIsEmoji)
                  Text(
                    words[index],
                    style: textStyle?.copyWith(fontSize: emoteSize - 5),
                  ),
                ...emoteStack.reversed.map(
                  (emote) => FrostyCachedNetworkImage(
                    imageUrl: emote.url,
                    height: emote.height != null
                        ? emote.height! * emoteScale
                        : emoteSize,
                    width: emote.width != null
                        ? emote.width! * emoteScale
                        : emoteSize,
                    useFade: false,
                  ),
                ),
              ];

              // Create the message for the tooltip
              final message = emoteStack.reversed.map(
                (emote) => emote.name,
              );
              final emoji = words[index];
              localSpan.add(
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: InkWell(
                    onTap: () => _showAssetDetailsBottomSheet(
                      context,
                      leading: Stack(
                        alignment: AlignmentDirectional.center,
                        children: [
                          if (nextWordIsEmoji)
                            Text(
                              emoji,
                              style: textStyle?.copyWith(fontSize: 40),
                            ),
                          ...emoteStack.reversed.map(
                            (emote) => FrostyCachedNetworkImage(
                              imageUrl: emote.url,
                              width: 56,
                            ),
                          ),
                        ],
                      ),
                      url: emoteStack.last.url,
                      title: nextWordIsEmoji
                          ? emoji
                          : '${emoteStack.last.name} (${emoteStack.last.type})',
                      subtitle: Text(
                        'with ${nextWordIsEmoji ? message.join(' + ') : message.skip(1).join(' + ')}',
                      ),
                      launchExternal: launchExternal,
                    ),
                    child: Stack(
                      alignment: AlignmentDirectional.center,
                      children: children,
                    ),
                  ),
                ),
              );

              // If the next word is neither an emote or emoji, add it as a text span.
              if (nextEmote == null && !nextWordIsEmoji) {
                localSpan.add(const TextSpan(text: ' '));
                localSpan.add(
                  _createTextSpan(
                    text: words[index],
                    style: textStyle,
                    launchExternal: launchExternal,
                    onTapPingedUser: onTapPingedUser,
                  ),
                );
              }
            } else {
              localSpan.add(
                _createEmoteSpan(
                  context,
                  emote: emote,
                  height: emote.height != null
                      ? emote.height! * emoteScale
                      : emoteSize,
                  width: emote.width != null ? emote.width! * emoteScale : null,
                  launchExternal: launchExternal,
                ),
              );
            }
          } else {
            if (regexEmoji.hasMatch(word)) {
              localSpan.add(
                _createEmojiSpan(
                  emoji: word,
                  style: textStyle?.copyWith(fontSize: emoteSize - 5),
                ),
              );
            } else {
              localSpan.add(
                _createTextSpan(
                  text: word,
                  style: textStyle,
                  launchExternal: launchExternal,
                  onTapPingedUser: onTapPingedUser,
                ),
              );
            }
          }

          localSpan.add(const TextSpan(text: ' '));
          index--;
        }

        // Add the the local span reversed to the final span.
        span.addAll(localSpan.reversed);
      }
    }

    return span;
  }

  static WidgetSpan _createEmojiSpan({
    required String emoji,
    TextStyle? style,
  }) {
    return WidgetSpan(
      alignment: PlaceholderAlignment.middle,
      child: Text(
        emoji,
        style: style,
      ),
    );
  }

  static Widget _createBadgeWidget({
    required ChatBadge badge,
    double? size,
    Color? backgroundColor,
    bool? isSvg,
  }) {
    if (backgroundColor != null) {
      return ColoredBox(
        color: backgroundColor,
        child: FrostyCachedNetworkImage(
          imageUrl: badge.url,
          height: size,
          width: size,
          useFade: false,
        ),
      );
    } else if (isSvg == true) {
      return SvgPicture.network(
        badge.url,
        height: size,
        width: size,
      );
    } else {
      return FrostyCachedNetworkImage(
        imageUrl: badge.url,
        height: size,
        width: size,
        useFade: false,
      );
    }
  }

  static WidgetSpan _createBadgeSpan(
    BuildContext context, {
    required ChatBadge badge,
    required double size,
    required bool launchExternal,
    Color? backgroundColor,
    bool? isSvg,
  }) {
    return WidgetSpan(
      alignment: PlaceholderAlignment.middle,
      child: InkWell(
        onTap: () => _showAssetDetailsBottomSheet(
          context,
          leading: _createBadgeWidget(
            badge: badge,
            backgroundColor: backgroundColor,
            isSvg: isSvg,
            size: 56,
          ),
          url: badge.url,
          title: badge.name,
          subtitle: Text(badge.type.toString()),
          launchExternal: launchExternal,
          showCopyName: false,
        ),
        child: _createBadgeWidget(
          badge: badge,
          size: size,
          backgroundColor: backgroundColor,
          isSvg: isSvg,
        ),
      ),
    );
  }

  static WidgetSpan _createEmoteSpan(
    BuildContext context, {
    required Emote emote,
    required double height,
    required double? width,
    required bool launchExternal,
  }) {
    return WidgetSpan(
      alignment: PlaceholderAlignment.middle,
      child: InkWell(
        onTap: () => showEmoteDetailsBottomSheet(
          context,
          emote: emote,
          launchExternal: launchExternal,
        ),
        child: FrostyCachedNetworkImage(
          imageUrl: emote.url,
          height: height,
          width: width,
          useFade: false,
          placeholder: (context, url) => const SizedBox(),
        ),
      ),
    );
  }

  static TextSpan _createTextSpan({
    required String text,
    required bool launchExternal,
    TextStyle? style,
    Function(String)? onTapPingedUser,
  }) {
    if (text.startsWith('@')) {
      return TextSpan(
        text: text,
        style: style?.copyWith(fontWeight: FontWeight.bold),
        recognizer: TapGestureRecognizer()
          ..onTap = () {
            if (onTapPingedUser != null) {
              onTapPingedUser(text.substring(1).split(',')[0]);
            }
          },
      );
    } else if (regexLink.hasMatch(text)) {
      return TextSpan(
        text: text,
        style: style?.copyWith(
          color: Colors.blue,
          decoration: TextDecoration.underline,
          decorationColor: Colors.blue,
        ),
        recognizer: TapGestureRecognizer()
          ..onTap = () => launchUrl(
                Uri.parse(text),
                mode: launchExternal
                    ? LaunchMode.externalApplication
                    : LaunchMode.inAppBrowserView,
              ),
      );
    } else {
      return TextSpan(text: text, style: style);
    }
  }

  static void showEmoteDetailsBottomSheet(
    BuildContext context, {
    required Emote emote,
    required bool launchExternal,
  }) {
    _showAssetDetailsBottomSheet(
      context,
      leading: FrostyCachedNetworkImage(
        imageUrl: emote.url,
        width: 56,
      ),
      url: emote.url,
      title: emote.realName != null
          ? '${emote.name} (${emote.realName})'
          : emote.name,
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emote.type.toString()),
          if (emote.ownerDisplayName != null && emote.ownerUsername != null)
            Text(
              'by ${getReadableName(emote.ownerDisplayName!, emote.ownerUsername!)}',
            ),
        ],
      ),
      launchExternal: launchExternal,
    );
  }

  static void _showAssetDetailsBottomSheet(
    BuildContext context, {
    required Widget leading,
    required String url,
    required String title,
    required Widget subtitle,
    required bool launchExternal,
    bool showCopyName = true,
  }) {
    showModalBottomSheet(
      context: context,
      builder: (context) => ListView(
        shrinkWrap: true,
        primary: false,
        children: [
          ListTile(
            leading: InkWell(
              onTap: () => showDialog(
                context: context,
                builder: (context) => FrostyPhotoViewDialog(imageUrl: url),
              ),
              child: leading,
            ),
            title: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: subtitle,
          ),
          if (showCopyName)
            ListTile(
              leading: const Icon(Icons.copy_rounded),
              title: const Text('Copy name'),
              onTap: () {
                Clipboard.setData(ClipboardData(text: title.split(' (')[0]));

                Navigator.pop(context);
              },
            ),
          ListTile(
            leading: const Icon(Icons.copy_rounded),
            title: const Text('Copy image URL'),
            onTap: () {
              Clipboard.setData(ClipboardData(text: url));

              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.launch_rounded),
            title: const Text('Open in browser'),
            onTap: () {
              launchUrl(
                Uri.parse(url),
                mode: launchExternal
                    ? LaunchMode.externalApplication
                    : LaunchMode.inAppBrowserView,
              );

              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
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
    final tags =
        whole.substring(1, tagAndIrcMessageDivider).replaceAll('\\s', ' ');

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
    final String? user = splitMessage[0] == 'tmi.twitch.tv'
        ? mappedTags['login']
        : splitMessage[0].substring(0, splitMessage[0].indexOf('!'));

    // If there is an associated message, set it.
    String? message;
    if (splitMessage.length > 3) {
      final combinedMessage = splitMessage.sublist(3).join(' ');

      if (combinedMessage.startsWith(':')) {
        message = combinedMessage.substring(1);
      } else {
        message = combinedMessage;
      }
    }

    // Now process any Twitch emotes contained in the message tags.
    // The map containing emotes from the user's tags to their URL.
    // This may include sub emotes that they can access but other users cannot.
    final localEmotes = <String, Emote>{};

    final emoteTags = mappedTags['emotes'];
    if (emoteTags != null && message != null) {
      // Emotes and their indices are separated by '/' so split them there.
      final emotes = emoteTags.split('/');

      for (final emoteIdAndPosition in emotes) {
        final indexBetweenIdAndPositions = emoteIdAndPosition.indexOf(':');
        final emoteId =
            emoteIdAndPosition.substring(0, indexBetweenIdAndPositions);

        // Parse the range in order to extract the associated word.
        // If there are more than one indices, use the first one.
        // Else, use the one provided indices.
        final String range;
        if (emoteIdAndPosition.contains(',')) {
          range = emoteIdAndPosition.substring(
            indexBetweenIdAndPositions + 1,
            emoteIdAndPosition.indexOf(','),
          );
        } else {
          range = emoteIdAndPosition.substring(indexBetweenIdAndPositions + 1);
        }

        // Extract the word associated with this emoteId by using the provided indices.
        final indexSplit = range.split('-');
        final startIndex = int.parse(indexSplit[0]);
        final endIndex = int.parse(indexSplit[1]);

        final emoteWord = message.substring(startIndex, endIndex + 1);

        // Store the emote word and its associated URL for later use.
        localEmotes[emoteWord] = Emote(
          name: emoteWord,
          zeroWidth: false,
          url:
              'https://static-cdn.jtvnw.net/emoticons/v2/$emoteId/default/dark/3.0',
          type: EmoteType.twitchSub,
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
      if (userLogin != null) {
        mention = message.toLowerCase().contains(userLogin);
      }

      // Escape the message
      message = message
          .split(' ')
          // Also remove any "INVALID/UNDEFINED" Unicode characters.
          // Rendering this character on iOS shows a question mark inside a square.
          // This character is used by some clients to bypass restrictions on repeating message.
          .map((word) => word.replaceAll('\u{E0000}', '').trim())
          .where((element) => element != '')
          .join(' ');

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

      if (wordBuffer.isNotEmpty) {
        split.addAll(
          wordBuffer.toString().split(' ').where((element) => element != ''),
        );
      }
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
      raw: whole,
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
        raw: '',
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
        raw: ircMessage.raw,
        color: ircMessage.tags['color'] ?? color,
        displayName: ircMessage.tags['display-name'] ?? displayName,
        mod: ircMessage.tags['mod'] == '0' ? false : true,
        subscriber: ircMessage.tags['subscriber'] == '0' ? false : true,
      );
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
