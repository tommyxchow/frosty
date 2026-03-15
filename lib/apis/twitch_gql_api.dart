import 'dart:math';

import 'package:dio/dio.dart';
import 'package:frosty/apis/base_api_client.dart';
import 'package:frosty/constants.dart';
import 'package:frosty/models/playback_access_token.dart';

/// Twitch GQL API client for fetching playback access tokens.
///
/// Uses the Twitch web client ID (not the app's registered client ID)
/// since the GQL endpoint requires it.
class TwitchGqlApi extends BaseApiClient {
  TwitchGqlApi(Dio dio) : super(dio, 'https://gql.twitch.tv');

  /// Fetches a playback access token for the given channel [login].
  ///
  /// When [authToken] is provided, the request is authenticated which may
  /// grant ad-free playback for subscribers and Turbo users.
  Future<PlaybackAccessToken> getPlaybackAccessToken({
    required String login,
    String? authToken,
  }) async {
    final headers = <String, String>{
      'Client-ID': twitchGqlClientId,
      if (authToken != null) 'Authorization': 'OAuth $authToken',
    };

    final body = {
      'operationName': 'PlaybackAccessToken_Template',
      'query':
          'query PlaybackAccessToken_Template(\$login: String!, \$isLive: Boolean!, \$vodID: ID!, \$isVod: Boolean!, \$playerType: String!) { streamPlaybackAccessToken(channelName: \$login, params: {platform: "web", playerBackend: "mediaplayer", playerType: \$playerType}) @include(if: \$isLive) { value signature __typename } videoPlaybackAccessToken(id: \$vodID, params: {platform: "web", playerBackend: "mediaplayer", playerType: \$playerType}) @include(if: \$isVod) { value signature __typename } }',
      'variables': {
        'isLive': true,
        'login': login,
        'isVod': false,
        'vodID': '',
        'playerType': 'site',
      },
    };

    final response = await post<JsonMap>(
      '/gql',
      data: body,
      headers: headers,
    );

    return PlaybackAccessToken.fromGqlResponse(response);
  }

  /// Builds the HLS stream URL for the given channel [login] and [token].
  String buildHlsUrl({
    required String login,
    required PlaybackAccessToken token,
  }) {
    final random = Random().nextInt(999999);
    final encodedToken = Uri.encodeComponent(token.value);

    return 'https://usher.ttvnw.net/api/channel/hls/$login.m3u8'
        '?sig=${token.signature}'
        '&token=$encodedToken'
        '&allow_source=true'
        '&allow_audio_only=true'
        '&fast_bread=true'
        '&supported_codecs=av1,h265,h264'
        '&reassignments_supported=true'
        '&platform=web'
        '&playlist_include_framerate=true'
        '&p=$random';
  }
}
