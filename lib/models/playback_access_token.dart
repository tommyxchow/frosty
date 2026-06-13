import 'dart:convert';

import 'package:flutter/foundation.dart';

class PlaybackAccessToken {
  final String value;
  final String signature;

  /// Whether Twitch will suppress ads for this session (Turbo, sub, etc.).
  /// Defaults to false when the token payload can't be parsed.
  final bool hideAds;

  /// Quality group names (e.g. "1080p60") that exist for this stream but are
  /// restricted to subscribers, so they won't appear in the HLS playlist.
  final List<String> restrictedQualities;

  const PlaybackAccessToken({
    required this.value,
    required this.signature,
    this.hideAds = false,
    this.restrictedQualities = const [],
  });

  /// Names in restricted_bitrates that aren't real video qualities
  /// (matches streamlink's filter).
  static final _nonQualityNameRe = RegExp(r'^((.+_)?archives|live|chunked)');

  factory PlaybackAccessToken.fromGqlResponse(Map<String, dynamic> json) {
    final data =
        (json['data'] as Map<String, dynamic>?)?['streamPlaybackAccessToken']
            as Map<String, dynamic>?;
    if (data == null) {
      throw const FormatException(
        'streamPlaybackAccessToken missing from GQL response',
      );
    }

    final value = data['value'] as String;
    var hideAds = false;
    var restricted = const <String>[];
    try {
      final payload = jsonDecode(value) as Map<String, dynamic>;
      hideAds = payload['hide_ads'] as bool? ?? false;
      final bitrates =
          (payload['chansub'] as Map<String, dynamic>?)?['restricted_bitrates']
              as List<dynamic>?;
      if (bitrates != null) {
        restricted = bitrates
            .whereType<String>()
            .where((name) => !_nonQualityNameRe.hasMatch(name))
            .toList();
      }
    } catch (e) {
      // Token payload format is Twitch-internal — never fail playback over it.
      debugPrint('PlaybackAccessToken: failed to parse token payload: $e');
    }

    return PlaybackAccessToken(
      value: value,
      signature: data['signature'] as String,
      hideAds: hideAds,
      restrictedQualities: restricted,
    );
  }
}
