import 'package:flutter_test/flutter_test.dart';
import 'package:frosty/models/shared_chat_session.dart';

import '../fixtures/api_responses.dart';

void main() {
  group('SharedChatSession', () {
    test('fromJson deserializes all fields', () {
      final session = SharedChatSession.fromJson(
        (twitchSharedChatSessionResponse['data']! as List).first
            as Map<String, dynamic>,
      );

      expect(session.sessionId, 'session_123');
      expect(session.hostBroadcasterId, '12345');
      expect(session.participants.length, 2);
      expect(session.createdAt, '2024-01-01T00:00:00Z');
      expect(session.updatedAt, '2024-01-01T01:00:00Z');
    });
  });

  group('Participant', () {
    test('fromJson deserializes broadcaster_id', () {
      final participant = Participant.fromJson(const {
        'broadcaster_id': '67890',
      });

      expect(participant.broadcasterId, '67890');
    });

    test('participants from shared chat session are correct', () {
      final session = SharedChatSession.fromJson(
        (twitchSharedChatSessionResponse['data']! as List).first
            as Map<String, dynamic>,
      );

      expect(session.participants[0].broadcasterId, '12345');
      expect(session.participants[1].broadcasterId, '67890');
    });
  });
}
