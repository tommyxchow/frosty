import 'package:frosty/screens/channel/video/video_player_interface.dart';

/// Capabilities that only the native player can meaningfully support.
/// Callers that need these must type-check against this interface.
abstract class NativeVideoPlayerInterface extends VideoPlayerInterface {
  /// Whether the current quality is an HLS audio-only variant.
  bool get isAudioOnlyMode;
}
