import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:frosty/apis/base_api_client.dart';
import 'package:frosty/constants.dart';
import 'package:frosty/models/playback_access_token.dart';

/// Twitch GQL API client for fetching playback access tokens.
///
/// Uses the Twitch web client ID (not the app's registered client ID)
/// since the GQL endpoint requires it.
class TwitchGqlApi extends BaseApiClient {
  TwitchGqlApi(Dio dio) : super(dio, 'https://gql.twitch.tv');

  /// Browser-consistent User-Agent for playback-related requests. Twitch has
  /// rejected access-token requests with non-browser UAs before
  /// (streamlink#6574); sending one consistent with the web client ID and
  /// web session token avoids the obvious fingerprint mismatch.
  static const playbackUserAgent =
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 '
      '(KHTML, like Gecko) Chrome/140.0.0.0 Safari/537.36';

  /// Headers for the HLS playlist/segment requests issued by the native
  /// player, mirroring what the web player sends to Usher/weaver.
  static const playbackHttpHeaders = <String, String>{
    'User-Agent': playbackUserAgent,
    'Referer': 'https://player.twitch.tv',
    'Origin': 'https://player.twitch.tv',
  };

  /// Fetches a playback access token for the given channel [login].
  ///
  /// When [authToken] is provided, the request is authenticated which may
  /// grant ad-free playback for subscribers and Turbo users.
  ///
  /// Uses the web client's persisted GQL query (smaller payload, blends in
  /// with regular web traffic); falls back to the inline query template if
  /// Twitch ever rotates the persisted-query hash.
  Future<PlaybackAccessToken> getPlaybackAccessToken({
    required String login,
    String? authToken,
  }) async {
    final headers = <String, String>{
      'Client-ID': twitchGqlClientId,
      'User-Agent': playbackUserAgent,
      if (authToken != null) 'Authorization': 'OAuth $authToken',
    };

    final variables = {
      'isLive': true,
      'login': login,
      'isVod': false,
      'vodID': '',
      'playerType': 'site',
      'platform': 'web',
    };

    final persistedBody = {
      'operationName': 'PlaybackAccessToken',
      'extensions': {
        'persistedQuery': {
          'version': 1,
          // Stable for years; used by the web player and streamlink.
          'sha256Hash':
              'ed230aa1e33e07eebb8928504583da78a5173989fadfb1ac94be06a04f3cdbe9',
        },
      },
      'variables': variables,
    };

    final response = await post<JsonMap>(
      '/gql',
      data: persistedBody,
      headers: headers,
    );

    // PersistedQueryNotFound (or similar) comes back as a 200 with an
    // errors array — retry once with the inline template before failing.
    if (response['errors'] != null && response['data'] == null) {
      debugPrint(
        'TwitchGqlApi: persisted query failed (${response['errors']}), '
        'falling back to inline template',
      );
      final templateBody = {
        'operationName': 'PlaybackAccessToken_Template',
        'query':
            'query PlaybackAccessToken_Template(\$login: String!, \$isLive: Boolean!, \$vodID: ID!, \$isVod: Boolean!, \$playerType: String!) { streamPlaybackAccessToken(channelName: \$login, params: {platform: "web", playerBackend: "mediaplayer", playerType: \$playerType}) @include(if: \$isLive) { value signature __typename } videoPlaybackAccessToken(id: \$vodID, params: {platform: "web", playerBackend: "mediaplayer", playerType: \$playerType}) @include(if: \$isVod) { value signature __typename } }',
        'variables': variables,
      };
      final fallback = await post<JsonMap>(
        '/gql',
        data: templateBody,
        headers: headers,
      );
      return PlaybackAccessToken.fromGqlResponse(fallback);
    }

    return PlaybackAccessToken.fromGqlResponse(response);
  }

  /// Builds the HLS stream URL for the given channel [login] and [token].
  String buildHlsUrl({
    required String login,
    required PlaybackAccessToken token,
  }) {
    final random = Random().nextInt(999999);
    final encodedToken = Uri.encodeComponent(token.value);

    // Usher v2 — what the web player and streamlink use today. Same query
    // params and token; the multivariant playlist is standards-compliant
    // (EXT-X-SESSION-DATA + STREAM-INF only, no EXT-X-MEDIA/TWITCH-INFO).
    return 'https://usher.ttvnw.net/api/v2/channel/hls/$login.m3u8'
        '?sig=${token.signature}'
        '&token=$encodedToken'
        '&allow_source=true'
        '&allow_audio_only=true'
        '&fast_bread=true'
        '&supported_codecs=av1,h265,h264'
        '&reassignments_supported=true'
        '&platform=web'
        '&player_backend=mediaplayer'
        '&play_session_id=${_randomSessionId()}'
        '&playlist_include_framerate=true'
        '&p=$random';
  }

  /// 32-char hex play-session id, matching the web client and streamlink. Sent
  /// to Usher to identify the playback session; Usher tolerates its absence
  /// today but has historically tightened required params.
  String _randomSessionId() {
    final random = Random();
    final buffer = StringBuffer();
    for (var i = 0; i < 32; i++) {
      buffer.write(random.nextInt(16).toRadixString(16));
    }
    return buffer.toString();
  }
}
