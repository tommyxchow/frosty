import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frosty/apis/base_api_client.dart';
import 'package:frosty/apis/bttv_api.dart';
import 'package:frosty/models/emotes.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

import '../fixtures/api_responses.dart';

void main() {
  late Dio dio;
  late DioAdapter dioAdapter;
  late BTTVApi api;

  setUp(() {
    dio = Dio(BaseOptions());
    dioAdapter = DioAdapter(dio: dio);
    api = BTTVApi(dio);
  });

  group('getEmotesGlobal', () {
    test('returns list of global BTTV emotes', () async {
      dioAdapter.onGet(
        'https://api.betterttv.net/3/cached/emotes/global',
        (server) => server.reply(200, bttvEmotesGlobalResponse),
      );

      final emotes = await api.getEmotesGlobal();

      expect(emotes, hasLength(2));
      expect(emotes[0].name, 'SourPls');
      expect(emotes[0].type, EmoteType.bttvGlobal);
      expect(emotes[0].url, contains('bttv1'));
      expect(emotes[1].name, 'catJAM');
    });

    test('returns empty list for empty response', () async {
      dioAdapter.onGet(
        'https://api.betterttv.net/3/cached/emotes/global',
        (server) => server.reply(200, <dynamic>[]),
      );

      final emotes = await api.getEmotesGlobal();

      expect(emotes, isEmpty);
    });
  });

  group('getEmotesChannel', () {
    test('combines channel and shared emotes', () async {
      dioAdapter.onGet(
        'https://api.betterttv.net/3/cached/users/twitch/12345',
        (server) => server.reply(200, bttvEmotesChannelResponse),
      );

      final emotes = await api.getEmotesChannel(id: '12345');

      expect(emotes, hasLength(3));
      expect(emotes[0].name, 'ChannelEmote');
      expect(emotes[0].type, EmoteType.bttvChannel);
      expect(emotes[1].name, 'SharedEmote');
      expect(emotes[1].type, EmoteType.bttvShared);
      expect(emotes[2].name, 'SharedEmote2');
      expect(emotes[2].type, EmoteType.bttvShared);
    });

    test('throws on 404 for unknown channel', () {
      dioAdapter.onGet(
        'https://api.betterttv.net/3/cached/users/twitch/99999',
        (server) => server.reply(404, {'message': 'user not found'}),
      );

      expect(
        () => api.getEmotesChannel(id: '99999'),
        throwsA(isA<NotFoundException>()),
      );
    });
  });

  group('getBadges', () {
    test('returns map of userId to ChatBadge', () async {
      dioAdapter.onGet(
        'https://api.betterttv.net/3/cached/badges',
        (server) => server.reply(200, bttvBadgesResponse),
      );

      final badges = await api.getBadges();

      expect(badges, hasLength(2));
      expect(badges['user123']!.name, 'BTTV Developer');
      expect(badges['user123']!.url, contains('dev.svg'));
      expect(badges['user456']!.name, 'BTTV Supporter');
    });

    test('returns empty map for empty response', () async {
      dioAdapter.onGet(
        'https://api.betterttv.net/3/cached/badges',
        (server) => server.reply(200, <dynamic>[]),
      );

      final badges = await api.getBadges();

      expect(badges, isEmpty);
    });
  });
}
