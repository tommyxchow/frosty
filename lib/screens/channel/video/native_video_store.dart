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
import 'package:frosty/screens/channel/video/video_player_interface.dart';
import 'package:frosty/screens/settings/stores/auth_store.dart';
import 'package:frosty/screens/settings/stores/settings_store.dart';
import 'package:mobx/mobx.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_pip_mode/simple_pip.dart';

part 'native_video_store.g.dart';

class NativeVideoStore = NativeVideoStoreBase with _$NativeVideoStore;

abstract class NativeVideoStoreBase with Store implements VideoPlayerInterface {
  static int _nextId = 0;

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
  DateTime? _lastStreamInfoUpdate;
  Future<void>? _streamInfoRequest;
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
  var _totalRefreshAttempts = 0;
  var _highLatencyCount = 0;
  var _isQualitySwitching = false;
  var _initGeneration = 0;
  static const _maxRefreshAttempts = 3;
  static const _highLatencyThresholdSeconds = 30;
  static final _bareResolutionRe = RegExp(r'^(\d+)p$');

  final _pip = SimplePip();
  ReactionDisposer? _disposeAndroidAutoPipReaction;

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
    if (settingsStore.autoSyncChatDelay) {
      settingsStore.syncedChatDelay = 0.0;
    }
    _controller = _createController();
    _scheduleOverlayHide();
    updateStreamInfo();
    _initPlayer();

    if (Platform.isAndroid) {
      _disposeAndroidAutoPipReaction = autorun((_) async {
        if (settingsStore.showVideo && await SimplePip.isAutoPipAvailable) {
          _pip.setAutoPipMode();
        } else {
          _pip.setAutoPipMode(autoEnter: false);
        }
      });
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
    controller.addActivityListener(_handleActivityEvent);
    return controller;
  }

  @action
  Future<void> _initPlayer() async {
    if (_initInFlight) return;
    _initInFlight = true;
    final generation = _initGeneration;
    try {
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

      if (_disposed || generation != _initGeneration) {
        _initInFlight = false;
        return;
      }

      _hlsUrl = twitchGqlApi.buildHlsUrl(login: userLogin, token: token);

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
        _initInFlight = false;
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
                final lastQuality = prefs.getString(kLastStreamQualityKey);
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

      await _controller!.loadUrl(url: _hlsUrl!);
      await _controller!.configureForLivePlayback();

      _startLatencyPolling();

      _initInFlight = false;
      runInAction(() {
        _error = null;
      });
    } catch (e) {
      if (_disposed || generation != _initGeneration) return;
      _initializing = false;
      _initInFlight = false;
      // Wait for stream info so we can distinguish "offline" from "broken".
      await updateStreamInfo(forceUpdate: true);
      if (_disposed || generation != _initGeneration) return;
      runInAction(() {
        _loading = false;
        // Only show the error if the stream is actually live — an offline
        // channel is expected to fail here and the overlay handles it.
        if (_streamInfo != null) {
          _error =
              'Native player failed to load. Try the standard player in Settings.';
        }
      });
      debugPrint('NativeVideoStore init error: $e');
    }
  }

