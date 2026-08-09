import 'package:flutter_test/flutter_test.dart';
import 'package:frosty/utils/twitch_oauth_scopes.dart';

void main() {
  group('scope sets', () {
    test('core scopes exclude moderator scopes', () {
      for (final scope in twitchModeratorScopes) {
        expect(twitchUserScopes, isNot(contains(scope)));
      }
      expect(twitchAllUserScopes, containsAll(twitchUserScopes));
      expect(twitchAllUserScopes, containsAll(twitchModeratorScopes));
    });
  });

  group('hasModeratorScopes', () {
    test('requires all three moderator scopes', () {
      expect(hasModeratorScopes(twitchAllUserScopes), isTrue);
      expect(
        hasModeratorScopes([
          ...twitchUserScopes,
          'user:read:moderated_channels',
          'moderator:manage:chat_messages',
        ]),
        isFalse,
      );
      expect(hasModeratorScopes(twitchUserScopes), isFalse);
    });
  });

  group('missingTwitchScopes', () {
    test('defaults to core scopes only', () {
      final missing = missingTwitchScopes(
        granted: const ['chat:read', 'chat:edit'],
      );

      expect(missing, contains('user:read:follows'));
      expect(missing, isNot(contains('user:read:moderated_channels')));
      expect(missing, isNot(contains('chat:read')));
    });

    test('returns empty when all required scopes are granted', () {
      expect(missingTwitchScopes(granted: twitchUserScopes), isEmpty);
      expect(
        missingTwitchScopes(
          granted: twitchAllUserScopes,
          required: twitchModeratorScopes,
        ),
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

    test('lists missing core permissions when logged in', () {
      final message = unauthorizedDialogMessage(
        isLoggedIn: true,
        grantedScopes: const ['chat:read', 'chat:edit'],
      );

      expect(message, contains('additional Twitch permissions'));
      expect(message, contains('View followed channels'));
      expect(message, isNot(contains('View channels you moderate')));
    });

    test('prefers session expired when core scopes are complete', () {
      expect(
        unauthorizedDialogMessage(
          isLoggedIn: true,
          grantedScopes: twitchUserScopes,
        ),
        contains('expired'),
      );
    });
  });

  group('enableModeratorToolsDialogMessage', () {
    test('lists moderator permission labels', () {
      final message = enableModeratorToolsDialogMessage();
      expect(message, contains('View channels you moderate'));
      expect(message, contains('Delete chat messages as a moderator'));
      expect(message, contains('Timeout and ban users as a moderator'));
    });
  });
}
