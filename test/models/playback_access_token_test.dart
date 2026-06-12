import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:frosty/models/playback_access_token.dart';

Map<String, dynamic> gqlResponse({required String value, String sig = 'sig'}) =>
    {
      'data': {
        'streamPlaybackAccessToken': {'value': value, 'signature': sig},
      },
    };

void main() {
  group('PlaybackAccessToken.fromGqlResponse', () {
    test('parses hide_ads and restricted bitrates from token payload', () {
      final value = jsonEncode({
        'hide_ads': true,
        'chansub': {
          'restricted_bitrates': [
            '1080p60',
            '720p60',
            'chunked',
            'archives',
            'sub_archives',
            'live',
            'audio_only',
          ],
        },
      });

      final token = PlaybackAccessToken.fromGqlResponse(
        gqlResponse(value: value),
      );

      expect(token.value, value);
      expect(token.signature, 'sig');
      expect(token.hideAds, isTrue);
      // chunked/archives/sub_archives/live are playlist-internal names, not
      // real qualities; names merely containing those words must survive.
      expect(token.restrictedQualities, [
        '1080p60',
        '720p60',
        'audio_only',
      ]);
    });

    test('does not filter qualities that merely contain reserved words', () {
      final value = jsonEncode({
        'chansub': {
          'restricted_bitrates': ['1080p60_live', 'olive', 'rearchives'],
        },
      });

      final token = PlaybackAccessToken.fromGqlResponse(
        gqlResponse(value: value),
      );

      expect(token.restrictedQualities, ['1080p60_live', 'olive', 'rearchives']);
    });

    test('survives a non-JSON token payload', () {
      final token = PlaybackAccessToken.fromGqlResponse(
        gqlResponse(value: 'not-json'),
      );

      expect(token.value, 'not-json');
      expect(token.hideAds, isFalse);
      expect(token.restrictedQualities, isEmpty);
    });

    test('throws FormatException when token is missing', () {
      expect(
        () => PlaybackAccessToken.fromGqlResponse({'data': null}),
        throwsFormatException,
      );
    });
  });
}
