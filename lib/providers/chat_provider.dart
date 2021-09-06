import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:frosty/constants.dart';
import 'package:frosty/models/channel.dart';
import 'package:frosty/utility/request.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ChatProvider extends ChangeNotifier {
  final Channel channelInfo;

  final channel = WebSocketChannel.connect(Uri.parse(twitchIrcUrl));
  final messages = <Widget>[];
  final scrollController = ScrollController();

  final _assetToUrl = <String, String>{};
  final _emoteIdToWord = <String, String>{};
  final _token = const String.fromEnvironment('TEST_TOKEN');

  ChatProvider({required this.channelInfo}) {
    final commands = [
      'PASS oauth:$_token',
      'NICK justinfan888',
      'CAP REQ :twitch.tv/tags',
      'CAP REQ :twitch.tv/commands',
      // 'CAP REQ :twitch.tv/membership',
      'CAP END',
      'JOIN #${channelInfo.userLogin}',
    ];

    for (final command in commands) {
      channel.sink.add(command);
    }
  }

  Future<void> getEmotes() async {
    final assets = [
      await Request.getEmotesBTTVGlobal(),
      await Request.getEmotesBTTVChannel(id: channelInfo.userId),
      await Request.getEmotesFFZGlobal(),
      await Request.getEmotesFFZChannel(id: channelInfo.userId),
      await Request.getEmotesTwitchGlobal(token: _token),
      await Request.getEmotesTwitchChannel(token: _token, id: channelInfo.userId),
      await Request.getBadgesTwitchGlobal(token: _token),
      await Request.getBadgesTwitchChannel(token: _token, id: channelInfo.userId),
      await Request.getEmotes7TVGlobal(),
      await Request.getEmotes7TVChannel(user: channelInfo.userLogin)
    ];

    for (final map in assets) {
      if (map != null) {
        _assetToUrl.addAll(map);
      }
    }
  }

  List<InlineSpan> parseIrcMessage(String whole) {
    var mappedTags = <String, String>{};

    final tagAndIrcMessageDivider = whole.indexOf(' ');
    final tags = whole.substring(1, tagAndIrcMessageDivider).replaceAll('\\s', ' ');
    final ircMessage = whole.substring(tagAndIrcMessageDivider + 2);

    for (final tag in tags.split(';')) {
      if (!tag.endsWith('=')) {
        final tagSplit = tag.split('=');
        mappedTags[tagSplit[0]] = tagSplit[1];
      }
    }

    final splitMessage = ircMessage.split(' ');

    // final user = splitMessage[0].substring(0, splitMessage[0].indexOf('!'));
    // print(user);

    final command = splitMessage[1];

    switch (command) {
      case 'CLEARCHAT':
        break;
      case 'CLEARMSG':
        break;
      case 'GLOBALUSERSTATE':
        break;
      case 'PRIVMSG':
        final message = splitMessage.sublist(3).join(' ').substring(1);
        return privateMessage(tags: mappedTags, chatMessage: message);
      case 'ROOMSTATE':
        break;
      case 'USERNOTICE':
        break;
      case 'USERSTATE':
        break;
    }
    return [];
  }

  List<InlineSpan> privateMessage({required Map<String, String> tags, required String chatMessage}) {
    var result = <InlineSpan>[];

    final emoteTags = tags['emotes'];
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

        final emoteWord = chatMessage.substring(startIndex, endIndex + 1);

        _emoteIdToWord[emoteId] = emoteWord;
        _assetToUrl[emoteWord] = 'https://static-cdn.jtvnw.net/emoticons/v2/$emoteId/default/dark/3.0';
      }
    }

    final words = chatMessage.split(' ');
    final badges = tags['badges'];
    if (badges != null) {
      for (final badge in badges.split(',')) {
        final badgeUrl = _assetToUrl[badge];
        if (badgeUrl != null) {
          result.add(
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Image.network(
                badgeUrl,
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
        text: tags['display-name']!,
        style: TextStyle(
          color: HexColor.fromHex(tags['color'] ?? '#868686'),
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
            child: Image.network(
              emoteUrl,
              height: 25,
            ),
          ),
        );
      } else {
        result.add(const TextSpan(text: ' '));
        result.add(TextSpan(text: word));
      }
    }
    return result;
  }

  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
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
