import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frosty/apis/twitch_api.dart';
import 'package:frosty/models/channel.dart';
import 'package:frosty/models/stream.dart';
import 'package:frosty/screens/settings/stores/auth_store.dart';
import 'package:frosty/screens/settings/stores/settings_store.dart';
import 'package:mobx/mobx.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_pip_mode/simple_pip.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

part 'video_store.g.dart';

class VideoStore = VideoStoreBase with _$VideoStore;

abstract class VideoStoreBase with Store {
  final TwitchApi twitchApi;

  /// The userlogin of the current channel.
  final String userLogin;

  /// The user ID of the current channel.
  final String userId;

  final AuthStore authStore;

  final SettingsStore settingsStore;

  /// The [SimplePip] instance used for initiating PiP on Android.
  final pip = SimplePip();

  var _firstTimeSettingQuality = true;

  /// The video web view params used for enabling auto play.
  late final PlatformWebViewControllerCreationParams _videoWebViewParams;

  /// The webview controller used for injecting JavaScript to control the webview and video player.
  late final WebViewController videoWebViewController =
      WebViewController.fromPlatformCreationParams(_videoWebViewParams)
        ..setBackgroundColor(Colors.black)
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..addJavaScriptChannel(
          'Latency',
          onMessageReceived: (message) {
            final receivedLatency = message.message;
            _latency = receivedLatency;

            if (!settingsStore.autoSyncChatDelay) return;

            final trimmedLatency = receivedLatency.split(' ')[0];
            final latencyAsDouble = double.tryParse(trimmedLatency);

            if (latencyAsDouble != null) {
              settingsStore.chatDelay = latencyAsDouble;
            }
          },
        )
        ..addJavaScriptChannel(
          'StreamQualities',
          onMessageReceived: (message) async {
            final data = jsonDecode(message.message) as List;
            _availableStreamQualities = data
                .map((item) => item as String)
                .toList();
            if (_firstTimeSettingQuality) {
              _firstTimeSettingQuality = false;
              if (settingsStore.defaultToHighestQuality) {
                await _setStreamQualityIndex(1);
                return;
              }
              final prefs = await SharedPreferences.getInstance();
              final lastStreamQuality = prefs.getString('last_stream_quality');
              if (lastStreamQuality == null) return;
              setStreamQuality(lastStreamQuality);
            }
          },
        )
        ..addJavaScriptChannel(
          'VideoPause',
          onMessageReceived: (message) {
            _paused = true;
            if (Platform.isAndroid) pip.setIsPlaying(false);
          },
        )
        ..addJavaScriptChannel(
          'VideoPlaying',
          onMessageReceived: (message) {
            _paused = false;
            if (Platform.isAndroid) pip.setIsPlaying(true);
            videoWebViewController.runJavaScript('''
              (function() {
                const video = document.getElementsByTagName("video")[0];
                if (video) {
                  video.muted = false;
                  video.volume = 1.0;
                  if (video.textTracks && video.textTracks.length > 0) {
                    video.textTracks[0].mode = "hidden";
                  }
                }
              })();
              ''');
          },
        )
        ..addJavaScriptChannel(
          'PipEntered',
          onMessageReceived: (message) {
            _isInPipMode = true;
          },
        )
        ..addJavaScriptChannel(
          'PipExited',
          onMessageReceived: (message) {
            _isInPipMode = false;
          },
        )
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageFinished: (url) async {
              if (url != videoUrl) return;
              // Safe evaluation of JavaScript boolean result
              final result = await videoWebViewController
                  .runJavaScriptReturningResult(
                    'window._injected ? true : false',
                  );
              final injected = result is bool
                  ? result
                  : (result.toString().toLowerCase() == 'true');
              if (injected) return;
              await videoWebViewController.runJavaScript(
                'window._injected = true;',
              );
              await initVideo();
              _acceptContentWarning();
            },
          ),
        );

  /// The timer that handles hiding the overlay automatically
  late Timer _overlayTimer;

  /// The timer that handles periodic stream info updates
  Timer? _streamInfoTimer;

  /// Tracks the last time stream info was updated to prevent double refresh
  DateTime? _lastStreamInfoUpdate;

  /// Disposes the overlay reactions.
  late final ReactionDisposer _disposeOverlayReaction;

  /// Disposes the video mode reaction for timer management.
  late final ReactionDisposer _disposeVideoModeReaction;

  ReactionDisposer? _disposeAndroidAutoPipReaction;

  /// If the video is currently paused.
  ///
  /// Does not pause or play the video, only used for rendering state of the overlay.
  @readonly
  var _paused = true;

  /// If the overlay is should be visible.
  @readonly
  var _overlayVisible = true;

  /// The current stream info, used for displaying relevant info on the overlay.
  @readonly
  StreamTwitch? _streamInfo;

  /// The offline channel info, used for displaying channel details when offline.
  @readonly
  Channel? _offlineChannelInfo;

  @readonly
  List<String> _availableStreamQualities = [];

  // The current stream quality index
  @readonly
  int _streamQualityIndex = 0;

  // The current stream quality string
  String get streamQuality =>
      _availableStreamQualities.elementAtOrNull(_streamQualityIndex) ?? 'Auto';

  @readonly
  String? _latency;

  /// Whether the app is currently in picture-in-picture mode (iOS only).
  /// On Android, this state is not tracked since there's no programmatic exit.
  @readonly
  var _isInPipMode = false;

  /// The video URL to use for the webview.
  String get videoUrl =>
      'https://player.twitch.tv/?channel=$userLogin&muted=false&parent=frosty';

  VideoStoreBase({
    required this.userLogin,
    required this.userId,
    required this.twitchApi,
    required this.authStore,
    required this.settingsStore,
  }) {
    // Reset chat delay to 0 if auto sync is already enabled to prevent starting with old values
    if (settingsStore.autoSyncChatDelay) {
      settingsStore.chatDelay = 0.0;
    }
    // Initialize the video webview params for iOS to enable video autoplay.
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      _videoWebViewParams = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      _videoWebViewParams = const PlatformWebViewControllerCreationParams();
    }

    // Initialize the video webview params for Android to enable video autoplay.
    if (videoWebViewController.platform is AndroidWebViewController) {
      (videoWebViewController.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }

    // Initialize the [_overlayTimer] to hide the overlay automatically after 5 seconds.
    _overlayTimer = Timer(
      const Duration(seconds: 5),
      () => _overlayVisible = false,
    );

    // Initialize a reaction that will reload the webview whenever the overlay is toggled.
    _disposeOverlayReaction = reaction(
      (_) => settingsStore.showOverlay,
      (_) => videoWebViewController.loadRequest(Uri.parse(videoUrl)),
    );

    // Initialize a reaction to manage stream info timer based on video mode
    _disposeVideoModeReaction = reaction((_) => settingsStore.showVideo, (
      showVideo,
    ) {
      if (showVideo) {
        // In video mode, stop the timer since overlay taps handle refreshing
        _stopStreamInfoTimer();
      } else {
        // In chat-only mode, start the timer for automatic updates
        _startStreamInfoTimer();
        // Ensure overlay timer is active for clean UI
        _overlayTimer.cancel();
        _overlayTimer = Timer(
          const Duration(seconds: 5),
          () => _overlayVisible = false,
        );
      }
    });

    // Check initial state and start timer if already in chat-only mode
    if (!settingsStore.showVideo) {
      _startStreamInfoTimer();
      _overlayTimer.cancel();
      _overlayTimer = Timer(
        const Duration(seconds: 5),
        () => _overlayVisible = false,
      );
    }

    // On Android, enable auto PiP mode (setAutoEnterEnabled) if the device supports it.
    if (Platform.isAndroid) {
      _disposeAndroidAutoPipReaction = autorun((_) async {
        if (settingsStore.showVideo && await SimplePip.isAutoPipAvailable) {
          pip.setAutoPipMode();
        } else {
          pip.setAutoPipMode(autoEnter: false);
        }
      });
    }

    updateStreamInfo();

    // Stream info timer will be started when entering chat-only mode
  }

  @action
  Future<void> updateStreamQualities() async {
    try {
      await videoWebViewController.runJavaScript(r'''
      _queuePromise(async () => {
        // Open the settings → quality submenu
        (await _asyncQuerySelector('[data-a-target="player-settings-button"]')).click();
        (await _asyncQuerySelector('[data-a-target="player-settings-menu-item-quality"]')).click();

        // Wait until at least one quality option is rendered
        await _asyncQuerySelector(
          '[data-a-target="player-settings-menu"] input[name="player-settings-submenu-quality-option"] + label'
        );

        // Grab every label, normalise whitespace, return as array
        const qualities = Array.from(
          document.querySelectorAll(
            '[data-a-target="player-settings-menu"] input[name="player-settings-submenu-quality-option"] + label'
          )
        ).map(l => l.textContent.replace(/\s+/g, ' ').trim());

        StreamQualities.postMessage(JSON.stringify(qualities));

        // Close the settings panel again
        (await _asyncQuerySelector('[data-a-target="player-settings-button"]')).click();
      });
    ''');
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @action
  Future<void> setStreamQuality(String newStreamQuality) async {
    final indexOfStreamQuality = _availableStreamQualities.indexOf(
      newStreamQuality,
    );
    if (indexOfStreamQuality == -1) return;
    await _setStreamQualityIndex(indexOfStreamQuality);
  }

  @action
  Future<void> _setStreamQualityIndex(int newStreamQualityIndex) async {
    try {
      await videoWebViewController.runJavaScript('''
        _queuePromise(async () => {
          (await _asyncQuerySelector('[data-a-target="player-settings-button"]')).click();
          (await _asyncQuerySelector('[data-a-target="player-settings-menu-item-quality"]')).click();
          await _asyncQuerySelector('[data-a-target="player-settings-submenu-quality-option"] input');
          [...document.querySelectorAll('[data-a-target="player-settings-submenu-quality-option"] input')][$newStreamQualityIndex].click();
          (await _asyncQuerySelector('[data-a-target="player-settings-button"]')).click();
        });
      ''');
      _streamQualityIndex = newStreamQualityIndex;
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> _hideDefaultOverlay() async {
    try {
      await videoWebViewController.runJavaScript('''
        {
          // Initialize observer tracking array if it doesn't exist
          if (!window._observers) {
            window._observers = [];
          }

          const hideElements = (...el) => {
            el.forEach((el) => {
              el?.style.setProperty("display", "none", "important");
            })
          }
          const hide = () => {
            const topBar = document.querySelector(".top-bar");
            const playerControls = document.querySelector(".player-controls");
            const channelDisclosures = document.querySelector("#channel-player-disclosures");
            const videoPreviewOverlay = document.querySelector('[data-a-target="player-overlay-preview-background"]');
            hideElements(topBar, playerControls, channelDisclosures, videoPreviewOverlay);
          }
          const observer = new MutationObserver(() => {
            const videoOverlay = document.querySelector('.video-player__overlay');
            if(!videoOverlay) return;
            hide();
            const videoOverlayObserver = new MutationObserver(hide);
            videoOverlayObserver.observe(videoOverlay, { childList: true, subtree: true });
            // Track the overlay observer for cleanup
            window._observers.push(videoOverlayObserver);
            observer.disconnect();
          });
          observer.observe(document.body, { childList: true, subtree: true });
          // Track the main observer for cleanup
          window._observers.push(observer);
        }
      ''');
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> _acceptContentWarning() async {
    try {
      await videoWebViewController.runJavaScript('''
        {
          (async () => {
            const warningBtn = await _asyncQuerySelector('button[data-a-target*="content-classification-gate"]', 10000);

            if (warningBtn) {
              warningBtn.click();
            }
          })();
        }
      ''');
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> _listenOnLatencyChanges() async {
    try {
      await videoWebViewController.runJavaScript('''
        _queuePromise(async () => {
          (await _asyncQuerySelector('[data-a-target="player-settings-button"]')).click();
          (await _asyncQuerySelector('[data-a-target="player-settings-menu-item-advanced"]')).click();
          (await _asyncQuerySelector('[data-a-target="player-settings-submenu-advanced-video-stats"] input')).click();
          (await _asyncQuerySelector('[data-a-target="player-overlay-video-stats"]')).style.display = "none";
          (await _asyncQuerySelector('[data-a-target="player-settings-button"]')).click();

          // Wait for and verify latency element exists
          const latencyElement = await _asyncQuerySelector('[aria-label="Latency To Broadcaster"]');
          if (!latencyElement) {
            console.warn("Latency element not found");
            return;
          }

          // Throttle latency updates to once every 5 seconds minimum
          let lastLatencyUpdate = 0;
          const LATENCY_UPDATE_INTERVAL = 5000; // 5 seconds in milliseconds

          const observer = new MutationObserver((changes) => {
            const now = Date.now();
            if (now - lastLatencyUpdate >= LATENCY_UPDATE_INTERVAL) {
              lastLatencyUpdate = now;
              Latency.postMessage(changes[0].target.textContent);
            }
          })
          observer.observe(latencyElement, { characterData: true, attributes: false, childList: false, subtree: true });
          // Track the latency observer for cleanup
          if (!window._observers) {
            window._observers = [];
          }
          window._observers.push(observer);
        });
      ''');
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  /// Initializes the video webview.
  @action
  Future<void> initVideo() async {
    if (await videoWebViewController.currentUrl() == videoUrl) {
      // Declare `window` level utility methods and add event listeners to notify the JavaScript channels when the video plays and pauses.
      try {
        await videoWebViewController.runJavaScript('''
          window._PROMISE_QUEUE = Promise.resolve();

          window._queuePromise = (method) => {
            window._PROMISE_QUEUE = window._PROMISE_QUEUE.then(method, method);
            return window._PROMISE_QUEUE;
          };
          window._asyncQuerySelector = (selector, timeout = 30000) => new Promise((resolve) => {
            let element = document.querySelector(selector);
            if (element) {
              return resolve(element);
            }

            let timeoutId;
            const cleanup = () => {
              observer.disconnect();
              if (timeoutId) clearTimeout(timeoutId);
              // Remove from tracking array with null safety
              if (window._observers) {
                const index = window._observers.indexOf(observer);
                if (index > -1) {
                  window._observers.splice(index, 1);
                }
              }
            };

            const observer = new MutationObserver(() => {
              element = document.querySelector(selector);
              if (element) {
                cleanup();
                resolve(element);
              }
            });
            observer.observe(document.body, { childList: true, subtree: true });

            // Track observer for cleanup
            if (!window._observers) {
              window._observers = [];
            }
            window._observers.push(observer);

            // Always set timeout with default of 30 seconds
            timeoutId = setTimeout(() => {
              cleanup();
              resolve(undefined);
            }, timeout);
          });

          _queuePromise(async () => {
            const videoElement = await _asyncQuerySelector("video");

            // Null check in case element was not found within timeout
            if (!videoElement) {
              console.warn("Video element not found within timeout");
              return;
            }

            // Prevent duplicate event listener registration
            if (!videoElement._listenersAdded) {
              videoElement._listenersAdded = true;

              videoElement.addEventListener("pause", () => {
                VideoPause.postMessage("video paused");
                if (videoElement.textTracks && videoElement.textTracks.length > 0) {
                  videoElement.textTracks[0].mode = "hidden";
                }
              });
              videoElement.addEventListener("playing", () => {
                VideoPlaying.postMessage("video playing");
                if (videoElement.textTracks && videoElement.textTracks.length > 0) {
                  videoElement.textTracks[0].mode = "hidden";
                }
              });

              // Add PiP event listeners for iOS
              videoElement.addEventListener("enterpictureinpicture", () => {
                PipEntered.postMessage("pip entered");
              });
              videoElement.addEventListener("leavepictureinpicture", () => {
                PipExited.postMessage("pip exited");
              });
            }

            if (!videoElement.paused) {
              VideoPlaying.postMessage("video playing");
              if (videoElement.textTracks && videoElement.textTracks.length > 0) {
                videoElement.textTracks[0].mode = "hidden";
              }
            }
          });
        ''');
        if (settingsStore.showOverlay) {
          await _hideDefaultOverlay();
          await _listenOnLatencyChanges();
          await updateStreamQualities();
        }
      } catch (e) {
        debugPrint(e.toString());
      }
    }
  }

  /// Called whenever the video/overlay is tapped.
  @action
  void handleVideoTap() {
    _overlayTimer.cancel();

    if (_overlayVisible) {
      _overlayVisible = false;
    } else {
      updateStreamInfo(forceUpdate: true);

      _overlayVisible = true;
      _overlayTimer = Timer(
        const Duration(seconds: 5),
        () => _overlayVisible = false,
      );
    }
  }

  /// Starts the periodic stream info timer for chat-only mode.
  void _startStreamInfoTimer() {
    // Only start if not already active
    if (_streamInfoTimer?.isActive != true) {
      _streamInfoTimer = Timer.periodic(
        const Duration(seconds: 60),
        (_) => updateStreamInfo(),
      );
    }
  }

  /// Stops the periodic stream info timer.
  void _stopStreamInfoTimer() {
    if (_streamInfoTimer?.isActive == true) {
      _streamInfoTimer?.cancel();
    }
  }

  /// Handles app resume event for immediate stream info refresh in chat-only mode.
  @action
  void handleAppResume() {
    // Only refresh immediately in chat-only mode
    if (!settingsStore.showVideo) {
      updateStreamInfo(forceUpdate: true);
    }
  }

  /// Updates the stream info from the Twitch API.
  ///
  /// If the stream is offline, fetches channel information to show offline details.
  /// Set [forceUpdate] to true to bypass the rate limiting check.
  @action
  Future<void> updateStreamInfo({bool forceUpdate = false}) async {
    // Rate limiting: prevent too frequent updates unless forced
    final now = DateTime.now();
    if (!forceUpdate && _lastStreamInfoUpdate != null) {
      final timeSinceLastUpdate = now.difference(_lastStreamInfoUpdate!);
      if (timeSinceLastUpdate.inSeconds < 5) {
        return; // Skip update if less than 5 seconds since last update
      }
    }

    _lastStreamInfoUpdate = now;

    try {
      _streamInfo = await twitchApi.getStream(userLogin: userLogin);
      // Clear offline info when stream is live
      _offlineChannelInfo = null;
    } catch (e) {
      _overlayTimer.cancel();
      _streamInfo = null;
      _paused = true;

      // Try to fetch offline channel information
      try {
        _offlineChannelInfo = await twitchApi.getChannel(userId: userId);
      } catch (channelError) {
        _offlineChannelInfo = null;
      }

      // Restart overlay timer in chat-only mode even on error
      if (!settingsStore.showVideo) {
        _overlayTimer = Timer(
          const Duration(seconds: 5),
          () => _overlayVisible = false,
        );
      }
    }
  }

  /// Handles the toggle overlay options.
  ///
  /// The toggle overlay option allows switching between the custom and Twitch's overlay by long-pressing the overlay.
  @action
  void handleToggleOverlay() {
    if (settingsStore.toggleableOverlay) {
      HapticFeedback.mediumImpact();

      settingsStore.showOverlay = !settingsStore.showOverlay;

      if (settingsStore.showOverlay) {
        _overlayVisible = true;

        _overlayTimer.cancel();
        _overlayTimer = Timer(
          const Duration(seconds: 3),
          () => _overlayVisible = false,
        );
      }
    }

    // Stream info timer is managed automatically by the video mode reaction
  }

  /// Refreshes the stream webview and updates the stream info.
  @action
  void handleRefresh() {
    HapticFeedback.lightImpact();
    _paused = true;
    _firstTimeSettingQuality = true;
    _isInPipMode = false;
    videoWebViewController.reload();
    updateStreamInfo();
  }

  /// Play or pause the video depending on the current state of [_paused].
  void handlePausePlay() {
    try {
      if (_paused) {
        videoWebViewController.runJavaScript(
          'document.getElementsByTagName("video")[0].play();',
        );
      } else {
        videoWebViewController.runJavaScript(
          'document.getElementsByTagName("video")[0].pause();',
        );
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  /// Initiate picture in picture if available.
  ///
  /// On Android, this will utilize the native Android PiP API.
  /// On iOS, this will utilize the web picture-in-picture API.
  void requestPictureInPicture() {
    try {
      if (Platform.isAndroid) {
        pip.enterPipMode(autoEnter: true);
      } else if (Platform.isIOS) {
        videoWebViewController.runJavaScript(
          'document.getElementsByTagName("video")[0].requestPictureInPicture();',
        );
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  /// Toggle picture-in-picture mode.
  ///
  /// If not in PiP mode, enters PiP mode.
  /// If already in PiP mode on iOS, exits PiP mode.
  /// On Android, always enters PiP mode (no programmatic exit or state tracking).
  @action
  void togglePictureInPicture() {
    try {
      if (Platform.isIOS && _isInPipMode) {
        // Exit PiP mode on iOS
        videoWebViewController.runJavaScript('''
          (function() {
            if (document.pictureInPictureElement) {
              document.exitPictureInPicture();
            }
          })();
          ''');
      } else {
        // Enter PiP mode (both iOS and Android)
        requestPictureInPicture();
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  /// Cleans up JavaScript state and observers to prevent memory leaks.
  Future<void> _cleanupJavaScript() async {
    try {
      await videoWebViewController.runJavaScript('''
        (function() {
          // Disconnect all MutationObservers created by our app
          if (window._observers) {
            window._observers.forEach(observer => observer.disconnect());
            delete window._observers;
          }

          // Clear window-level state
          delete window._PROMISE_QUEUE;
          delete window._queuePromise;
          delete window._asyncQuerySelector;
          delete window._injected;

          // Note: Video element listener cleanup is unnecessary since
          // about:blank will be loaded immediately after this (see video.dart:63-65)
        })();
      ''');
    } catch (e) {
      // Ignore errors during cleanup as the WebView may already be disposed
      debugPrint('Error during JavaScript cleanup: ${e.toString()}');
    }
  }

  @action
  Future<void> dispose() async {
    // Disable auto PiP when leaving so that we don't enter PiP on other screens.
    if (Platform.isAndroid) {
      SimplePip.isAutoPipAvailable.then((isAutoPipAvailable) {
        if (isAutoPipAvailable) pip.setAutoPipMode(autoEnter: false);
      });
    }

    _overlayTimer.cancel();
    _streamInfoTimer?.cancel();

    _disposeOverlayReaction();
    _disposeVideoModeReaction();
    _disposeAndroidAutoPipReaction?.call();

    // Clean up JavaScript state and observers
    await _cleanupJavaScript();

    // Remove all JavaScript channels to prevent memory leaks
    try {
      videoWebViewController.removeJavaScriptChannel('Latency');
      videoWebViewController.removeJavaScriptChannel('StreamQualities');
      videoWebViewController.removeJavaScriptChannel('VideoPause');
      videoWebViewController.removeJavaScriptChannel('VideoPlaying');
      videoWebViewController.removeJavaScriptChannel('PipEntered');
      videoWebViewController.removeJavaScriptChannel('PipExited');
    } catch (e) {
      // Ignore errors if channels were already removed
      debugPrint('Error removing JavaScript channels: ${e.toString()}');
    }
  }
}