  void _handleActivityEvent(PlayerActivityEvent event) {
    runInAction(() {
      switch (event.state) {
        case PlayerActivityState.playing:
          _loading = false;
          _paused = false;
          _hasPlayedOnce = true;
          _initializing = false;
          _isQualitySwitching = false;
          _stallRecoveryTimer?.cancel();
          _stallRecoveryAttempt = 0;
          _totalRefreshAttempts = 0;
          if (_pendingQualityIndex != null) {
            final index = _pendingQualityIndex!;
            _pendingQualityIndex = null;
            _setStreamQualityIndex(index);
          }
        case PlayerActivityState.buffering:
        case PlayerActivityState.loading:
          if (!_isQualitySwitching && !_hasPlayedOnce) {
            _loading = true;
          }
          // Clear _initializing on the first buffering event so the stall
          // recovery timer is not permanently blocked during init stalls.
          // The player has started loading content — if it gets stuck here,
          // the watchdog needs to be able to act.
          if (_initializing && event.state == PlayerActivityState.buffering) {
            _initializing = false;
          }
          if (!_userPaused && !_initializing) _startStallRecoveryTimer();
        case PlayerActivityState.error:
          _loading = false;
          _initializing = false;
          _isQualitySwitching = false;
          _stallRecoveryTimer?.cancel();
          // Check if the stream is actually live before showing the error —
          // an offline channel is expected to 404 and the overlay handles it.
          final errorMessage =
              event.data?['message'] as String? ??
              'Playback error. Try refreshing or switch to the standard player in Settings.';
          updateStreamInfo(forceUpdate: true).then((_) {
            if (_disposed) return;
            runInAction(() {
              if (_streamInfo != null) {
                _error = errorMessage;
              }
            });
          });
        case PlayerActivityState.paused:
        case PlayerActivityState.stopped:
        case PlayerActivityState.completed:
        case PlayerActivityState.idle:
          if (!_isInPipMode) {
            _paused = true;
          }
          _isQualitySwitching = false;
          _stallRecoveryTimer?.cancel();
        default:
          break;
      }
    });
  }

  void _startStallRecoveryTimer() {
    _stallRecoveryTimer?.cancel();
    _stallRecoveryTimer = Timer(const Duration(seconds: 8), () async {
      if (_disposed || !_loading || _userPaused || _initializing) return;

      // Before attempting recovery, check if the stream is still live.
      // When a stream ends the HLS server stops serving segments, causing
      // the player to stall indefinitely. Recovering is pointless if the
      // stream is offline — just let the overlay show the offline state.
      await updateStreamInfo(forceUpdate: true);
      if (_disposed || _streamInfo == null) return;

      _stallRecoveryAttempt++;

      // During PiP, only attempt light recovery (seek to live edge).
      // Heavy recovery (handleRefresh) disposes the controller, killing PiP.
      if (_isInPipMode) {
        if (_stallRecoveryAttempt > _maxRefreshAttempts) return;
        debugPrint('NativeVideoStore: stall in PiP, seeking to live edge');
        _controller?.seekToLiveEdge();
        _controller?.play();
        _startStallRecoveryTimer();
        return;
      }

      if (_stallRecoveryAttempt <= 1) {
        // Light recovery: seek to live edge and resume.
        debugPrint('NativeVideoStore: stall detected, seeking to live edge');
        _controller?.seekToLiveEdge();
        _controller?.play();
        _startStallRecoveryTimer();
      } else if (_totalRefreshAttempts >= _maxRefreshAttempts) {
        // Exhausted all recovery attempts — show error instead of looping.
        debugPrint('NativeVideoStore: max recovery attempts reached');
        runInAction(() {
          _loading = false;
          _error =
              'Stream stalled. Try refreshing or switch to the standard player in Settings.';
        });
      } else {
        // Heavy recovery: new HLS token + full player restart.
        _totalRefreshAttempts++;
        debugPrint(
          'NativeVideoStore: stall persists, refreshing player '
          '(attempt $_totalRefreshAttempts/$_maxRefreshAttempts)',
        );
        handleRefresh();
      }
    });
  }

