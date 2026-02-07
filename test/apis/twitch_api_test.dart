import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frosty/apis/base_api_client.dart';
import 'package:frosty/apis/twitch_api.dart';
import 'package:frosty/models/emotes.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

import '../fixtures/api_responses.dart';

void main() {
  late Dio dio;
  late DioAdapter dioAdapter;
  late TwitchApi api;

  setUp(() {
    dio = Dio(BaseOptions());
    dioAdapter = DioAdapter(dio: dio);
    api = TwitchApi(dio);
  });

  group('getEmotesGlobal', () {
    test('returns list of global Twitch emotes', () async {
      dioAdapter.onGet(
        'https://api.twitch.tv/helix/chat/emotes/global',
        (server) => server.reply(200, twitchEmotesGlobalResponse),
      );

      final emotes = await api.getEmotesGlobal();

      expect(emotes, hasLength(2));
      expect(emotes[0].name, 'Kappa');
      expect(emotes[0].type, EmoteType.twitchGlobal);
      expect(emotes[0].url, contains('25'));
      expect(emotes[1].name, 'Keepo');
    });
  });

  group('getBadgesGlobal', () {
    test('returns map of badge set/version to ChatBadge', () async {
      dioAdapter.onGet(
        'https://api.twitch.tv/helix/chat/badges/global',
        (server) => server.reply(200, twitchBadgesGlobalResponse),
      );

      final badges = await api.getBadgesGlobal();

      expect(badges, hasLength(1));
      expect(badges['subscriber/0'], isNotNull);
      expect(badges['subscriber/0']!.name, 'Subscriber');
      expect(badges['subscriber/0']!.url, contains('4x.png'));
    });

    test('handles multiple versions per badge set', () async {
      dioAdapter.onGet(
        'https://api.twitch.tv/helix/chat/badges/global',
        (server) => server.reply(200, {
          'data': [
            {
              'set_id': 'subscriber',
              'versions': [
                {
                  'id': '0',
                  'image_url_1x': 'https://cdn/1x.png',
                  'image_url_2x': 'https://cdn/2x.png',
                  'image_url_4x': 'https://cdn/4x.png',
                  'title': 'Subscriber',
                  'description': '0 months',
                },
                {
                  'id': '3',
                  'image_url_1x': 'https://cdn/3mo/1x.png',
                  'image_url_2x': 'https://cdn/3mo/2x.png',
                  'image_url_4x': 'https://cdn/3mo/4x.png',
                  'title': '3-Month Subscriber',
                  'description': '3 months',
                },
              ],
            },
          ],
        }),
      );

      final badges = await api.getBadgesGlobal();

      expect(badges, hasLength(2));
      expect(badges['subscriber/0']!.name, 'Subscriber');
      expect(badges['subscriber/3']!.name, '3-Month Subscriber');
    });
  });

  group('getUser', () {
    test('returns user by login', () async {
      dioAdapter.onGet(
        'https://api.twitch.tv/helix/users',
        (server) => server.reply(200, twitchUserResponse),
        queryParameters: {'login': 'testuser'},
      );

      final user = await api.getUser(userLogin: 'testuser');

      expect(user.id, '12345');
      expect(user.login, 'testuser');
      expect(user.displayName, 'TestUser');
      expect(user.profileImageUrl, 'https://cdn/profile.png');
    });

    test('returns user by id', () async {
      dioAdapter.onGet(
        'https://api.twitch.tv/helix/users',
        (server) => server.reply(200, twitchUserResponse),
        queryParameters: {'id': '12345'},
      );

      final user = await api.getUser(id: '12345');

      expect(user.id, '12345');
    });

    test('throws NotFoundException for unknown user', () {
      dioAdapter.onGet(
        'https://api.twitch.tv/helix/users',
        (server) => server.reply(200, {
          'data': <dynamic>[],
        }),
        queryParameters: {'login': 'doesnotexist'},
      );

      expect(
        () => api.getUser(userLogin: 'doesnotexist'),
        throwsA(isA<NotFoundException>()),
      );
    });
  });

  group('getStream', () {
    test('returns stream for online user', () async {
      dioAdapter.onGet(
        'https://api.twitch.tv/helix/streams',
        (server) => server.reply(200, twitchStreamResponse),
        queryParameters: {'user_login': 'testuser'},
      );

      final stream = await api.getStream(userLogin: 'testuser');

      expect(stream.userName, 'TestUser');
      expect(stream.gameName, 'Just Chatting');
      expect(stream.viewerCount, 1000);
    });

    test('throws ApiException for offline user', () {
      dioAdapter.onGet(
        'https://api.twitch.tv/helix/streams',
        (server) => server.reply(200, {
          'data': <dynamic>[],
          'pagination': <String, String>{},
        }),
        queryParameters: {'user_login': 'offlineuser'},
      );

      expect(
        () => api.getStream(userLogin: 'offlineuser'),
        throwsA(
          isA<ApiException>().having(
            (e) => e.message,
            'message',
            contains('offlineuser'),
          ),
        ),
      );
    });
  });

  group('getStreamsByIds', () {
    test('builds query string for multiple user IDs', () async {
      // getStreamsByIds manually builds URL: /streams?user_id=1&user_id=2&first=100
      dioAdapter.onGet(
        'https://api.twitch.tv/helix/streams?user_id=111&user_id=222&first=100',
        (server) => server.reply(200, {
          'data': [
            {
              'user_id': '111',
              'user_login': 'user1',
              'user_name': 'User1',
              'game_id': '1',
              'game_name': 'Game',
              'title': 'Stream 1',
              'viewer_count': 100,
              'started_at': '2024-01-01T00:00:00Z',
              'thumbnail_url': 'https://cdn/1.jpg',
            },
            {
              'user_id': '222',
              'user_login': 'user2',
              'user_name': 'User2',
              'game_id': '2',
              'game_name': 'Game 2',
              'title': 'Stream 2',
              'viewer_count': 200,
              'started_at': '2024-01-01T00:00:00Z',
              'thumbnail_url': 'https://cdn/2.jpg',
            },
          ],
          'pagination': <String, String>{},
        }),
      );

      final result = await api.getStreamsByIds(
        userIds: ['111', '222'],
      );

      expect(result.data, hasLength(2));
      expect(result.data[0].userName, 'User1');
      expect(result.data[1].userName, 'User2');
    });
  });

  group('validateToken', () {
    test('returns true for valid token', () async {
      dioAdapter.onGet(
        'https://id.twitch.tv/oauth2/validate',
        (server) => server.reply(200, twitchValidateTokenResponse),
      );

      final isValid = await api.validateToken(token: 'valid_token');

      expect(isValid, isTrue);
    });

    test('returns false for expired token (401)', () async {
      dioAdapter.onGet(
        'https://id.twitch.tv/oauth2/validate',
        (server) => server.reply(401, {'message': 'invalid access token'}),
      );

      final isValid = await api.validateToken(token: 'expired_token');

      expect(isValid, isFalse);
    });

    test('rethrows on server error', () {
      dioAdapter.onGet(
        'https://id.twitch.tv/oauth2/validate',
        (server) => server.reply(500, null),
      );

      expect(
        () => api.validateToken(token: 'some_token'),
        throwsA(isA<ServerException>()),
      );
    });
  });

  group('getUserBlockedList', () {
    test('returns blocked users from single page', () async {
      dioAdapter.onGet(
        'https://api.twitch.tv/helix/users/blocks',
        (server) => server.reply(200, {
          'data': [
            {
              'user_id': '99999',
              'user_login': 'blockeduser',
              'display_name': 'BlockedUser',
            },
          ],
          'pagination': {'cursor': null},
        }),
        queryParameters: {'first': '100', 'broadcaster_id': '12345'},
      );

      final blocked = await api.getUserBlockedList(id: '12345');

      expect(blocked, hasLength(1));
      expect(blocked.first.userId, '99999');
      expect(blocked.first.userLogin, 'blockeduser');
    });

    test('returns empty list when no users blocked', () async {
      dioAdapter.onGet(
        'https://api.twitch.tv/helix/users/blocks',
        (server) => server.reply(200, {
          'data': <dynamic>[],
          'pagination': {'cursor': null},
        }),
        queryParameters: {'first': '100', 'broadcaster_id': '12345'},
      );

      final blocked = await api.getUserBlockedList(id: '12345');

      expect(blocked, isEmpty);
    });
  });

  group('getTopStreams', () {
    test('returns streams with pagination', () async {
      dioAdapter.onGet(
        'https://api.twitch.tv/helix/streams',
        (server) => server.reply(200, twitchStreamResponse),
      );

      final streams = await api.getTopStreams();

      expect(streams.data, hasLength(1));
      expect(streams.data.first.userName, 'TestUser');
      expect(streams.pagination['cursor'], 'next_cursor');
    });

    test('passes cursor for pagination', () async {
      dioAdapter.onGet(
        'https://api.twitch.tv/helix/streams',
        (server) => server.reply(200, {
          'data': <dynamic>[],
          'pagination': <String, String>{},
        }),
        queryParameters: {'after': 'page2_cursor'},
      );

      final streams = await api.getTopStreams(cursor: 'page2_cursor');

      expect(streams.data, isEmpty);
    });
  });

  group('getChannel', () {
    test('returns channel info', () async {
      dioAdapter.onGet(
        'https://api.twitch.tv/helix/channels',
        (server) => server.reply(200, twitchChannelResponse),
        queryParameters: {'broadcaster_id': '12345'},
      );

      final channel = await api.getChannel(userId: '12345');

      expect(channel.broadcasterId, '12345');
      expect(channel.broadcasterName, 'TestUser');
      expect(channel.title, 'Test Stream');
      expect(channel.gameName, 'Just Chatting');
    });

    test('throws ApiException for nonexistent channel', () {
      dioAdapter.onGet(
        'https://api.twitch.tv/helix/channels',
        (server) => server.reply(200, {
          'data': <dynamic>[],
        }),
        queryParameters: {'broadcaster_id': '99999'},
      );

      expect(
        () => api.getChannel(userId: '99999'),
        throwsA(isA<ApiException>()),
      );
    });
  });

  group('getEmotesChannel', () {
    test('maps emote types correctly', () async {
      dioAdapter.onGet(
        'https://api.twitch.tv/helix/chat/emotes',
        (server) => server.reply(200, {
          'data': [
            {
              'id': '1',
              'name': 'BitsEmote',
              'emote_type': 'bitstier',
              'owner_id': null,
            },
            {
              'id': '2',
              'name': 'FollowerEmote',
              'emote_type': 'follower',
              'owner_id': null,
            },
            {
              'id': '3',
              'name': 'SubEmote',
              'emote_type': 'subscriptions',
              'owner_id': '12345',
            },
          ],
        }),
        queryParameters: {'broadcaster_id': '12345'},
      );

      final emotes = await api.getEmotesChannel(id: '12345');

      expect(emotes, hasLength(3));
      expect(emotes[0].type, EmoteType.twitchBits);
      expect(emotes[1].type, EmoteType.twitchFollower);
      expect(emotes[2].type, EmoteType.twitchChannel);
    });
  });
}
