import 'dart:async';
import 'dart:io';

import 'package:better_native_video_player/better_native_video_player.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frosty/apis/base_api_client.dart';
import 'package:frosty/apis/twitch_api.dart';
import 'package:frosty/apis/twitch_gql_api.dart';
import 'package:frosty/constants.dart';
import 'package:frosty/models/channel.dart';
import 'package:frosty/models/playback_access_token.dart';
import 'package:frosty/models/stream.dart';
import 'package:frosty/screens/channel/video/chat_latency_sync.dart';
import 'package:frosty/screens/channel/video/native_video_player_interface.dart';
import 'package:frosty/screens/channel/video/stream_info_poller.dart';
import 'package:frosty/screens/channel/video/video_timing_constants.dart';
import 'package:frosty/screens/settings/stores/auth_store.dart';
import 'package:frosty/screens/settings/stores/settings_store.dart';
import 'package:mobx/mobx.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_pip_mode/simple_pip.dart';

part 'native_video_store.g.dart';

class NativeVideoStore = NativeVideoStoreBase with _$NativeVideoStore;

abstract class NativeVideoStoreBase
    with Store
    implements NativeVideoPlayerInterface {
  static int _nextId = 0;

  @override
  final String userLogin;
  final String userId;
  final String displayName;
  final TwitchApi twitchApi;
  final TwitchGqlApi twitchGqlApi;
  final AuthStore authStore;

  @override
  final SettingsStore settingsStore;

  @readonly
  NativeVideoPlayerController? _controller;

  Timer? _overlayTimer;
  Timer? _latencyTimer;
  Timer? _stallRecoveryTimer;
  Timer? _streamInfoTimer;
  var _stallRecoveryAttempt = 0;
  var _isStalled = false;
  Timer? _initRetryTimer;
  Timer? _healthyPlaybackTimer;
  DateTime? _lastRefreshTime;
  bool _overlayWasVisibleBeforePip = true;
  var _userPaused = false;

  String? _profileImageUrl;
  var _manualPipRequested = false;
  var _lastPipWasAutomatic = false;
  List<NativeVideoPlayerQuality> _qualityObjects = [];
  var _firstTimeSettingQuality = true;
  int? _pendingQualityIndex;
  var _disposed = false;
  var _initializing = true;
  var _initInFlight = false;
  var _controllerInitialized = false;
  var _totalRefreshAttempts = 0;
  var _highLatencyCount = 0;

  /// Timestamp of the most recent transition into `_onPlaying`. A subsequent
  /// stall that arrives inside [VideoTimingConstants.shortPlayWindow] counts
  /// as a bounce; repeated bounces surface a tailored CDN-trouble error.
  DateTime? _lastPlayingStart;
  int _shortPlayBounceCount = 0;
  var _isQualitySwitching = false;
  Timer? _qualitySwitchGraceTimer;

  /// Set when an automatic refresh was suppressed because the user had
  /// paused (e.g. the playback session expired mid-pause). Consumed by
  /// [handlePausePlay] to refresh instead of playing a dead session.
  var _pendingRefreshOnResume = false;
  var _initGeneration = 0;
  static final _bareResolutionRe = RegExp(r'^(\d+)p$');

  final _pip = SimplePip();
  late final ChatLatencySync _chatLatencySync =
      ChatLatencySync(settingsStore: settingsStore);
  late final StreamInfoPoller _streamInfoPoller = StreamInfoPoller(
    twitchApi: twitchApi,
    userLogin: userLogin,
    userId: userId,
  );
  ReactionDisposer? _disposeAndroidAutoPipReaction;
  ReactionDisposer? _disposeVideoModeReaction;

  /// Cached SimplePip.isAutoPipAvailable result. Populated by the Android
  /// auto-PiP reaction on first run; reused by dispose to avoid a redundant
  /// platform-channel call.
  bool? _autoPipAvailable;

  StreamSubscription<bool>? _pipSub;
  StreamSubscription<List<NativeVideoPlayerQuality>>? _qualitiesSub;
  StreamSubscription<bool>? _adBreakSub;

  /// True while a server-stitched ad break is playing (native player detects
  /// twitch-stitched-ad dateranges). Latency readings and play/buffer
  /// transitions are unreliable during ads, so recovery and chat sync are
  /// suspended rather than burning refresh attempts on ad-induced noise.
  var _isAdBreakActive = false;

  @readonly
  var _loading = true;

  @readonly
  var _paused = true;

  @readonly
  var _hasPlayedOnce = false;

  @readonly
  var _overlayVisible = true;

  @readonly
  StreamTwitch? _streamInfo;

  @readonly
  Channel? _offlineChannelInfo;

  @readonly
  var _availableStreamQualities = <String>[];

  /// Qualities that exist for this stream but require a subscription
  /// (parsed from the playback token's restricted_bitrates).
  @readonly
  var _restrictedStreamQualities = <String>[];

  @readonly
  var _streamQualityIndex = 0;

  @override
  @computed
  String get streamQuality =>
      _availableStreamQualities.elementAtOrNull(_streamQualityIndex) ?? 'Auto';

  @readonly
  String? _latency;

  @readonly
  var _isInPipMode = false;

  @readonly
  var _isAudioOnlyMode = false;

  @readonly
  String? _error;

  NativeVideoStoreBase({
    required this.userLogin,
    required this.userId,
    required this.displayName,
    required this.twitchApi,
    required this.twitchGqlApi,
    required this.authStore,
    required this.settingsStore,
  }) {
    _chatLatencySync.reset();
    _scheduleOverlayHide();
    updateStreamInfo();
    _startStreamInfoTimer();

    // Skip eager init in chat-only mode — `play()` is what activates the
    // iOS audio session, so without it nothing is allocated.
    if (settingsStore.showVideo) {
      _controller = _createController();
      _initPlayer();
    } else {
      _loading = false;
      _initializing = false;
    }

    // `pause()` alone leaves the audio session, PiP controller, and URL
    // session alive on iOS, which blocks low-power sleep states. Full
    // dispose is the only path that deactivates the audio session.
    _disposeVideoModeReaction = reaction(
      (_) => settingsStore.showVideo,
      (showVideo) {
        if (!showVideo) {
          _disposeController();
          _resetPlayerStateForChatOnly();
        } else if (_controller == null) {
          _initFreshController();
        }
      },
    );

    if (Platform.isAndroid) {
      // Explicit reaction on showVideo only (vs autorun, which re-runs on any
      // observable the closure happens to read). Caches the auto-PiP
      // availability check — it doesn't change within a session.
      _disposeAndroidAutoPipReaction = reaction(
        (_) => settingsStore.showVideo,
        (showVideo) async {
          _autoPipAvailable ??= await SimplePip.isAutoPipAvailable;
          if (_disposed || !_autoPipAvailable!) return;
          if (showVideo) {
            _pip.setAutoPipMode();
          } else {
            _pip.setAutoPipMode(autoEnter: false);
          }
        },
        fireImmediately: true,
      );
    }
  }

  NativeVideoPlayerController _createController() {
    final controller = NativeVideoPlayerController(
      id: _nextId++,
      autoPlay: true,
      showNativeControls: false,
      mediaInfo: NativeVideoPlayerMediaInfo(
        title: displayName,
        subtitle: 'Frosty — Twitch',
        artworkUrl: _profileImageUrl,
      ),
    );
    controller.addActivityListener(_onPlayerActivity);
    return controller;
  }

  /// Pushes the channel's Now Playing metadata (lock screen / control center)
  /// to the native player using the cached profile image.
  void _applyNowPlayingMediaInfo() {
    if (_disposed || _controller == null) return;
    _controller!.setMediaInfo(NativeVideoPlayerMediaInfo(
      title: displayName,
      subtitle: _streamInfo?.title ?? 'Twitch',
      artworkUrl: _profileImageUrl,
    ));
  }

  @action
  Future<void> _initPlayer() async {
    if (_initInFlight) return;
    _initInFlight = true;
    final generation = _initGeneration;
    try {
      // Fetch profile image URL for Now Playing artwork (fire-and-forget).
      // _initPlayer re-runs on every hard refresh and chat-only toggle, so
      // skip the Helix call once the URL is cached.
      if (_profileImageUrl != null) {
        _applyNowPlayingMediaInfo();
      } else {
        twitchApi.getUser(id: userId).then((user) {
          _profileImageUrl = user.profileImageUrl;
          _applyNowPlayingMediaInfo();
        }).catchError((e) {
          debugPrint('NativeVideoStore: profile image fetch failed: $e');
        });
      }

      await _controller!.initialize();
      if (_disposed || generation != _initGeneration) {
        // Don't reset _initInFlight here — a newer generation's _initPlayer
        // may already own the flag. Only the current generation should touch it.
        return;
      }

      _adBreakSub = _controller!.adBreakStream.listen((isActive) {
        _isAdBreakActive = isActive;
        debugPrint(
          'NativeVideoStore: ad break ${isActive ? 'started' : 'ended'}',
        );
      });

      _pipSub = _controller!.isPipEnabledStream.listen((isPip) {
        runInAction(() {
          // iOS-only bookkeeping: track whether PiP was triggered by gesture
          // (auto) or button (manual). Must run before _setPipActive mutates
          // _isInPipMode.
          if (isPip && !_isInPipMode) {
            _lastPipWasAutomatic = !_manualPipRequested;
            _manualPipRequested = false;
          } else if (!isPip && _isInPipMode) {
            _lastPipWasAutomatic = false;
          }
          _setPipActive(isPip);
        });
      });

      _qualitiesSub = _controller!.qualitiesStream.listen((qualities) {
        runInAction(() {
          // Filter out the plugin's auto entry (we add our own) and deduplicate.
          final seen = <String>{};
          final filtered = qualities
              .where((q) => !q.isAuto && seen.add(q.label))
              .toList();

          // Remove bare "{height}p" entries when a fps-suffixed version
          // (e.g. "160p30") exists at the same height. The bare entry is
          // typically a duplicate HLS variant with missing FRAME-RATE that
          // causes frozen video when selected.
          final labels = filtered.map((q) => q.label).toSet();
          filtered.removeWhere((q) {
            final bare = _bareResolutionRe.firstMatch(q.label);
            if (bare == null) return false;
            final height = bare.group(1)!;
            return labels.any(
              (l) => l != q.label && l.startsWith('${height}p'),
            );
          });

          // Reverse so highest quality comes first.
          _qualityObjects = filtered.reversed.toList();
          _availableStreamQualities = [
            'Auto',
            ..._qualityObjects.map((q) => q.label),
          ];

          if (_firstTimeSettingQuality && qualities.isNotEmpty) {
            _firstTimeSettingQuality = false;
            if (settingsStore.defaultToHighestQuality) {
              _queueOrApplyInitialQualityIndex(1);
            } else {
              SharedPreferences.getInstance().then((prefs) {
                if (_disposed || _pendingQualityIndex != null) return;
                final lastQuality =
                    prefs.getString(lastStreamQualityKey(userLogin));
                if (lastQuality == null) return;
                final index = _availableStreamQualities.indexOf(lastQuality);
                if (index != -1) {
                  runInAction(() => _queueOrApplyInitialQualityIndex(index));
                }
              }).catchError((e) {
                debugPrint('NativeVideoStore: failed to read last quality: $e');
              });
            }
          }
        });
      });

      _controllerInitialized = true;
    } catch (e, stackTrace) {
      if (_disposed || generation != _initGeneration) return;
      _initInFlight = false;
      await _handleLoadError(e, stackTrace, generation);
      return;
    }
    _initInFlight = false;
    await _runLoadStream(generation);
  }

  /// Wraps `_loadStream` with shared success/error handling. On success,
  /// clears `_error`; on failure, delegates to `_handleLoadError` for retry
  /// scheduling or error display. Used by both first-time init and refresh.
  Future<void> _runLoadStream(int generation) async {
    try {
      await _loadStream(generation);
      if (_disposed || generation != _initGeneration) return;
      runInAction(() {
        _error = null;
      });
    } catch (e, stackTrace) {
      if (_disposed || generation != _initGeneration) return;
      await _handleLoadError(e, stackTrace, generation);
    }
  }

  /// Fetches a fresh playback token, builds the HLS URL, and loads it into
  /// the (already-initialized) controller. Used by both first-time init and
  /// user-initiated refresh (light refresh reuses the same AVPlayer via
  /// replaceCurrentItem internally, per Apple's HLS recovery guidance).
  Future<void> _loadStream(int generation) async {
    // Use web cookie token (works with web Client-ID) for ad-free playback.
    final authToken = authStore.gqlToken;
    late final PlaybackAccessToken token;
    try {
      token = await twitchGqlApi.getPlaybackAccessToken(
        login: userLogin,
        authToken: authToken,
      );
    } catch (e) {
      if (authToken != null) {
        debugPrint('NativeVideoStore: auth token failed, retrying without: $e');
        if (e is UnauthorizedException) {
          // Twitch rejected the web session token — unlink it so the UI
          // reflects the true state and future loads skip this request.
          authStore.invalidateGqlToken();
        }
        token = await twitchGqlApi.getPlaybackAccessToken(login: userLogin);
      } else {
        rethrow;
      }
    }

    if (_disposed || generation != _initGeneration || !settingsStore.showVideo) {
      return;
    }
    runInAction(
      () => _restrictedStreamQualities = token.restrictedQualities,
    );
    final hlsUrl = twitchGqlApi.buildHlsUrl(login: userLogin, token: token);

    await _controller!.loadUrl(
      url: hlsUrl,
      headers: TwitchGqlApi.playbackHttpHeaders,
    );
    if (_disposed || generation != _initGeneration || !settingsStore.showVideo) {
      return;
    }
    await _controller!.configureForLivePlayback();
    _startLatencyPolling();
  }

  /// Shared error handler for both `_initPlayer` and `_reloadCurrentController`.
  /// Checks stream liveness, auto-retries if CDN is still serving stale
  /// manifests, or surfaces the error with the overlay visible.
  Future<void> _handleLoadError(
    Object e,
    StackTrace stackTrace,
    int generation,
  ) async {
    _initializing = false;
    // Wait for stream info so we can distinguish "offline" from "broken".
    await updateStreamInfo(forceUpdate: true);
    if (_disposed || generation != _initGeneration) return;
    debugPrint('NativeVideoStore load error: $e');
    if (_streamInfo != null) {
      _recordNativePlaybackError(
        e,
        stackTrace,
        'Native video load failed',
        information: [
          'channel=$userLogin',
          'attempt=$_totalRefreshAttempts',
        ],
      );
    }

    // Auto-retry if the stream is live — the CDN may still be serving
    // stale manifests right after a stream crash.
    if (_streamInfo != null &&
        _totalRefreshAttempts < VideoTimingConstants.maxRefreshAttempts) {
      _totalRefreshAttempts++;
      debugPrint(
        'NativeVideoStore: auto-retrying load '
        '(attempt $_totalRefreshAttempts/${VideoTimingConstants.maxRefreshAttempts})',
      );
      _initRetryTimer?.cancel();
      _initRetryTimer = Timer(VideoTimingConstants.initRetryDelay, () {
        if (!_disposed && generation == _initGeneration) {
          _handleRefresh(userInitiated: false);
        }
      });
      return;
    }

    runInAction(() {
      _loading = false;
      _paused = true;
      // Only show the error if the stream is actually live — an offline
      // channel is expected to fail here and the overlay handles it.
      if (_streamInfo != null) {
        _showErrorOverlay(
          'Native player failed to load. Try the standard player in Settings.',
        );
      }
    });
  }

  /// Light refresh — reloads the stream URL on the existing controller.
  /// Skips platform view recreation, audio session churn, and subscription
  /// teardown. Per Apple's WWDC 2017 guidance, this is the preferred
  /// pattern: new AVPlayerItem via `replaceCurrentItem` on existing AVPlayer.
  @action
  Future<void> _reloadCurrentController() => _runLoadStream(_initGeneration);

  void _onPlayerActivity(PlayerActivityEvent event) {
    runInAction(() {
      switch (event.state) {
        case PlayerActivityState.playing:
          _onPlaying();
        case PlayerActivityState.buffering:
        case PlayerActivityState.loading:
          _onBufferingOrLoading(event.state);
        case PlayerActivityState.error:
          _onPlayerError(event.data);
        case PlayerActivityState.paused:
        case PlayerActivityState.stopped:
        case PlayerActivityState.completed:
        case PlayerActivityState.idle:
          _onPaused();
        default:
          break;
      }
    });
  }

  void _onPlaying() {
    _loading = false;
    _paused = false;
    _isStalled = false;
    _hasPlayedOnce = true;
    _initializing = false;
    _isQualitySwitching = false;
    _stallRecoveryTimer?.cancel();
    _stallRecoveryAttempt = 0;
    _lastPlayingStart = DateTime.now();
    _scheduleHealthyPlaybackRecoveryReset(_lastPlayingStart!);
    if (_pendingQualityIndex != null) {
      final index = _pendingQualityIndex!;
      _pendingQualityIndex = null;
      _setStreamQualityIndex(index);
    }
    _updateLatency();
  }

  void _onBufferingOrLoading(PlayerActivityState state) {
    if (!_isQualitySwitching && !_hasPlayedOnce) {
      _loading = true;
    }
    // Track mid-stream stalls separately from initial loading. With
    // automaticallyWaitsToMinimizeStalling = false, AVPlayer silently drops
    // rate to 0 when the buffer empties. The stall timer needs this flag
    // to engage recovery on those stalls.
    if (_hasPlayedOnce && !_isQualitySwitching) {
      _isStalled = true;
      // Ad-pod entry/exit produces short play/buffer bounces that would
      // otherwise count toward the CDN-trouble error heuristic.
      if (!_isAdBreakActive) _recordShortPlayBounceIfNeeded();
    }
    // Clear _initializing on the first buffering event so the stall
    // recovery timer isn't permanently blocked during init stalls.
    if (_initializing && state == PlayerActivityState.buffering) {
      _initializing = false;
    }
    if (!_userPaused && !_initializing) _startStallRecoveryTimer();
  }

  void _onPlayerError(Map<String, dynamic>? eventData) {
    _loading = false;
    _paused = true;
    _isStalled = false;
    _initializing = false;
    _isQualitySwitching = false;
    _stallRecoveryTimer?.cancel();
    final errorMessage =
        eventData?['message'] as String? ??
        'Playback error. Try refreshing or switch to the standard player in Settings.';
    final errorCode = eventData?['code'] as String?;
    final statusCode = eventData?['statusCode'] as int?;

    if (errorCode == 'mediaServicesWereReset') {
      _handleMediaServicesReset(errorMessage);
      return;
    }

    // 4xx on the HLS fetch means the current playback session is gone — a
    // fresh GQL token + new query params can land on a different CDN edge
    // with a working manifest. Skip the user-facing error and retry
    // immediately (handleRefresh updates _lastRefreshTime itself).
    if (statusCode != null &&
        statusCode >= 400 &&
        statusCode < 500 &&
        !_refreshCapReached()) {
      if (_userPaused) {
        // Don't yank a user-paused stream back to life — the refresh would
        // reload with autoplay. Defer until they resume.
        _pendingRefreshOnResume = true;
        return;
      }
      debugPrint(
        'NativeVideoStore: $statusCode on HLS fetch, refreshing with fresh '
        'token (attempt ${_totalRefreshAttempts + 1}/${VideoTimingConstants.maxRefreshAttempts})',
      );
      _totalRefreshAttempts++;
      _handleRefresh(userInitiated: false);
      return;
    }

    // Check stream liveness before showing the error — an offline channel
    // is expected to 404 and the overlay handles it.
    final generation = _initGeneration;
    updateStreamInfo(forceUpdate: true).then((_) {
      if (_disposed || generation != _initGeneration) return;
      runInAction(() {
        if (_streamInfo != null) {
          _recordNativePlaybackError(
            StateError(errorMessage),
            StackTrace.current,
            'Native video player error',
            information: [
              'channel=$userLogin',
              if (errorCode != null) 'code=$errorCode',
              if (statusCode != null) 'statusCode=$statusCode',
            ],
          );
          _showErrorOverlay(errorMessage);
        }
      });
    });
  }

  /// Surfaces [message] on the video overlay and pins it (cancels auto-hide).
  /// Must be called inside an action context.
  void _showErrorOverlay(String message) {
    _error = message;
    _overlayVisible = true;
    _overlayTimer?.cancel();
  }

  void _recordNativePlaybackError(
    Object error,
    StackTrace stackTrace,
    String reason, {
    List<Object> information = const [],
  }) {
    try {
      FirebaseCrashlytics.instance.recordError(
        error,
        stackTrace,
        reason: reason,
        information: information,
      );
    } catch (_) {
      // Firebase may not be initialized (e.g., in tests).
    }
  }

  void _handleMediaServicesReset(String errorMessage) {
    if (_refreshCapReached()) {
      runInAction(() {
        _disposeController();
        _loading = false;
        _paused = true;
        _isStalled = false;
        _initializing = false;
        _isQualitySwitching = false;
        _showErrorOverlay(errorMessage);
      });
      return;
    }

    if (_userPaused) {
      // The player is orphaned either way, but don't auto-resume a stream
      // the user paused — rebuild when they tap play.
      _disposeController();
      _pendingRefreshOnResume = true;
      return;
    }

    _totalRefreshAttempts++;
    debugPrint(
      'NativeVideoStore: media services reset, rebuilding player '
      '(attempt $_totalRefreshAttempts/${VideoTimingConstants.maxRefreshAttempts})',
    );
    _disposeController();
    unawaited(_handleRefresh(userInitiated: false));
  }

  bool _refreshCapReached() =>
      _totalRefreshAttempts >= VideoTimingConstants.maxRefreshAttempts;

  void _onPaused() {
    _healthyPlaybackTimer?.cancel();
    _paused = true;
    _isStalled = false;
    _isQualitySwitching = false;
    _stallRecoveryTimer?.cancel();

    // If the player auto-paused during startup/buffering before playing once,
    // and the user didn't explicitly pause it, force resume and trigger recovery.
    if (!_userPaused && !_hasPlayedOnce && !_initializing && _error == null) {
      debugPrint('NativeVideoStore: auto-paused before first play, triggering play');
      _controller?.play();
      _startStallRecoveryTimer();
    }
  }

  void _startStallRecoveryTimer() {
    _stallRecoveryTimer?.cancel();
    _stallRecoveryTimer = Timer(
      VideoTimingConstants.stallDetectionDelay,
      _runStallRecovery,
    );
  }

  Future<void> _runStallRecovery() async {
    if (_disposed ||
        (!_loading && !_isStalled) ||
        _userPaused ||
        _initializing) {
      return;
    }

    // Note: recovery deliberately does NOT defer during ad breaks. Ad-pod
    // transition glitches resolve well inside the 8s stall window, attempt-1
    // recovery (seek to edge + play) is harmless mid-pod, and the native
    // ad-break flag can freeze at true when paused (the time observer that
    // re-evaluates it stops firing) — gating recovery on it deadlocks the
    // player into a permanent pause.

    // When a stream ends the HLS server stops serving segments, causing
    // the player to stall indefinitely. Skip recovery if the stream is
    // offline — the overlay handles that state.
    await updateStreamInfo(forceUpdate: true);
    if (_disposed || _streamInfo == null) return;

    _stallRecoveryAttempt++;

    if (_stallRecoveryAttempt <= 1) {
      _recoverBySeekingToLiveEdge();
    } else if (_refreshCapReached()) {
      _showStallError();
    } else if (_backoffDelayRemaining() > Duration.zero) {
      // Still within the exponential backoff window — re-arm and try again.
      debugPrint('NativeVideoStore: refresh backoff pending, re-arming timer');
      _startStallRecoveryTimer();
    } else {
      _recoverByFullRefresh();
    }
  }

  void _recoverBySeekingToLiveEdge() {
    debugPrint('NativeVideoStore: stall detected, seeking to live edge');
    _controller?.seekToLiveEdge();
    _controller?.play();
    _startStallRecoveryTimer();
  }

  void _showStallError() {
    debugPrint('NativeVideoStore: max recovery attempts reached');
    final bouncing = _shortPlayBounceCount >=
        VideoTimingConstants.shortPlayLoopThreshold;
    runInAction(() {
      _loading = false;
      _showErrorOverlay(
        bouncing
            ? 'Twitch is having trouble with this channel right now. Try again in a moment, or switch to the standard player in Settings.'
            : 'Stream stalled. Try refreshing or switch to the standard player in Settings.',
      );
    });
  }

  /// If a stall arrives within [shortPlayWindow] of the last `_onPlaying`,
  /// count it as a bounce. Three bounces in a row flips the stall-error
  /// message to the CDN-trouble variant.
  void _recordShortPlayBounceIfNeeded() {
    _healthyPlaybackTimer?.cancel();
    final start = _lastPlayingStart;
    if (start == null) return;
    final elapsed = DateTime.now().difference(start);
    if (elapsed <= VideoTimingConstants.shortPlayWindow) {
      _shortPlayBounceCount++;
    } else {
      _shortPlayBounceCount = 0;
    }
    _lastPlayingStart = null;
  }

  void _scheduleHealthyPlaybackRecoveryReset(DateTime playingStartedAt) {
    _healthyPlaybackTimer?.cancel();
    _healthyPlaybackTimer = Timer(VideoTimingConstants.shortPlayWindow, () {
      if (_disposed ||
          _isStalled ||
          _lastPlayingStart != playingStartedAt) {
        return;
      }
      runInAction(() {
        _totalRefreshAttempts = 0;
        _shortPlayBounceCount = 0;
        _lastPlayingStart = null;
      });
    });
  }

  /// How long to wait before the next stall-recovery full refresh, based on
  /// how many have already fired. Returns zero once enough time has elapsed
  /// since the last refresh, or when no refresh has happened yet.
  Duration _backoffDelayRemaining() {
    if (_lastRefreshTime == null) return Duration.zero;
    final idx = _totalRefreshAttempts
        .clamp(0, VideoTimingConstants.refreshBackoff.length - 1);
    final required = VideoTimingConstants.refreshBackoff[idx];
    final elapsed = DateTime.now().difference(_lastRefreshTime!);
    final remaining = required - elapsed;
    return remaining > Duration.zero ? remaining : Duration.zero;
  }

  void _recoverByFullRefresh() {
    _totalRefreshAttempts++;
    debugPrint(
      'NativeVideoStore: stall persists, refreshing player '
      '(attempt $_totalRefreshAttempts/${VideoTimingConstants.maxRefreshAttempts})',
    );
    _handleRefresh(userInitiated: false);
  }

  void _startStreamInfoTimer() {
    _streamInfoTimer?.cancel();
    _streamInfoTimer = Timer.periodic(
      VideoTimingConstants.nativeStreamInfoInterval,
      (_) => _pollStreamInfoAndRecoverIfNeeded(),
    );
  }

  void _stopStreamInfoTimer() {
    _streamInfoTimer?.cancel();
    _streamInfoTimer = null;
  }

  Future<void> _pollStreamInfoAndRecoverIfNeeded() async {
    if (_disposed) return;
    final wasOffline = _streamInfo == null;
    await updateStreamInfo(forceUpdate: true);
    if (_disposed) return;

    if (wasOffline && _streamInfo != null && settingsStore.showVideo && !_userPaused) {
      debugPrint(
        'NativeVideoStore: stream detected back online, auto-refreshing',
      );
      _handleRefresh(userInitiated: false);
    }
  }

  void _startLatencyPolling() {
    _latencyTimer?.cancel();
    _updateLatency();
    _latencyTimer = Timer.periodic(
      VideoTimingConstants.latencyPollingInterval,
      (_) => _updateLatency(),
    );
  }

  Future<void> _updateLatency() async {
    // Program-date-time readings jump around during stitched ad breaks —
    // skip the poll entirely (display, recovery, and chat sync all resume
    // on the next tick after the break ends).
    if (_isAdBreakActive) return;

    final seconds = await _controller?.getLatencyToLive();
    if (_disposed || seconds == null) return;
    final rounded = seconds.round();

    // Auto-recover when latency climbs too high (e.g. stream glitch,
    // temporary network issue). Normal live latency is under ~15s;
    // 30s+ means the player fell behind and needs intervention.
    // Intentionally skips the latency display update and chat delay
    // sync — both are stale at this point and will refresh after recovery.
    if (rounded >= VideoTimingConstants.highLatencyThresholdSeconds &&
        !_paused &&
        !_loading &&
        !_userPaused) {
      _highLatencyCount++;
      // Still high after several interventions — the reading can't be
      // trusted (device clock skew) or the device genuinely can't keep up.
      // Either way, looping seeks/refreshes forever makes playback worse.
      // The counter survives refreshes and only resets on a healthy
      // reading, so a persistent condition stops recovery permanently.
      if (_highLatencyCount >
          VideoTimingConstants.maxHighLatencyRecoveries) {
        return;
      }
      if (_isInPipMode || _highLatencyCount == 1) {
        // During PiP, only seek to live edge — handleRefresh() disposes
        // the controller which kills PiP.
        debugPrint(
          'NativeVideoStore: high latency (${rounded}s), seeking to live edge',
        );
        _controller?.seekToLiveEdge();
        _controller?.play();
      } else if (!_refreshCapReached() &&
          _backoffDelayRemaining() == Duration.zero) {
        debugPrint(
          'NativeVideoStore: latency still high (${rounded}s), refreshing '
          '(attempt ${_totalRefreshAttempts + 1}/${VideoTimingConstants.maxRefreshAttempts})',
        );
        _totalRefreshAttempts++;
        _handleRefresh(userInitiated: false);
      }
      // Within the refresh cap/backoff window — wait for the next poll.
      return;
    }
    _highLatencyCount = 0;

    final newLatency = '${seconds.toStringAsFixed(2)}s';
    if (newLatency != _latency) {
      runInAction(() {
        _latency = newLatency;
      });
    }

    // Skip chat sync when the player isn't actively progressing against
    // the live edge — a stall/pause leaves the live edge racing ahead and
    // would inflate syncedChatDelay unbounded.
    if (_paused || _loading || _userPaused || _isStalled) return;
    _chatLatencySync.report(seconds);
  }

  void _scheduleOverlayHide([
    Duration delay = VideoTimingConstants.overlayAutoHide,
  ]) {
    _overlayTimer?.cancel();

    if (_isInPipMode) {
      runInAction(() => _overlayVisible = true);
      return;
    }

    _overlayTimer = Timer(delay, () {
      if (_isInPipMode) return;
      runInAction(() {
        _overlayVisible = false;
      });
    });
  }

  @override
  @action
  void handleVideoTap() {
    if (_isInPipMode) {
      _overlayVisible = true;
      return;
    }

    _overlayTimer?.cancel();

    if (_overlayVisible) {
      _overlayVisible = false;
    } else {
      updateStreamInfo(forceUpdate: true);
      _overlayVisible = true;
      _scheduleOverlayHide();
    }
  }

  @override
  void handlePausePlay() {
    if (_pendingRefreshOnResume) {
      // The playback session died while user-paused (token expiry, media
      // services reset) — playing the dead session would no-op or error.
      _pendingRefreshOnResume = false;
      _handleRefresh(userInitiated: false);
      return;
    }
    if (_controller == null) return;
    if (_paused) {
      _userPaused = false;
      _controller!.play();
    } else {
      _userPaused = true;
      _controller!.pause();
    }
  }

  @override
  @action
  void handleToggleOverlay() {
    if (settingsStore.toggleableOverlay) {
      HapticFeedback.mediumImpact();
      settingsStore.showOverlay = !settingsStore.showOverlay;

      if (settingsStore.showOverlay) {
        _overlayVisible = true;
        _scheduleOverlayHide(VideoTimingConstants.overlayQuickHide);
      }
    }
  }

  @override
  @action
  Future<void> handleRefresh() => _handleRefresh(userInitiated: true);

  Future<void> _handleRefresh({required bool userInitiated}) {
    // Auto-recovery must never resume a stream the user paused — park the
    // refresh until they tap play (handlePausePlay consumes the flag). The
    // error paths set the flag themselves to preserve attempt counters;
    // this guard covers every other producer (e.g. the init-retry timer).
    if (!userInitiated && _userPaused) {
      _pendingRefreshOnResume = true;
      return Future<void>.value();
    }

    if (userInitiated) HapticFeedback.lightImpact();

    final wasControllerInitialized = _controllerInitialized;
    runInAction(() {
      // Reset recovery cap, cooldown, and bounce counter on user-initiated
      // refresh (error was shown). Stall recovery calls this with
      // _error == null, preserving the cap.
      if (userInitiated && _error != null) {
        _totalRefreshAttempts = 0;
        _shortPlayBounceCount = 0;
      }
      _lastRefreshTime = DateTime.now();
      // PiP state is preserved here: the light path reuses the controller
      // (flags must stay in sync with the native player) and the hard path
      // resets it via _disposeController below. _highLatencyCount survives
      // so the latency-recovery cap can stop a persistent loop; it resets
      // on the next healthy reading.
      _resetPlayerStateCommon(
        preservePipState: true,
        preserveHighLatencyCount: true,
      );
      _loading = true;
      _initializing = true;
      _initGeneration++;

      _overlayTimer?.cancel();
      _scheduleOverlayHide();
      _latencyTimer?.cancel();
      _stallRecoveryTimer?.cancel();
      _initRetryTimer?.cancel();
      _healthyPlaybackTimer?.cancel();

      if (wasControllerInitialized) return;

      // Hard refresh: controller isn't ready (init in progress or failed).
      // Tear down and rebuild from scratch.
      _isInPipMode = false;
      _lastPipWasAutomatic = false;
      _manualPipRequested = false;
      _overlayWasVisibleBeforePip = true;
      _disposeController();
      _controller = _createController();
    });

    if (wasControllerInitialized) {
      // Light refresh: reload stream on existing controller. PiP state is
      // intentionally preserved — the controller is reused, so its observable
      // PiP flags must stay in sync with the native player.
      unawaited(_reloadCurrentController());
    } else {
      unawaited(_initPlayer());
    }
    unawaited(updateStreamInfo());
    return Future<void>.value();
  }

  @override
  void requestPictureInPicture() {
    if (Platform.isAndroid) {
      // autoEnter for future background transitions is managed by the showVideo
      // reaction (setAutoPipMode) — don't also pass it here.
      _pip.enterPipMode();
    } else {
      // Skip manual PiP if the last session was auto-triggered (swipe gesture).
      // Entering manual PiP right after auto-PiP causes gray window artifacts
      // because the two PiP systems (AVPlayerViewController vs custom controller)
      // conflict on the same player.
      if (_lastPipWasAutomatic) return;
      _manualPipRequested = true;
      _controller?.enterPictureInPicture();
    }
  }

  @override
  @action
  void togglePictureInPicture() {
    if (_isInPipMode) {
      // iOS has a programmatic exit; Android does not — the user must close
      // the PiP window themselves, so the toggle is a no-op there.
      if (Platform.isIOS) _controller?.exitPictureInPicture();
      return;
    }
    requestPictureInPicture();
  }

  @override
  @action
  Future<void> updateStreamQualities() async {
    // Qualities are populated automatically via qualitiesStream.
  }

  @override
  @action
  Future<void> setStreamQuality(String quality) async {
    final index = _availableStreamQualities.indexOf(quality);
    if (index == -1) return;
    await _setStreamQualityIndex(index);
  }

  @action
  Future<void> _setStreamQualityIndex(int index) async {
    _streamQualityIndex = index;
    final controller = _controller;
    if (controller == null) return;

    _isQualitySwitching = true;
    // A resolution-only switch never interrupts playback, so no play/pause
    // event arrives to clear the flag — expire it after a grace window or
    // it sticks for the session and disables stall classification.
    _qualitySwitchGraceTimer?.cancel();
    _qualitySwitchGraceTimer = Timer(
      VideoTimingConstants.qualitySwitchGrace,
      () {
        if (_disposed) return;
        runInAction(() => _isQualitySwitching = false);
      },
    );

    if (index == 0) {
      // 'Auto' — reset to adaptive quality
      await controller.setQuality(NativeVideoPlayerQuality.auto());
    } else {
      final qualityIndex = index - 1;
      if (qualityIndex >= 0 && qualityIndex < _qualityObjects.length) {
        await controller.setQuality(_qualityObjects[qualityIndex]);
      }
    }

    // The controller can be disposed or replaced during the platform call
    // (user backs out, chat-only toggle, media services reset).
    if (_disposed || !identical(controller, _controller)) return;

    // Toggle background PiP based on audio-only mode.
    // Only call when the mode actually changes to avoid unnecessary
    // method channel round-trips on every quality switch.
    final quality = index == 0
        ? null
        : _qualityObjects.elementAtOrNull(index - 1);
    final isAudioOnly =
        quality != null && quality.width == 0 && quality.height == 0;
    if (isAudioOnly != _isAudioOnlyMode) {
      _isAudioOnlyMode = isAudioOnly;
      if (Platform.isIOS) {
        if (isAudioOnly) {
          controller.disableAutomaticInlinePip();
        } else {
          controller.enableAutomaticInlinePip();
        }
      } else if (Platform.isAndroid && _autoPipAvailable == true) {
        if (isAudioOnly) {
          _pip.setAutoPipMode(autoEnter: false);
        } else if (settingsStore.showVideo) {
          _pip.setAutoPipMode();
        }
      }
    }
  }

  void _queueOrApplyInitialQualityIndex(int index) {
    if (_hasPlayedOnce) {
      unawaited(_setStreamQualityIndex(index));
    } else {
      _pendingQualityIndex = index;
    }
  }

  @override
  @action
  Future<void> updateStreamInfo({bool forceUpdate = false}) async {
    final result = await _streamInfoPoller.fetch(forceUpdate: forceUpdate);
    if (_disposed || result == null) return;
    runInAction(() {
      if (result.stream != null) {
        _streamInfo = result.stream;
        _offlineChannelInfo = null;
        return;
      }
      if (result.offlineChannel == null) {
        return;
      }
      _overlayTimer?.cancel();
      _latencyTimer?.cancel();
      _stallRecoveryTimer?.cancel();
      _healthyPlaybackTimer?.cancel();
      _loading = false;
      _latency = null;
      _streamInfo = null;
      _offlineChannelInfo = result.offlineChannel;
      // Confirmed offline (transient errors returned above) — flush the
      // chat delay since there's no video to sync against.
      _chatLatencySync.reset();
    });
  }

  @override
  @action
  void handleAppResume() {
    if (_isInPipMode) return;
    _highLatencyCount = 0;
    updateStreamInfo(forceUpdate: true);
    if (!_userPaused && !_initializing && _controller != null) {
      _controller!.play();
    }
  }

  @override
  @action
  void handleAndroidPipChanged(bool isInPip) => _setPipActive(isInPip);

  /// Shared PiP enter/exit overlay state machine, driven by the Android
  /// activity callback and the iOS controller's PiP stream.
  void _setPipActive(bool isInPip) {
    if (isInPip && !_isInPipMode) {
      _overlayWasVisibleBeforePip = _overlayVisible;
      _isInPipMode = true;
      _overlayTimer?.cancel();
      _overlayVisible = true;
    } else if (!isInPip && _isInPipMode) {
      _isInPipMode = false;
      if (_overlayWasVisibleBeforePip) {
        _scheduleOverlayHide();
      } else {
        _overlayVisible = false;
      }
    }
  }

  @override
  @action
  void dispose() {
    _disposed = true;

    if (Platform.isAndroid && _autoPipAvailable == true) {
      _pip.setAutoPipMode(autoEnter: false);
    }

    _overlayTimer?.cancel();
    _stopStreamInfoTimer();
    _disposeAndroidAutoPipReaction?.call();
    _disposeVideoModeReaction?.call();
    _disposeController();
  }

  /// Tears down the native player and all of its observers. Releases the
  /// `AVPlayer`, deactivates the audio session (when this is the last player
  /// alive), and stops the PiP controller. Safe to call when no controller
  /// has been created.
  void _disposeController() {
    _latencyTimer?.cancel();
    _stallRecoveryTimer?.cancel();
    _initRetryTimer?.cancel();
    _healthyPlaybackTimer?.cancel();
    _qualitySwitchGraceTimer?.cancel();
    _pipSub?.cancel();
    _pipSub = null;
    _qualitiesSub?.cancel();
    _qualitiesSub = null;
    _adBreakSub?.cancel();
    _adBreakSub = null;
    _controller?.removeActivityListener(_onPlayerActivity);
    _controller?.dispose();
    _controller = null;
    _controllerInitialized = false;
    _initInFlight = false;
    _initGeneration++;
  }

  /// Resets the observable fields that have the same target value across
  /// "torn down for chat-only" and "fresh controller about to load". Caller
  /// sets the few fields that differ (`_loading`, `_initializing`).
  void _resetPlayerStateCommon({
    bool preservePipState = false,
    bool preserveHighLatencyCount = false,
  }) {
    _hasPlayedOnce = false;
    _userPaused = false;
    _pendingRefreshOnResume = false;
    _paused = true;
    _isStalled = false;
    _isAdBreakActive = false;
    _restrictedStreamQualities = [];
    _isQualitySwitching = false;
    _isAudioOnlyMode = false;
    _stallRecoveryAttempt = 0;
    if (!preserveHighLatencyCount) _highLatencyCount = 0;
    _firstTimeSettingQuality = true;
    _pendingQualityIndex = null;
    _streamQualityIndex = 0;
    _availableStreamQualities = [];
    _qualityObjects = [];
    _latency = null;
    _error = null;
    if (!preservePipState) {
      _isInPipMode = false;
      _lastPipWasAutomatic = false;
      _manualPipRequested = false;
      _overlayWasVisibleBeforePip = true;
    }
  }

  /// Resets observable display state after [_disposeController] so the UI
  /// reflects "no active player". Called only when entering chat-only mode;
  /// final disposal skips this since the store is being torn down.
  @action
  void _resetPlayerStateForChatOnly() {
    _resetPlayerStateCommon();
    _loading = false;
    _initializing = false;
    _chatLatencySync.reset();
  }

  /// Builds a brand new controller and kicks off `_initPlayer`. Used when
  /// the user toggles back to video mode after a chat-only stretch.
  @action
  void _initFreshController() {
    _resetPlayerStateCommon();
    _loading = true;
    _initializing = true;
    _controller = _createController();
    _initPlayer();
  }
}
