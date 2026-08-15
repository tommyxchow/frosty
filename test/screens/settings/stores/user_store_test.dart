import 'package:flutter_test/flutter_test.dart';
import 'package:frosty/apis/twitch_api.dart';
import 'package:frosty/models/user.dart';
import 'package:frosty/screens/settings/stores/user_store.dart';
import 'package:mocktail/mocktail.dart';

class MockTwitchApi extends Mock implements TwitchApi {}

void main() {
  late MockTwitchApi api;

  setUp(() {
    api = MockTwitchApi();
    when(() => api.getUserInfo()).thenAnswer(
      (_) async => const UserTwitch(
        '12345',
        'testuser',
        'TestUser',
        'https://cdn/profile.png',
      ),
    );
    when(() => api.getUserBlockedList(id: any(named: 'id'))).thenAnswer(
      (_) async => <UserBlockedTwitch>[],
    );
    when(() => api.getModeratedChannels(id: any(named: 'id'))).thenAnswer(
      (_) async => <String>['999'],
    );
  });

  group('UserStore moderated channels gating', () {
    test('init skips moderated-channels without moderator scopes', () async {
      final store = UserStore(
        twitchApi: api,
        hasModeratorScopes: () => false,
      );

      await store.init();
      await Future<void>.delayed(Duration.zero);

      verifyNever(() => api.getModeratedChannels(id: any(named: 'id')));
      expect(store.moderatedChannels, isEmpty);
    });

    test('init fetches moderated-channels when moderator scopes exist', () async {
      final store = UserStore(
        twitchApi: api,
        hasModeratorScopes: () => true,
      );

      await store.init();
      await Future<void>.delayed(Duration.zero);

      verify(() => api.getModeratedChannels(id: '12345')).called(1);
      expect(store.moderatedChannels, ['999']);
    });

    test('refreshModeratedChannels no-ops without moderator scopes', () async {
      final store = UserStore(
        twitchApi: api,
        hasModeratorScopes: () => false,
      );
      await store.init();
      clearInteractions(api);

      await store.refreshModeratedChannels();
      verifyNever(() => api.getModeratedChannels(id: any(named: 'id')));
    });

    test('deleteMessage requires moderator scopes', () async {
      when(
        () => api.deleteChatMessage(
          broadcasterId: any(named: 'broadcasterId'),
          moderatorId: any(named: 'moderatorId'),
          messageId: any(named: 'messageId'),
        ),
      ).thenAnswer((_) async => true);

      final store = UserStore(
        twitchApi: api,
        hasModeratorScopes: () => false,
      );
      await store.init();

      final result = await store.deleteMessage(
        broadcasterId: '12345',
        messageId: 'msg',
      );

      expect(result, isFalse);
      verifyNever(
        () => api.deleteChatMessage(
          broadcasterId: any(named: 'broadcasterId'),
          moderatorId: any(named: 'moderatorId'),
          messageId: any(named: 'messageId'),
        ),
      );
    });
  });
}