  void _startLatencyPolling() {
    _latencyTimer?.cancel();
    _pollLatency();
    _latencyTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => _pollLatency(),
    );
  }

  Future<void> _pollLatency() async {
    final seconds = await _controller?.getLatencyToLive();
    if (_disposed || seconds == null) return;
    final rounded = seconds.round();

    // Auto-recover when latency climbs too high (e.g. stream glitch,
    // temporary network issue). Normal live latency is under ~15s;
    // 30s+ means the player fell behind and needs intervention.
    // Intentionally skips the latency display update and chat delay
    // sync — both are stale at this point and will refresh after recovery.
    if (rounded >= _highLatencyThresholdSeconds &&
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

    if (!settingsStore.autoSyncChatDelay) return;

    // Only update when unset or drifted by >2s to avoid restarting
    // the chat countdown on minor fluctuations.
    final current = settingsStore.syncedChatDelay;
    if (current == 0 || (seconds - current).abs() > 2) {
      settingsStore.syncedChatDelay = seconds;
    }
  }

  void _scheduleOverlayHide([Duration delay = const Duration(seconds: 5)]) {
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
        _scheduleOverlayHide(const Duration(seconds: 3));
      }
    }
  }

  @override
  @action
  Future<void> handleRefresh() async {
    if (_isInPipMode) return;
    HapticFeedback.lightImpact();
    // Reset recovery cap on user-initiated refresh (error was shown).
    // Stall recovery calls this with _error == null, preserving the cap.
    if (_error != null) {
      _totalRefreshAttempts = 0;
    }
    _loading = true;
    _paused = true;
    _hasPlayedOnce = false;
    _userPaused = false;
    _stallRecoveryAttempt = 0;
    _highLatencyCount = 0;
    _firstTimeSettingQuality = true;
    _pendingQualityIndex = null;
    _isQualitySwitching = false;
    _isInPipMode = false;
    _lastPipWasAutomatic = false;
    _manualPipRequested = false;
    _overlayWasVisibleBeforePip = true;
    _latency = null;
    _availableStreamQualities = [];
    _qualityObjects = [];
    _error = null;
    _initializing = true;
    _initInFlight = false;
    _initGeneration++;

    _pipSub?.cancel();
    _qualitiesSub?.cancel();
    _overlayTimer?.cancel();
    _scheduleOverlayHide();

    _latencyTimer?.cancel();
    _stallRecoveryTimer?.cancel();
    _controller?.removeActivityListener(_handleActivityEvent);
    _controller?.dispose();
    _controller = _createController();

    _initPlayer();
    updateStreamInfo();
  }

  @override
  void requestPictureInPicture() {
    if (Platform.isAndroid) {
      _pip.enterPipMode(autoEnter: true);
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
    if (Platform.isIOS && _isInPipMode) {
      _controller?.exitPictureInPicture();
    } else {
      requestPictureInPicture();
    }
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
  }

  @override
  @action
  Future<void> updateStreamInfo({bool forceUpdate = false}) async {
    if (_streamInfoRequest != null) {
      await _streamInfoRequest;
      return;
    }

    final now = DateTime.now();
    if (!forceUpdate && _lastStreamInfoUpdate != null) {
      final timeSince = now.difference(_lastStreamInfoUpdate!);
      if (timeSince.inSeconds < 5) return;
    }

    _lastStreamInfoUpdate = now;

    final request = _updateStreamInfoInternal();
    _streamInfoRequest = request;

    try {
      await request;
    } finally {
      if (identical(_streamInfoRequest, request)) {
        _streamInfoRequest = null;
      }
    }
  }

  Future<void> _updateStreamInfoInternal() async {
    try {
      final info = await twitchApi.getStream(userLogin: userLogin);
      if (_disposed) return;
      runInAction(() {
        _streamInfo = info;
        _offlineChannelInfo = null;
      });
    } catch (e) {
      if (_disposed) return;
      Channel? channel;
      try {
        channel = await twitchApi.getChannel(userId: userId);
      } catch (e) {
        debugPrint('NativeVideoStore: channel info fallback failed: $e');
      }
      if (_disposed) return;

      runInAction(() {
        _overlayTimer?.cancel();
        _latencyTimer?.cancel();
        _stallRecoveryTimer?.cancel();
        _loading = false;
        _latency = null;
        _streamInfo = null;
        _offlineChannelInfo = channel;
      });
    }
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

    if (Platform.isAndroid) {
      SimplePip.isAutoPipAvailable.then((isAutoPipAvailable) {
        if (isAutoPipAvailable) _pip.setAutoPipMode(autoEnter: false);
      });
    }

    _overlayTimer?.cancel();
    _latencyTimer?.cancel();
    _stallRecoveryTimer?.cancel();
    _pipSub?.cancel();
    _qualitiesSub?.cancel();
    _disposeAndroidAutoPipReaction?.call();

    _controller?.removeActivityListener(_handleActivityEvent);
    _controller?.dispose();
    _controller = null;
  }
}
