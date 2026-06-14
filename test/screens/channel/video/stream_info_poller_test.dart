import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:frosty/apis/twitch_api.dart';
import 'package:frosty/models/channel.dart';
import 'package:frosty/models/stream.dart';
import 'package:frosty/screens/channel/video/stream_info_poller.dart';
import 'package:mocktail/mocktail.dart';

import '../../../fixtures/api_responses.dart';

class MockTwitchApi extends Mock implements TwitchApi {}

void main() {
  const userLogin = 'testuser';
  const userId = '12345';

  late MockTwitchApi api;

  // Fresh fixtures per test so nothing leaks between cases.
  StreamTwitch buildStream() => StreamTwitch.fromJson(
    (twitchStreamResponse['data']! as List).first as Map<String, dynamic>,
  );

  Channel buildChannel() => Channel.fromJson(
    (twitchChannelResponse['data']! as List).first as Map<String, dynamic>,
  );

  // Fresh poller per test so _lastUpdate / _inFlight debounce state never
  // carries over between tests.
  StreamInfoPoller buildPoller() =>
      StreamInfoPoller(twitchApi: api, userLogin: userLogin, userId: userId);

  setUp(() {
    api = MockTwitchApi();
  });

  group('live', () {
    test('returns stream when getStream succeeds', () async {
      when(
        () => api.getStream(userLogin: any(named: 'userLogin')),
      ).thenAnswer((_) async => buildStream());

      final poller = buildPoller();
      final result = await poller.fetch();

      expect(result, isNotNull);
      expect(result!.stream, isNotNull);
      expect(result.stream!.userName, 'TestUser');
      expect(result.offlineChannel, isNull);

      verify(() => api.getStream(userLogin: userLogin)).called(1);
      verifyNever(() => api.getChannel(userId: any(named: 'userId')));
    });
  });

  group('debounce', () {
    test(
      'second fetch within debounce window returns null, forceUpdate bypasses',
      () async {
        when(
          () => api.getStream(userLogin: any(named: 'userLogin')),
        ).thenAnswer((_) async => buildStream());

        final poller = buildPoller();

        // First fetch resolves with a real result.
        final first = await poller.fetch();
        expect(first, isNotNull);
        expect(first!.stream, isNotNull);

        // Immediate second fetch (no forceUpdate) is inside the 5s debounce
        // window -> debounced -> null.
        final second = await poller.fetch();
        expect(second, isNull);

        // forceUpdate bypasses the debounce -> a fresh result.
        final forced = await poller.fetch(forceUpdate: true);
        expect(forced, isNotNull);
        expect(forced!.stream, isNotNull);

        // Two real fetches (first + forced); the debounced one issued no call.
        verify(() => api.getStream(userLogin: userLogin)).called(2);
      },
    );
  });

  group('in-flight dedup', () {
    test(
      'concurrent fetches await the same request and call getStream once',
      () async {
        final completer = Completer<StreamTwitch>();
        when(
          () => api.getStream(userLogin: any(named: 'userLogin')),
        ).thenAnswer((_) => completer.future);

        final poller = buildPoller();

        // Fire both without awaiting so the second sees the in-flight future.
        final firstFuture = poller.fetch();
        final secondFuture = poller.fetch();

        // Now let the underlying request complete.
        completer.complete(buildStream());

        final first = await firstFuture;
        final second = await secondFuture;

        expect(first, isNotNull);
        expect(second, isNotNull);
        // Same deduplicated result instance.
        expect(identical(first, second), isTrue);
        expect(first!.stream, isNotNull);

        verify(() => api.getStream(userLogin: userLogin)).called(1);
      },
    );
  });

  group('second-chance retry', () {
    test(
      'getStream fails once then succeeds on retry -> stream, no getChannel',
      () async {
        var calls = 0;
        when(() => api.getStream(userLogin: any(named: 'userLogin'))).thenAnswer(
          (_) async {
            calls++;
            if (calls == 1) throw Exception('transient drop');
            return buildStream();
          },
        );

        final poller = buildPoller();
        final result = await poller.fetch();

        expect(result, isNotNull);
        expect(result!.stream, isNotNull);
        expect(result.offlineChannel, isNull);

        verify(() => api.getStream(userLogin: userLogin)).called(2);
        verifyNever(() => api.getChannel(userId: any(named: 'userId')));
      },
    );
  });

  group('offline', () {
    test(
      'getStream fails twice, getChannel succeeds -> offlineChannel',
      () async {
        when(
          () => api.getStream(userLogin: any(named: 'userLogin')),
        ).thenThrow(Exception('offline'));
        when(
          () => api.getChannel(userId: any(named: 'userId')),
        ).thenAnswer((_) async => buildChannel());

        final poller = buildPoller();
        final result = await poller.fetch();

        expect(result, isNotNull);
        expect(result!.stream, isNull);
        expect(result.offlineChannel, isNotNull);
        expect(result.offlineChannel!.broadcasterName, 'TestUser');

        verify(() => api.getStream(userLogin: userLogin)).called(2);
        verify(() => api.getChannel(userId: userId)).called(1);
      },
    );
  });

  group('total failure', () {
    test(
      'getStream fails twice and getChannel fails -> empty result',
      () async {
        when(
          () => api.getStream(userLogin: any(named: 'userLogin')),
        ).thenThrow(Exception('stream boom'));
        when(
          () => api.getChannel(userId: any(named: 'userId')),
        ).thenThrow(Exception('channel boom'));

        final poller = buildPoller();
        final result = await poller.fetch();

        expect(result, isNotNull);
        expect(result!.stream, isNull);
        expect(result.offlineChannel, isNull);

        verify(() => api.getStream(userLogin: userLogin)).called(2);
        verify(() => api.getChannel(userId: userId)).called(1);
      },
    );
  });
}
