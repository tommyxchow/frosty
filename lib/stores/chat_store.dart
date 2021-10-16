import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:frosty/api/bttv_api.dart';
import 'package:frosty/api/ffz_api.dart';
import 'package:frosty/api/irc_api.dart';
import 'package:frosty/api/seventv_api.dart';
import 'package:frosty/api/twitch_api.dart';
import 'package:frosty/models/irc_message.dart';
import 'package:frosty/stores/auth_store.dart';
import 'package:frosty/widgets/chat_message.dart';
import 'package:mobx/mobx.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

part 'chat_store.g.dart';

class ChatStore = _ChatStoreBase with _$ChatStore;

abstract class _ChatStoreBase with Store {
  final messages = <IrcMessage>[];

  final channel = WebSocketChannel.connect(Uri.parse('wss://irc-ws.chat.twitch.tv:443'));

  final _assetToUrl = <String, String>{};

  final _emoteIdToWord = <String, String>{};

  final String channelName;

  final AuthStore auth;

  final scrollController = ScrollController();

  @readonly
  var _autoScroll = true;

  _ChatStoreBase({required this.auth, required this.channelName}) {
    final commands = [
      'PASS oauth:${auth.token}',
      'NICK ${auth.isLoggedIn ? auth.user!.login : 'justinfan888'}',
      'CAP REQ :twitch.tv/tags',
      'CAP REQ :twitch.tv/commands',
      // 'CAP REQ :twitch.tv/membership',
      'CAP END',
      'JOIN #$channelName',
    ];

    for (final command in commands) {
      channel.sink.add(command);
    }

    scrollController.addListener(() {
      if (!scrollController.position.atEdge && scrollController.position.pixels < scrollController.position.maxScrollExtent) {
        _autoScroll = false;
      } else if (scrollController.position.atEdge && scrollController.position.pixels != scrollController.position.minScrollExtent) {
        _autoScroll = true;
      }
    });
  }

  @action
  Future<void> getAssets() async {
    final channelInfo = await Twitch.getUser(userLogin: channelName, headers: auth.headersTwitch);

    if (channelInfo != null) {
      final assets = [
        await FFZ.getEmotesGlobal(),
        await FFZ.getEmotesChannel(id: channelInfo.id),
        await BTTV.getEmotesGlobal(),
        await BTTV.getEmotesChannel(id: channelInfo.id),
        await Twitch.getEmotesGlobal(headers: auth.headersTwitch),
        await Twitch.getEmotesChannel(id: channelInfo.id, headers: auth.headersTwitch),
        await Twitch.getBadgesGlobal(headers: auth.headersTwitch),
        await Twitch.getBadgesChannel(id: channelInfo.id, headers: auth.headersTwitch),
        await SevenTV.getEmotesGlobal(),
        await SevenTV.getEmotesChannel(user: channelInfo.login)
      ];

      for (final map in assets) {
        if (map != null) {
          _assetToUrl.addAll(map);
        }
      }
    }
  }

  void handleWebsocketData(Object? data) {
    final ircMessages = data.toString();
    for (final message in ircMessages.substring(0, ircMessages.length - 2).split('\r\n')) {
      if (message.startsWith('@')) {
        final parsed = Irc.parse(message);

        switch (parsed.command) {
          case 'CLEARCHAT':
            clearChat(ircMessage: parsed);
            break;
          case 'CLEARMSG':
            break;
          case 'GLOBALUSERSTATE':
            break;
          case 'PRIVMSG':
            if (_autoScroll) {
              if (messages.length > 100) {
                messages.removeRange(0, messages.length - 100);
              }
              SchedulerBinding.instance?.addPostFrameCallback((_) {
                scrollController.jumpTo(scrollController.position.maxScrollExtent);
              });
            }
            messages.add(parsed);
            break;
          case 'ROOMSTATE':
            break;
          case 'USERNOTICE':
            break;
          case 'USERSTATE':
            break;
        }
      } else if (message.startsWith('P')) {
        channel.sink.add('PONG :tmi.twitch.tv');
      }
    }
  }

  void clearChat({required IrcMessage ircMessage}) {
    // If there is no message, it means that entire chat was cleared.
    if (ircMessage.message == null) {
      // messages.clear();
      messages[0].message = 'User was permabanned!';
      return;
    }

    final bannedUser = ircMessage.message;
    final banDuration = ircMessage.tags['ban-duration'];

    debugPrint('$bannedUser was banned');

    messages.asMap().forEach((i, message) {
      if (message.user! == bannedUser) {
        if (banDuration == null) {
          messages[i].message = 'User was permabanned!';
        } else {
          messages[i].message = 'User was timed out for $banDuration seconds!';
        }
      }
    });
  }

  ChatMessage renderChatMessage({required IrcMessage ircMessage}) {
    final result = <InlineSpan>[];

    final emoteTags = ircMessage.tags['emotes'];
    if (emoteTags != null) {
      final emotes = emoteTags.split('/');

      for (final emoteIdAndPosition in emotes) {
        final indexBetweenIdAndPositions = emoteIdAndPosition.indexOf(':');
        final emoteId = emoteIdAndPosition.substring(0, indexBetweenIdAndPositions);

        if (_emoteIdToWord[emoteId] != null) {
          continue;
        }

        final String range;
        if (emoteIdAndPosition.contains(',')) {
          range = emoteIdAndPosition.substring(indexBetweenIdAndPositions + 1, emoteIdAndPosition.indexOf(','));
        } else {
          range = emoteIdAndPosition.substring(indexBetweenIdAndPositions + 1);
        }

        final indexSplit = range.split('-');
        final startIndex = int.parse(indexSplit[0]);
        final endIndex = int.parse(indexSplit[1]);

        final emoteWord = ircMessage.message!.substring(startIndex, endIndex + 1);

        _emoteIdToWord[emoteId] = emoteWord;
        _assetToUrl[emoteWord] = 'https://static-cdn.jtvnw.net/emoticons/v2/$emoteId/default/dark/3.0';
      }
    }

    final words = ircMessage.message!.split(' ');
    final badges = ircMessage.tags['badges'];
    if (badges != null) {
      for (final badge in badges.split(',')) {
        final badgeUrl = _assetToUrl[badge];
        if (badgeUrl != null) {
          result.add(
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
          result.add(const TextSpan(text: ' '));
        }
      }
    }

    result.add(
      TextSpan(
        text: ircMessage.tags['display-name']!,
        style: TextStyle(
          color: HexColor.fromHex(ircMessage.tags['color'] ?? '#868686'),
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    result.add(
      const TextSpan(text: ':'),
    );

    for (final word in words) {
      final emoteUrl = _assetToUrl[word];
      if (emoteUrl != null) {
        result.add(const TextSpan(text: ' '));
        result.add(
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
        result.add(const TextSpan(text: ' '));
        result.add(TextSpan(text: word));
      }
    }

    return ChatMessage(
      key: Key(ircMessage.tags['id']!),
      children: result,
    );
  }

  @action
  void resumeScroll() {
    _autoScroll = true;
    scrollController.jumpTo(scrollController.position.maxScrollExtent);
    SchedulerBinding.instance?.addPostFrameCallback((_) {
      scrollController.jumpTo(scrollController.position.maxScrollExtent);
    });
  }
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
