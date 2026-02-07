import 'package:flutter_test/flutter_test.dart';
import 'package:frosty/models/user.dart';

import '../fixtures/api_responses.dart';

void main() {
  group('UserTwitch', () {
    test('fromJson deserializes snake_case fields', () {
      final user = UserTwitch.fromJson(
        (twitchUserResponse['data']! as List).first as Map<String, dynamic>,
      );

      expect(user.id, '12345');
      expect(user.login, 'testuser');
      expect(user.displayName, 'TestUser');
      expect(user.profileImageUrl, 'https://cdn/profile.png');
    });
  });

  group('UserBlockedTwitch', () {
    test('fromJson deserializes snake_case fields', () {
      final blocked = UserBlockedTwitch.fromJson(
        (twitchBlockedUsersResponse['data']! as List).first
            as Map<String, dynamic>,
      );

      expect(blocked.userId, '99999');
      expect(blocked.userLogin, 'blockeduser');
      expect(blocked.displayName, 'BlockedUser');
    });

    test('fromJson with different values', () {
      final blocked = UserBlockedTwitch.fromJson(const {
        'user_id': '11111',
        'user_login': 'another_blocked',
        'display_name': 'AnotherBlocked',
      });

      expect(blocked.userId, '11111');
      expect(blocked.userLogin, 'another_blocked');
      expect(blocked.displayName, 'AnotherBlocked');
    });
  });
}
