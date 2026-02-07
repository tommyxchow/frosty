import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frosty/apis/base_api_client.dart';
import 'package:frosty/apis/ffz_api.dart';
import 'package:frosty/models/badges.dart';
import 'package:frosty/models/emotes.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

import '../fixtures/api_responses.dart';

void main() {
  late Dio dio;
  late DioAdapter dioAdapter;
  late FFZApi api;

  setUp(() {
    dio = Dio(BaseOptions());
    dioAdapter = DioAdapter(dio: dio);
    api = FFZApi(dio);
  });

  group('getEmotesGlobal', () {
    test('returns global FFZ emotes from default sets', () async {
      dioAdapter.onGet(
        'https://api.frankerfacez.com/v1/set/global',
        (server) => server.reply(200, ffzEmotesGlobalResponse),
      );

      final emotes = await api.getEmotesGlobal();

      expect(emotes, hasLength(1));
      expect(emotes.first.name, 'LULW');
      expect(emotes.first.type, EmoteType.ffzGlobal);
      expect(emotes.first.ownerDisplayName, 'FFZOwner');
      expect(emotes.first.ownerUsername, 'ffzowner');
    });

    test('returns emotes from multiple default sets', () async {
      dioAdapter.onGet(
        'https://api.frankerfacez.com/v1/set/global',
        (server) => server.reply(200, {
          'default_sets': [1, 2],
          'sets': {
            '1': {
              'emoticons': [
                {
                  'name': 'LULW',
                  'height': 28,
                  'width': 28,
                  'owner': {'display_name': 'A', 'name': 'a'},
                  'urls': {'1': 'https://cdn/1x.png'},
                  'animated': null,
                },
              ],
            },
            '2': {
              'emoticons': [
                {
                  'name': 'KEKW',
                  'height': 32,
                  'width': 32,
                  'owner': {'display_name': 'B', 'name': 'b'},
                  'urls': {'1': 'https://cdn/kekw.png'},
                  'animated': null,
                },
              ],
            },
          },
        }),
      );

      final emotes = await api.getEmotesGlobal();

      expect(emotes, hasLength(2));
      expect(emotes[0].name, 'LULW');
      expect(emotes[1].name, 'KEKW');
    });
  });

  group('getRoomInfo', () {
    test('returns room info and channel emotes', () async {
      dioAdapter.onGet(
        'https://api.frankerfacez.com/v1/room/id/12345',
        (server) => server.reply(200, ffzRoomInfoResponse),
      );

      final (roomInfo, emotes) = await api.getRoomInfo(id: '12345');

      expect(roomInfo.set, 123);
      expect(roomInfo.vipBadge, isNull);
      expect(roomInfo.modUrls, isNull);
      expect(emotes, hasLength(1));
      expect(emotes.first.name, 'ChannelFFZ');
      expect(emotes.first.type, EmoteType.ffzChannel);
    });

    test('returns room info with VIP badge', () async {
      dioAdapter.onGet(
        'https://api.frankerfacez.com/v1/room/id/54321',
        (server) => server.reply(200, {
          'room': {
            'set': 456,
            'vip_badge': {
              '1': 'https://cdn/vip/1x.png',
              '2': 'https://cdn/vip/2x.png',
              '4': 'https://cdn/vip/4x.png',
            },
            'mod_urls': null,
          },
          'sets': {
            '456': {
              'emoticons': <dynamic>[],
            },
          },
        }),
      );

      final (roomInfo, emotes) = await api.getRoomInfo(id: '54321');

      expect(roomInfo.vipBadge, isNotNull);
      expect(roomInfo.vipBadge!.url1x, 'https://cdn/vip/1x.png');
      expect(emotes, isEmpty);
    });

    test('throws NotFoundException for unknown channel', () {
      dioAdapter.onGet(
        'https://api.frankerfacez.com/v1/room/id/99999',
        (server) => server.reply(404, {'error': 'No such room'}),
      );

      expect(
        () => api.getRoomInfo(id: '99999'),
        throwsA(isA<NotFoundException>()),
      );
    });
  });

  group('getBadges', () {
    test('builds user-to-badge map with reversed badge order', () async {
      dioAdapter.onGet(
        'https://api.frankerfacez.com/v1/badges/ids',
        (server) => server.reply(200, ffzBadgesResponse),
      );

      final badges = await api.getBadges();

      // User 22222 appears in both badge lists, so should have 2 badges.
      // Reversed iteration means badge 2 (Supporter) is processed first,
      // then badge 1 (Developer).
      expect(badges['22222'], hasLength(2));
      expect(badges['22222']![0].name, 'FFZ Supporter');
      expect(badges['22222']![1].name, 'FFZ Developer');

      // User 11111 only appears in badge 1
      expect(badges['11111'], hasLength(1));
      expect(badges['11111']![0].name, 'FFZ Developer');

      // User 33333 only appears in badge 2
      expect(badges['33333'], hasLength(1));
      expect(badges['33333']![0].name, 'FFZ Supporter');
    });

    test('badge entries have correct type', () async {
      dioAdapter.onGet(
        'https://api.frankerfacez.com/v1/badges/ids',
        (server) => server.reply(200, ffzBadgesResponse),
      );

      final badges = await api.getBadges();

      for (final badgeList in badges.values) {
        for (final badge in badgeList) {
          expect(badge.type, BadgeType.ffz);
        }
      }
    });

    test('returns empty map when no badges exist', () async {
      dioAdapter.onGet(
        'https://api.frankerfacez.com/v1/badges/ids',
        (server) => server.reply(200, {
          'badges': <dynamic>[],
          'users': <String, dynamic>{},
        }),
      );

      final badges = await api.getBadges();

      expect(badges, isEmpty);
    });
  });
}
