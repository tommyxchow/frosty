import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frosty/apis/twitch_api.dart';
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
            _availableStreamQualities =
                data.map((item) => item as String).toList();
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
            videoWebViewController.runJavaScript(
              'document.getElementsByTagName("video")[0].muted = false;',
            );
            videoWebViewController.runJavaScript(
              'document.getElementsByTagName("video")[0].volume = 1.0;',
            );
          },
        )
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageFinished: (url) async {
              if (url != videoUrl) return;
              final injected =
                  (await videoWebViewController.runJavaScriptReturningResult(
                'window._injected ? true : false',
              )) as bool;
              if (injected) return;
              await videoWebViewController
                  .runJavaScript('window._injected = true;');
              await initVideo();
              _acceptContentWarning();
            },
          ),
        );

  /// The timer that handles hiding the overlay automatically
  late Timer _overlayTimer;

  /// Disposes the overlay reactions.
  late final ReactionDisposer _disposeOverlayReaction;

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

  /// The video URL to use for the webview.
  String get videoUrl =>
      'https://player.twitch.tv/?channel=$userLogin&muted=false&parent=frosty';

  VideoStoreBase({
    required this.userLogin,
    required this.twitchApi,
    required this.authStore,
    required this.settingsStore,
  }) {
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
    _overlayTimer =
        Timer(const Duration(seconds: 5), () => _overlayVisible = false);

    // Initialize a reaction that will reload the webview whenever the overlay is toggled.
    _disposeOverlayReaction = reaction(
      (_) => settingsStore.showOverlay,
      (_) => videoWebViewController.loadRequest(Uri.parse(videoUrl)),
    );

    // On Android, enable auto PiP mode (setAutoEnterEnabled) if the device supports it.
    if (Platform.isAndroid) {
      _disposeAndroidAutoPipReaction = autorun(
        (_) async {
          if (settingsStore.showVideo && await SimplePip.isAutoPipAvailable) {
            pip.setAutoPipMode();
          } else {
            pip.setAutoPipMode(autoEnter: false);
          }
        },
      );
    }

    updateStreamInfo();
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
    final indexOfStreamQuality =
        _availableStreamQualities.indexOf(newStreamQuality);
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
          const hideElements = (...el) => {
            el.forEach((el) => {
              el?.style.setProperty("display", "none", "important");
            })
          }
          const hide = () => {
            const topBar = document.querySelector(".top-bar");
            const playerControls = document.querySelector(".player-controls");
            const channelDisclosures = document.querySelector("#channel-player-disclosures");
            hideElements(topBar, playerControls, channelDisclosures);
          }
          const observer = new MutationObserver(() => {
            const videoOverlay = document.querySelector('.video-player__overlay');
            if(!videoOverlay) return;
            hide();
            const videoOverlayObserver = new MutationObserver(hide);
            videoOverlayObserver.observe(videoOverlay, { childList: true, subtree: true });
            observer.disconnect();
          });
          observer.observe(document.body, { childList: true, subtree: true });
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
          const observer = new MutationObserver((changes) => {
            Latency.postMessage(changes[0].target.textContent);
          })
          observer.observe(document.querySelector('[aria-label="Latency To Broadcaster"]'), { characterData: true, attributes: false, childList: false, subtree: true });
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
          window._asyncQuerySelector = (selector, timeout = undefined) => new Promise((resolve) => {
            let element = document.querySelector(selector);
            if (element) {
              return resolve(element);
            }
            const observer = new MutationObserver(() => {
              element = document.querySelector(selector);
              if (element) {
                observer.disconnect();
                resolve(element);
              }
            });
            observer.observe(document.body, { childList: true, subtree: true });
            if (timeout) {
              setTimeout(() => {
                observer.disconnect();
                resolve(undefined);
              }, timeout);
            }
          });

          _queuePromise(async () => {
            const videoElement = await _asyncQuerySelector("video");
            videoElement.addEventListener("pause", () => {
              VideoPause.postMessage("video paused");
              videoElement.textTracks[0].mode = "hidden";
            });
            videoElement.addEventListener("playing", () => {
              VideoPlaying.postMessage("video playing");
              videoElement.textTracks[0].mode = "hidden";
            });
            if (!videoElement.paused) {
              VideoPlaying.postMessage("video playing");
              videoElement.textTracks[0].mode = "hidden";
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
      updateStreamInfo();

      _overlayVisible = true;
      _overlayTimer =
          Timer(const Duration(seconds: 5), () => _overlayVisible = false);
    }
  }

  /// Updates the stream info from the Twitch API.
  ///
  /// If the stream is offline, disables the overlay.
  @action
  Future<void> updateStreamInfo() async {
    try {
      _streamInfo = await twitchApi.getStream(
        userLogin: userLogin,
        headers: authStore.headersTwitch,
      );
    } catch (e) {
      debugPrint(e.toString());

      _overlayTimer.cancel();
      _streamInfo = null;
      _paused = true;
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
        _overlayTimer =
            Timer(const Duration(seconds: 3), () => _overlayVisible = false);
      }
    }
  }

  /// Refreshes the stream webview and updates the stream info.
  @action
  void handleRefresh() {
    HapticFeedback.lightImpact();
    _paused = true;
    _firstTimeSettingQuality = true;
    videoWebViewController.reload();
    updateStreamInfo();
  }

  /// Play or pause the video depending on the current state of [_paused].
  void handlePausePlay() {
    try {
      if (_paused) {
        videoWebViewController
            .runJavaScript('document.getElementsByTagName("video")[0].play();');
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

  @action
  void dispose() {
    // Disable auto PiP when leaving so that we don't enter PiP on other screens.
    if (Platform.isAndroid) {
      SimplePip.isAutoPipAvailable.then((isAutoPipAvailable) {
        if (isAutoPipAvailable) pip.setAutoPipMode(autoEnter: false);
      });
    }

    _overlayTimer.cancel();

    _disposeOverlayReaction();
    _disposeAndroidAutoPipReaction?.call();
  }
}
