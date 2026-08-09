import 'package:flutter_test/flutter_test.dart';
import 'package:frosty/utils/twitch_oauth_scopes.dart';

void main() {
  group('missingTwitchScopes', () {
    test('returns scopes not present on the token', () {
      final missing = missingTwitchScopes(
        granted: const ['chat:read', 'chat:edit'],
      );

      expect(missing, contains('user:read:moderated_channels'));
      expect(missing, contains('moderator:manage:chat_messages'));
      expect(missing, contains('moderator:manage:banned_users'));
      expect(missing, isNot(contains('chat:read')));
    });

    test('returns empty when all required scopes are granted', () {
      expect(
        missingTwitchScopes(granted: twitchUserScopes),
        isEmpty,
      );
    });
  });

  group('unauthorizedDialogMessage', () {
    test('explains expired session when logged out', () {
      expect(
        unauthorizedDialogMessage(
          isLoggedIn: false,
          grantedScopes: const [],
        ),
        contains('expired'),
      );
    });

    test('lists human-readable missing permissions when logged in', () {
      final message = unauthorizedDialogMessage(
        isLoggedIn: true,
        grantedScopes: const [
          'chat:read',
          'chat:edit',
          'user:read:follows',
          'user:read:blocked_users',
          'user:manage:blocked_users',
          'user:manage:chat_color',
        ],
      );

      expect(message, contains('additional Twitch permissions'));
      expect(message, contains('View channels you moderate'));
      expect(message, contains('Delete chat messages as a moderator'));
      expect(message, contains('Timeout and ban users as a moderator'));
      expect(message, isNot(contains('Send chat messages')));
    });

    test('falls back when logged in but no missing scopes are known', () {
      expect(
        unauthorizedDialogMessage(
          isLoggedIn: true,
          grantedScopes: twitchUserScopes,
        ),
        contains('missing permissions'),
      );
    });
  });
}
