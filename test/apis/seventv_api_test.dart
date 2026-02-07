import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frosty/apis/base_api_client.dart';
import 'package:frosty/apis/seventv_api.dart';
import 'package:frosty/models/emotes.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

import '../fixtures/api_responses.dart';

void main() {
  late Dio dio;
  late DioAdapter dioAdapter;
  late SevenTVApi api;

  setUp(() {
    dio = Dio(BaseOptions());
    dioAdapter = DioAdapter(dio: dio);
    api = SevenTVApi(dio);
  });

  group('getEmotesGlobal', () {
    test('returns list of global 7TV emotes', () async {
      dioAdapter.onGet(
        'https://7tv.io/v3/emote-sets/global',
        (server) => server.reply(200, sevenTVEmotesGlobalResponse),
      );

      final emotes = await api.getEmotesGlobal();

      expect(emotes, hasLength(1));
      expect(emotes.first.name, 'EZ');
      expect(emotes.first.type, EmoteType.sevenTVGlobal);
      expect(emotes.first.url, contains('7tv.app'));
      expect(emotes.first.url, contains('4x.webp'));
      expect(emotes.first.ownerDisplayName, 'Creator');
      expect(emotes.first.ownerUsername, 'creator');
    });

    test('returns empty list for empty emotes', () async {
      dioAdapter.onGet(
        'https://7tv.io/v3/emote-sets/global',
        (server) => server.reply(200, {
          'emotes': <dynamic>[],
        }),
      );

      final emotes = await api.getEmotesGlobal();

      expect(emotes, isEmpty);
    });
  });

  group('getEmotesChannel', () {
    test('returns emote set ID and channel emotes', () async {
      dioAdapter.onGet(
        'https://7tv.io/v3/users/twitch/12345',
        (server) => server.reply(200, sevenTVEmotesChannelResponse),
      );

      final (emoteSetId, emotes) = await api.getEmotesChannel(id: '12345');

      expect(emoteSetId, 'set_abc123');
      expect(emotes, hasLength(1));
      expect(emotes.first.name, 'Clap');
      expect(emotes.first.type, EmoteType.sevenTVChannel);
    });

    test('filters out emotes with empty URLs', () async {
      dioAdapter.onGet(
        'https://7tv.io/v3/users/twitch/12345',
        (server) => server.reply(200, {
          'emote_set': {
            'id': 'set_filter',
            'emotes': [
              {
                'id': 'valid',
                'name': 'ValidEmote',
                'data': {
                  'id': 'valid',
                  'name': 'ValidEmote',
                  'flags': 0,
                  'owner': null,
                  'host': {
                    'url': '//cdn.7tv.app/emote/valid',
                    'files': [
                      {
                        'name': '1x.webp',
                        'width': 32,
                        'height': 32,
                        'format': 'WEBP',
                      },
                    ],
                  },
                },
              },
              {
                'id': 'empty_url',
                'name': 'NoUrlEmote',
                'data': {
                  'id': 'empty_url',
                  'name': 'NoUrlEmote',
                  'flags': 0,
                  'owner': null,
                  'host': {
                    'url': '//cdn.7tv.app/emote/empty_url',
                    // Only AVIF files — these get filtered by lastWhereOrNull,
                    // resulting in empty URL
                    'files': [
                      {
                        'name': '1x.avif',
                        'width': 32,
                        'height': 32,
                        'format': 'AVIF',
                      },
                    ],
                  },
                },
              },
            ],
          },
        }),
      );

      final (_, emotes) = await api.getEmotesChannel(id: '12345');

      expect(emotes, hasLength(1));
      expect(emotes.first.name, 'ValidEmote');
    });

    test('throws on 404 for unknown user', () {
      dioAdapter.onGet(
        'https://7tv.io/v3/users/twitch/99999',
        (server) => server.reply(404, {'message': 'Unknown User'}),
      );

      expect(
        () => api.getEmotesChannel(id: '99999'),
        throwsA(isA<NotFoundException>()),
      );
    });
  });
}
