import 'package:flutter_test/flutter_test.dart';
import 'package:frosty/apis/bttv_api.dart';
import 'package:frosty/apis/ffz_api.dart';
import 'package:frosty/apis/seventv_api.dart';
import 'package:frosty/apis/twitch_api.dart';
import 'package:frosty/models/emotes.dart';
import 'package:frosty/models/user.dart';
import 'package:frosty/screens/channel/chat/stores/chat_assets_store.dart';
import 'package:frosty/stores/global_assets_store.dart';
import 'package:mocktail/mocktail.dart';

class MockTwitchApi extends Mock implements TwitchApi {}

class MockBTTVApi extends Mock implements BTTVApi {}

class MockFFZApi extends Mock implements FFZApi {}

class MockSevenTVApi extends Mock implements SevenTVApi {}

class MockGlobalAssetsStore extends Mock implements GlobalAssetsStore {}

void main() {
  late MockTwitchApi twitchApi;
  late ChatAssetsStore store;

  const hypeEmote = Emote(
    name: 'HypeLol',
    zeroWidth: false,
    url: 'https://cdn/hype',
    type: EmoteType.twitchUnlocked,
    ownerId: 'twitch',
  );
  const subEmote = Emote(
    name: 'ChannelLove',
    zeroWidth: false,
    url: 'https://cdn/sub',
    type: EmoteType.twitchSub,
    ownerId: '67890',
  );

  setUp(() {
    twitchApi = MockTwitchApi();
    store = ChatAssetsStore(
      twitchApi: twitchApi,
      bttvApi: MockBTTVApi(),
      ffzApi: MockFFZApi(),
      sevenTVApi: MockSevenTVApi(),
      globalAssetsStore: MockGlobalAssetsStore(),
    );
  });

  test(
    'indexes Hype Train emotes and preserves subscription sections',
    () async {
      when(
        () => twitchApi.getUserEmotes(userId: '12345', broadcasterId: '67890'),
      ).thenAnswer((_) async => [hypeEmote, subEmote]);
      when(() => twitchApi.getUser(id: '67890')).thenAnswer(
        (_) async => const UserTwitch(
          '67890',
          'channel',
          'Channel',
          'https://cdn/profile',
        ),
      );

      await store.userEmotesFuture(
        userId: '12345',
        broadcasterId: '67890',
        onError: fail,
      );

      expect(store.userEmoteToObject['HypeLol'], hypeEmote);
      expect(store.userEmoteSectionToEmotes['Unlocked Emotes'], [hypeEmote]);
      expect(store.userEmoteSectionToEmotes['Channel'], [subEmote]);
      verify(() => twitchApi.getUser(id: '67890')).called(1);
    },
  );

  test('failed refresh preserves the last complete inventory', () async {
    when(
      () => twitchApi.getUserEmotes(userId: '12345', broadcasterId: '67890'),
    ).thenAnswer((_) async => [hypeEmote]);

    await store.userEmotesFuture(
      userId: '12345',
      broadcasterId: '67890',
      onError: fail,
    );

    final error = Exception('network failure');
    when(
      () => twitchApi.getUserEmotes(userId: '12345', broadcasterId: '67890'),
    ).thenThrow(error);
    Object? reportedError;

    await store.userEmotesFuture(
      userId: '12345',
      broadcasterId: '67890',
      onError: (value) => reportedError = value,
    );

    expect(reportedError, same(error));
    expect(store.userEmoteToObject, {'HypeLol': hypeEmote});
    expect(store.userEmoteSectionToEmotes['Unlocked Emotes'], [hypeEmote]);
  });
}
