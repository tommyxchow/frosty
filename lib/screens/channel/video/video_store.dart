import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frosty/apis/twitch_api.dart';
import 'package:frosty/models/stream.dart';
import 'package:frosty/screens/settings/stores/auth_store.dart';
import 'package:frosty/screens/settings/stores/settings_store.dart';
import 'package:mobx/mobx.dart';
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

  /// The video web view params used for enabling auto play.
  late final PlatformWebViewControllerCreationParams _videoWebViewParams;

  /// The webview controller used for injecting JavaScript to control the webview and video player.
  late final WebViewController videoWebViewController =
      WebViewController.fromPlatformCreationParams(_videoWebViewParams)
        ..setBackgroundColor(Colors.black)
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..addJavaScriptChannel(
          'StreamQualities',
          onMessageReceived: (message) {
            final data = jsonDecode(message.message) as List;
            _availableStreamQualities =
                data.map((item) => item as String).toList();
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
            onPageFinished: (_) => initVideo(),
          ),
        );

  /// The timer that handles hiding the overlay automatically
  late Timer _overlayTimer;

  /// Disposes the overlay reactions.
  late final ReactionDisposer _disposeOverlayReaction;

  /// If the video is currently paused.
  ///
  /// Does not pause or play the video, only used for rendering state of the overlay.
  @readonly
  var _paused = true;

  /// If the overlay is should be visible.
  @readonly
  var _overlayVisible = true;

  /// If the current device is iPad.
  @readonly
  var _isIPad = false;

  /// The current stream info, used for displaying relevant info on the overlay.
  @readonly
  StreamTwitch? _streamInfo;

  @readonly
  List<String> _availableStreamQualities = [];

  // The current stream quality string
  @readonly
  String _streamQuality = 'Auto';

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

    // On Android, enable auto PiP mode (setAutoEnterEnabled) if the device supports it.
    if (Platform.isAndroid) {
      SimplePip.isAutoPipAvailable.then((isAutoPipAvailable) {
        if (isAutoPipAvailable) pip.setAutoPipMode();
      });
    }

    // Initialize the [_overlayTimer] to hide the overlay automatically after 5 seconds.
    _overlayTimer =
        Timer(const Duration(seconds: 5), () => _overlayVisible = false);

    // Initialize a reaction that will reload the webview whenever the overlay is toggled.
    _disposeOverlayReaction = reaction(
      (_) => settingsStore.showOverlay,
      (_) => videoWebViewController.loadRequest(Uri.parse(videoUrl)),
    );

    updateStreamInfo();
  }

  @action
  Future<void> updateStreamQualities() async {
    try {
      await videoWebViewController.runJavaScript('''
        {
          document.querySelector('[data-a-target="player-settings-button"]').click();
          document.querySelector('[data-a-target="player-settings-menu-item-quality"]').click();
          const qualities = [...document.querySelectorAll('[data-a-target="player-settings-submenu-quality-option"] label div')].map((el) => el.textContent);
          document.querySelector('.tw-drop-down-menu-item-figure').click();
          document.querySelector('[data-a-target="player-settings-menu"] [role="menuitem"] button').click();
          StreamQualities.postMessage(JSON.stringify(qualities));
        }
      ''');
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @action
  Future<void> setStreamQuality(String newStreamQuality) async {
    final indexOfStreamQuality =
        _availableStreamQualities.indexOf(newStreamQuality);
    await videoWebViewController.runJavaScript('''
        document.querySelector('[data-a-target="player-settings-button"]').click();
        document.querySelector('[data-a-target="player-settings-menu-item-quality"]').click();
        [...document.querySelectorAll('[data-a-target="player-settings-submenu-quality-option"] input')][$indexOfStreamQuality].click();
        document.querySelector('.tw-drop-down-menu-item-figure').click();
        document.querySelector('[data-a-target="player-settings-menu"] [role="menuitem"] button').click();
      ''');
    _streamQuality = newStreamQuality;
  }

  /// Initializes the video webview.
  @action
  Future<void> initVideo() async {
    if (await videoWebViewController.currentUrl() == videoUrl) {
      // Add event listeners to notify the JavaScript channels when the video plays and pauses.
      try {
        videoWebViewController.runJavaScript(
          '''document.getElementsByTagName("video")[0].addEventListener("pause", () => {
              VideoPause.postMessage("video paused");
              document.getElementsByTagName("video")[0].textTracks[0].mode = "hidden";
          });''',
        );
        videoWebViewController.runJavaScript(
          '''document.getElementsByTagName("video")[0].addEventListener("playing", () => {
              VideoPlaying.postMessage("video playing")
              document.getElementsByTagName("video")[0].textTracks[0].mode = "hidden";
          });''',
        );
        if (settingsStore.showOverlay) {
          videoWebViewController.runJavaScript('''
            {
              const observer = new MutationObserver(() => {
                const classificationGate = document.querySelector('[data-a-target="content-classification-gate-overlay"]');
                if(classificationGate) return;
                const overlay = document.querySelector('.video-player__overlay');
                if(!overlay) return;
                overlay.style.display = "none";
                observer.disconnect();
              });
              observer.observe(document.body, { childList: true, subtree: true });
            }
          ''');
        }
      } catch (e) {
        debugPrint(e.toString());
      }
    }

    // Determine whether the device is an iPad or not.
    // Used to show or hide the rotate button on the overlay.
    // Flutter doesn't allow programmatic rotation on iPad unless multitasking is disabled.
    if (Platform.isIOS) {
      final deviceInfo = DeviceInfoPlugin();
      final info = await deviceInfo.iosInfo;
      if (info.model.toLowerCase().contains('ipad')) {
        _isIPad = true;
      } else {
        _isIPad = false;
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

    _disposeOverlayReaction();
  }
}
