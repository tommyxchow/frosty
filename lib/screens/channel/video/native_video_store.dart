import 'dart:async';
import 'dart:io';

import 'package:better_native_video_player/better_native_video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  var _stallRecoveryAttempt = 0;
  var _isStalled = false;
  Timer? _initRetryTimer;
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

  String? _hlsUrl;

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
          if (showVideo && _autoPipAvailable!) {
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

  @action
  Future<void> _initPlayer() async {
    if (_initInFlight) return;
    _initInFlight = true;
    final generation = _initGeneration;
    try {
      // Fetch profile image URL for Now Playing artwork (fire-and-forget)
      twitchApi.getUser(id: userId).then((user) {
        _profileImageUrl = user.profileImageUrl;
        if (!_disposed && _controller != null) {
          _controller!.setMediaInfo(NativeVideoPlayerMediaInfo(
            title: displayName,
            subtitle: _streamInfo?.title ?? 'Twitch',
            artworkUrl: _profileImageUrl,
          ));
        }
      }).catchError((e) {
        debugPrint('NativeVideoStore: profile image fetch failed: $e');
      });

      await _controller!.initialize();
      if (_disposed || generation != _initGeneration) {
        // Don't reset _initInFlight here — a newer generation's _initPlayer
        // may already own the flag. Only the current generation should touch it.
        return;
      }

      _pipSub = _controller!.isPipEnabledStream.listen((isPip) {
        runInAction(() {
          if (isPip && !_isInPipMode) {
            // Detect whether PiP was triggered by gesture (auto) or button (manual).
            _lastPipWasAutomatic = !_manualPipRequested;
            _manualPipRequested = false;
            _overlayWasVisibleBeforePip = _overlayVisible;
            _isInPipMode = true;
            _overlayTimer?.cancel();
            _overlayVisible = true;
          } else if (!isPip && _isInPipMode) {
            _isInPipMode = false;
            _lastPipWasAutomatic = false;
            if (_overlayWasVisibleBeforePip) {
              _scheduleOverlayHide();
            } else {
              _overlayVisible = false;
            }
          }
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
              _pendingQualityIndex = 1;
            } else {
              SharedPreferences.getInstance().then((prefs) {
                if (_disposed || _pendingQualityIndex != null) return;
                final lastQuality =
                    prefs.getString(lastStreamQualityKey(userLogin));
                if (lastQuality != null) {
                  final index = _availableStreamQualities.indexOf(lastQuality);
                  if (index != -1) _pendingQualityIndex = index;
                }
              }).catchError((e) {
                debugPrint('NativeVideoStore: failed to read last quality: $e');
              });
            }
          }
        });
      });

      _controllerInitialized = true;
    } catch (e) {
      if (_disposed || generation != _initGeneration) return;
      _initInFlight = false;
      await _handleLoadError(e, generation);
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
    } catch (e) {
      if (_disposed || generation != _initGeneration) return;
      await _handleLoadError(e, generation);
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
        token = await twitchGqlApi.getPlaybackAccessToken(login: userLogin);
      } else {
        rethrow;
      }
    }

    if (_disposed || generation != _initGeneration || !settingsStore.showVideo) {
      return;
    }
    _hlsUrl = twitchGqlApi.buildHlsUrl(login: userLogin, token: token);

    await _controller!.loadUrl(url: _hlsUrl!);
    if (_disposed || generation != _initGeneration || !settingsStore.showVideo) {
      return;
    }
    await _controller!.configureForLivePlayback();
    _startLatencyPolling();
  }

  /// Shared error handler for both `_initPlayer` and `_reloadCurrentController`.
  /// Checks stream liveness, auto-retries if CDN is still serving stale
  /// manifests, or surfaces the error with the overlay visible.
  Future<void> _handleLoadError(dynamic e, int generation) async {
    _initializing = false;
    // Wait for stream info so we can distinguish "offline" from "broken".
    await updateStreamInfo(forceUpdate: true);
    if (_disposed || generation != _initGeneration) return;
    debugPrint('NativeVideoStore load error: $e');

    // Auto-retry if the stream is live — the CDN may still be serving
    // stale manifests right after a stream crash.
    if (_streamInfo != null && _totalRefreshAttempts < VideoTimingConstants.maxRefreshAttempts) {
      _totalRefreshAttempts++;
      debugPrint(
        'NativeVideoStore: auto-retrying load '
        '(attempt $_totalRefreshAttempts/${VideoTimingConstants.maxRefreshAttempts})',
      );
      _initRetryTimer?.cancel();
      _initRetryTimer = Timer(VideoTimingConstants.initRetryDelay, () {
        if (!_disposed && generation == _initGeneration) handleRefresh();
      });
      return;
    }

    runInAction(() {
      _loading = false;
      _paused = true;
      // Only show the error if the stream is actually live — an offline
      // channel is expected to fail here and the overlay handles it.
      if (_streamInfo != null) {
        _error =
            'Native player failed to load. Try the standard player in Settings.';
        _overlayVisible = true;
        _overlayTimer?.cancel();
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
    _totalRefreshAttempts = 0;
    _lastPlayingStart = DateTime.now();
    if (_pendingQualityIndex != null) {
      final index = _pendingQualityIndex!;
      _pendingQualityIndex = null;
      _setStreamQualityIndex(index);
    }
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
      _recordShortPlayBounceIfNeeded();
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
    final statusCode = eventData?['statusCode'] as int?;

    // 4xx on the HLS fetch means the current playback session is gone — a
    // fresh GQL token + new query params can land on a different CDN edge
    // with a working manifest. Skip the user-facing error and retry
    // immediately (handleRefresh updates _lastRefreshTime itself).
    if (statusCode != null &&
        statusCode >= 400 &&
        statusCode < 500 &&
        !_isWithinRecoveryCap()) {
      _totalRefreshAttempts++;
      handleRefresh();
      return;
    }

    // Check stream liveness before showing the error — an offline channel
    // is expected to 404 and the overlay handles it.
    updateStreamInfo(forceUpdate: true).then((_) {
      if (_disposed) return;
      runInAction(() {
        if (_streamInfo != null) {
          _error = errorMessage;
          _overlayVisible = true;
          _overlayTimer?.cancel();
        }
      });
    });
  }

  bool _isWithinRecoveryCap() =>
      _totalRefreshAttempts >= VideoTimingConstants.maxRefreshAttempts;

  void _onPaused() {
    if (!_isInPipMode) {
      _paused = true;
    }
    _isStalled = false;
    _isQualitySwitching = false;
    _stallRecoveryTimer?.cancel();
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

    // When a stream ends the HLS server stops serving segments, causing
    // the player to stall indefinitely. Skip recovery if the stream is
    // offline — the overlay handles that state.
    await updateStreamInfo(forceUpdate: true);
    if (_disposed || _streamInfo == null) return;

    _stallRecoveryAttempt++;

    if (_stallRecoveryAttempt <= 1) {
      _recoverBySeekingToLiveEdge();
    } else if (_totalRefreshAttempts >=
        VideoTimingConstants.maxRefreshAttempts) {
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
      _error = bouncing
          ? 'Twitch is having trouble with this channel right now. Try again in a moment, or switch to the standard player in Settings.'
          : 'Stream stalled. Try refreshing or switch to the standard player in Settings.';
      _overlayVisible = true;
      _overlayTimer?.cancel();
    });
  }

  /// If a stall arrives within [shortPlayWindow] of the last `_onPlaying`,
  /// count it as a bounce. Three bounces in a row flips the stall-error
  /// message to the CDN-trouble variant.
  void _recordShortPlayBounceIfNeeded() {
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
    handleRefresh();
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
      if (_isInPipMode || _highLatencyCount == 1) {
        // During PiP, only seek to live edge — handleRefresh() disposes
        // the controller which kills PiP.
        debugPrint(
          'NativeVideoStore: high latency (${rounded}s), seeking to live edge',
        );
        _controller?.seekToLiveEdge();
        _controller?.play();
      } else {
        debugPrint(
          'NativeVideoStore: latency still high (${rounded}s), refreshing',
        );
        _highLatencyCount = 0;
        handleRefresh();
      }
      return;
    }
    _highLatencyCount = 0;

    final newLatency = '${rounded}s';
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
  Future<void> handleRefresh() async {
    HapticFeedback.lightImpact();
    // Reset recovery cap, cooldown, and bounce counter on user-initiated
    // refresh (error was shown). Stall recovery calls this with
    // _error == null, preserving the cap.
    if (_error != null) {
      _totalRefreshAttempts = 0;
      _shortPlayBounceCount = 0;
    }
    _lastRefreshTime = DateTime.now();
    _loading = true;
    _paused = true;
    _isStalled = false;
    _hasPlayedOnce = false;
    _userPaused = false;
    _stallRecoveryAttempt = 0;
    _highLatencyCount = 0;
    _firstTimeSettingQuality = true;
    _pendingQualityIndex = null;
    _isQualitySwitching = false;
    _isAudioOnlyMode = false;
    _streamQualityIndex = 0;
    _latency = null;
    _availableStreamQualities = [];
    _qualityObjects = [];
    _error = null;
    _initializing = true;
    _initGeneration++;

    _overlayTimer?.cancel();
    _scheduleOverlayHide();
    _latencyTimer?.cancel();
    _stallRecoveryTimer?.cancel();
    _initRetryTimer?.cancel();

    if (_controllerInitialized) {
      // Light refresh: reload stream on existing controller. PiP state is
      // intentionally preserved — the controller is reused, so its observable
      // PiP flags must stay in sync with the native player.
      _reloadCurrentController();
    } else {
      // Hard refresh: controller isn't ready (init in progress or failed).
      // Tear down and rebuild from scratch.
      _isInPipMode = false;
      _lastPipWasAutomatic = false;
      _manualPipRequested = false;
      _overlayWasVisibleBeforePip = true;
      _controllerInitialized = false;
      _initInFlight = false;
      _pipSub?.cancel();
      _qualitiesSub?.cancel();
      _controller?.removeActivityListener(_onPlayerActivity);
      _controller?.dispose();
      _controller = _createController();
      _initPlayer();
    }
    updateStreamInfo();
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
    if (_controller == null) return;

    _isQualitySwitching = true;

    if (index == 0) {
      // 'Auto' — reset to adaptive quality
      await _controller!.setQuality(NativeVideoPlayerQuality.auto());
    } else {
      final qualityIndex = index - 1;
      if (qualityIndex >= 0 && qualityIndex < _qualityObjects.length) {
        await _controller!.setQuality(_qualityObjects[qualityIndex]);
      }
    }

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
          _controller!.disableAutomaticInlinePip();
        } else {
          _controller!.enableAutomaticInlinePip();
        }
      } else if (Platform.isAndroid) {
        if (isAudioOnly) {
          _pip.setAutoPipMode(autoEnter: false);
        } else if (settingsStore.showVideo) {
          _pip.setAutoPipMode();
        }
      }
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
      _overlayTimer?.cancel();
      _latencyTimer?.cancel();
      _stallRecoveryTimer?.cancel();
      _loading = false;
      _latency = null;
      _streamInfo = null;
      _offlineChannelInfo = result.offlineChannel;
      // Only flush chat delay on confirmed-offline (offlineChannel != null).
      // Transient network errors leave chat state untouched.
      if (result.offlineChannel != null) _chatLatencySync.reset();
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
  void handleAndroidPipChanged(bool isInPip) {
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
    _pipSub?.cancel();
    _pipSub = null;
    _qualitiesSub?.cancel();
    _qualitiesSub = null;
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
  void _resetPlayerStateCommon() {
    _hasPlayedOnce = false;
    _userPaused = false;
    _paused = true;
    _isStalled = false;
    _isQualitySwitching = false;
    _isAudioOnlyMode = false;
    _stallRecoveryAttempt = 0;
    _highLatencyCount = 0;
    _firstTimeSettingQuality = true;
    _pendingQualityIndex = null;
    _streamQualityIndex = 0;
    _availableStreamQualities = [];
    _qualityObjects = [];
    _latency = null;
    _error = null;
    _isInPipMode = false;
    _lastPipWasAutomatic = false;
    _manualPipRequested = false;
    _overlayWasVisibleBeforePip = true;
  }

  /// Resets observable display state after [_disposeController] so the UI
  /// reflects "no active player". Called only when entering chat-only mode;
  /// final disposal skips this since the store is being torn down.
  @action
  void _resetPlayerStateForChatOnly() {
    _resetPlayerStateCommon();
    _loading = false;
    _initializing = false;
    _hlsUrl = null;
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
