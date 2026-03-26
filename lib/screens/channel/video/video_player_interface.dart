import 'package:frosty/models/channel.dart';
import 'package:frosty/models/stream.dart';
import 'package:frosty/screens/settings/stores/settings_store.dart';

/// Abstraction over the video player store so both [VideoStore] (WebView)
/// and [NativeVideoStore] can drive the same overlay and channel UI.
abstract class VideoPlayerInterface {
  SettingsStore get settingsStore;

  bool get loading;
  bool get paused;
  bool get overlayVisible;
  bool get isInPipMode;
  bool get isAudioOnlyMode;
  StreamTwitch? get streamInfo;
  Channel? get offlineChannelInfo;
  List<String> get availableStreamQualities;
  String get streamQuality;
  String? get latency;

  void handleVideoTap();
  void handlePausePlay();
  void handleToggleOverlay();
  Future<void> handleRefresh();
  void requestPictureInPicture();
  void togglePictureInPicture();
  Future<void> updateStreamQualities();
  Future<void> setStreamQuality(String quality);
  Future<void> updateStreamInfo({bool forceUpdate});
  void handleAppResume();
  void handleAndroidPipChanged(bool isInPip);
  void dispose();
}
