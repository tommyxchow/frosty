import 'package:dio/dio.dart';
import 'package:frosty/screens/settings/stores/auth_store.dart';

/// Dio interceptor that automatically adds Twitch authentication headers
/// to requests targeting Twitch API endpoints.
class TwitchAuthInterceptor extends Interceptor {
  final AuthStore _authStore;

  const TwitchAuthInterceptor(this._authStore);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Check if this is a Twitch API request that needs authentication
    if (_shouldAddTwitchHeaders(options.uri)) {
      // Add Twitch auth headers automatically
      final twitchHeaders = _authStore.headersTwitch;
      options.headers.addAll(twitchHeaders);
    }

    handler.next(options);
  }

  /// Determines if the request URL is for a Twitch API endpoint that requires authentication
  bool _shouldAddTwitchHeaders(Uri uri) {
    final url = uri.toString();

    // Add headers for Twitch Helix API and OAuth endpoints
    return url.startsWith('https://api.twitch.tv/helix') ||
        url.startsWith('https://id.twitch.tv/oauth2');
  }
}
