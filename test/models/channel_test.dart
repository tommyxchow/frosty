import 'package:flutter_test/flutter_test.dart';
import 'package:frosty/models/channel.dart';

import '../fixtures/api_responses.dart';

void main() {
  group('Channel', () {
    test('fromJson deserializes snake_case fields', () {
      final channel = Channel.fromJson(
        (twitchChannelResponse['data']! as List).first as Map<String, dynamic>,
      );

      expect(channel.broadcasterId, '12345');
      expect(channel.broadcasterLogin, 'testuser');
      expect(channel.broadcasterName, 'TestUser');
      expect(channel.broadcasterLanguage, 'en');
      expect(channel.title, 'Test Stream');
      expect(channel.gameId, '509658');
      expect(channel.gameName, 'Just Chatting');
    });
  });

  group('ChannelQuery', () {
    test('fromJson deserializes snake_case fields', () {
      final query = ChannelQuery.fromJson(
        (twitchChannelQueryResponse['data']! as List).first
            as Map<String, dynamic>,
      );

      expect(query.broadcasterLogin, 'testuser');
      expect(query.displayName, 'TestUser');
      expect(query.id, '12345');
      expect(query.isLive, isTrue);
      expect(query.startedAt, '2024-01-01T00:00:00Z');
    });

    test('fromJson handles isLive false', () {
      final query = ChannelQuery.fromJson(const {
        'broadcaster_login': 'offline',
        'display_name': 'Offline',
        'id': '99999',
        'is_live': false,
        'started_at': '',
      });

      expect(query.isLive, isFalse);
    });
  });
}
