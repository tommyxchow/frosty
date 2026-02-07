import 'package:flutter_test/flutter_test.dart';
import 'package:frosty/models/chatters.dart';

import '../fixtures/api_responses.dart';

void main() {
  group('ChatUsers', () {
    test('fromJson deserializes chatter count and chatters', () {
      final chatUsers = ChatUsers.fromJson(
        chattersResponse as Map<String, dynamic>,
      );

      expect(chatUsers.chatterCount, 5);
      expect(chatUsers.chatters.broadcaster, ['streamer']);
      expect(chatUsers.chatters.vips, ['vip1']);
      expect(chatUsers.chatters.moderators, ['mod1']);
      expect(chatUsers.chatters.viewers, ['viewer1', 'viewer2']);
    });
  });

  group('Chatters', () {
    test('fromJson handles all role lists', () {
      final chatters = Chatters.fromJson(
        chattersResponse['chatters'] as Map<String, dynamic>,
      );

      expect(chatters.broadcaster, hasLength(1));
      expect(chatters.vips, hasLength(1));
      expect(chatters.moderators, hasLength(1));
      expect(chatters.staff, isEmpty);
      expect(chatters.admins, isEmpty);
      expect(chatters.globalMods, isEmpty);
      expect(chatters.viewers, hasLength(2));
    });
  });
}
