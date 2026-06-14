import 'package:frosty/apis/twitch_api.dart';
import 'package:frosty/models/channel.dart';
import 'package:frosty/models/stream.dart';
import 'package:frosty/screens/channel/video/video_timing_constants.dart';

/// Snapshot of a channel's live state.
class StreamInfoResult {
  const StreamInfoResult({this.stream, this.offlineChannel});

  /// Non-null when the channel is currently live.
  final StreamTwitch? stream;

  /// Non-null when the channel is confirmed offline (channel metadata fetched
  /// successfully but no live stream). Both fields null means the fetch
  /// failed entirely (network error, etc.).
  final Channel? offlineChannel;
}

/// Debounced, deduplicated Twitch stream-info fetcher shared by both video
/// stores. Each store still owns its observable `_streamInfo` /
/// `_offlineChannelInfo` fields and decides how to react to the result.
class StreamInfoPoller {
  StreamInfoPoller({
    required this.twitchApi,
    required this.userLogin,
    required this.userId,
  });

  final TwitchApi twitchApi;
  final String userLogin;
  final String userId;

  DateTime? _lastUpdate;
  Future<StreamInfoResult>? _inFlight;

  /// Fetches the latest stream info, returning `null` if the call was
  /// debounced (caller should skip updating state). Concurrent calls await
  /// the in-flight request instead of issuing a new one.
  Future<StreamInfoResult?> fetch({bool forceUpdate = false}) async {
    final pending = _inFlight;
    if (pending != null) return pending;

    final now = DateTime.now();
    if (!forceUpdate && _lastUpdate != null) {
      if (now.difference(_lastUpdate!) <
          VideoTimingConstants.streamInfoDebounce) {
        return null;
      }
    }

    _lastUpdate = now;
    final request = _runFetch();
    _inFlight = request;
    try {
      return await request;
    } finally {
      if (identical(_inFlight, request)) _inFlight = null;
    }
  }

  Future<StreamInfoResult> _runFetch() async {
    try {
      final info = await twitchApi.getStream(userLogin: userLogin);
      return StreamInfoResult(stream: info);
    } catch (_) {
      // Helix can transiently drop a live stream from /streams (or 500 on
      // one endpoint while others succeed). A false "confirmed offline"
      // tears down latency polling and chat delay on healthy playback, so
      // require a second failed check before falling back to /channels.
      try {
        await Future<void>.delayed(
          VideoTimingConstants.offlineConfirmationDelay,
        );
        final info = await twitchApi.getStream(userLogin: userLogin);
        return StreamInfoResult(stream: info);
      } catch (_) {
        try {
          final channel = await twitchApi.getChannel(userId: userId);
          return StreamInfoResult(offlineChannel: channel);
        } catch (_) {
          return const StreamInfoResult();
        }
      }
    }
  }
}
