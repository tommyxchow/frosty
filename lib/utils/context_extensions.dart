import 'package:flutter/material.dart';
import 'package:frosty/apis/bttv_api.dart';
import 'package:frosty/apis/ffz_api.dart';
import 'package:frosty/apis/seventv_api.dart';
import 'package:frosty/apis/twitch_api.dart';
import 'package:frosty/screens/settings/stores/auth_store.dart';
import 'package:frosty/screens/settings/stores/settings_store.dart';
import 'package:frosty/stores/global_assets_store.dart';
import 'package:provider/provider.dart';

/// Static utility class for orientation-related operations
class OrientationUtils {
  /// Gets the current orientation from the given context
  static Orientation getCurrentOrientation(BuildContext context) {
    return MediaQuery.of(context).orientation;
  }

  /// Returns true if the current orientation is portrait
  static bool isPortrait(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }

  /// Returns true if the current orientation is landscape
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }
}

/// Comprehensive context extensions for common Flutter patterns
extension ContextExtensions on BuildContext {
  // ===== THEME & STYLING =====

  /// Gets the current theme
  ThemeData get theme => Theme.of(this);

  /// Gets the current color scheme
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// Gets the current text theme
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// Gets the scaffold background color
  Color get scaffoldColor => Theme.of(this).scaffoldBackgroundColor;

  /// Gets body small text color (commonly used for secondary text)
  Color? get bodySmallColor => Theme.of(this).textTheme.bodySmall?.color;

  /// Gets the default text style
  TextStyle get defaultTextStyle => DefaultTextStyle.of(this).style;

  // ===== SCREEN & LAYOUT =====

  /// Gets the screen width
  double get screenWidth => MediaQuery.of(this).size.width;

  /// Gets the screen height
  double get screenHeight => MediaQuery.of(this).size.height;

  /// Gets the safe area padding top (commonly used)
  double get safePaddingTop => MediaQuery.of(this).padding.top;

  /// Gets the safe area padding bottom (commonly used)
  double get safePaddingBottom => MediaQuery.of(this).padding.bottom;

  // ===== PROVIDER ACCESS =====

  /// Gets TwitchApi from provider
  TwitchApi get twitchApi => read<TwitchApi>();

  /// Gets AuthStore from provider
  AuthStore get authStore => read<AuthStore>();

  /// Gets SettingsStore from provider
  SettingsStore get settingsStore => read<SettingsStore>();

  /// Gets FFZApi from provider
  FFZApi get ffzApi => read<FFZApi>();

  /// Gets BTTVApi from provider
  BTTVApi get bttvApi => read<BTTVApi>();

  /// Gets SevenTVApi from provider
  SevenTVApi get sevenTVApi => read<SevenTVApi>();

  /// Gets GlobalAssetsStore from provider
  GlobalAssetsStore get globalAssetsStore => read<GlobalAssetsStore>();

  // ===== ORIENTATION =====

  /// Returns true if currently in portrait orientation
  bool get isPortrait => OrientationUtils.isPortrait(this);

  /// Returns true if currently in landscape orientation
  bool get isLandscape => OrientationUtils.isLandscape(this);
}

/// TextScaler extensions for common scaling operations
extension TextScalerExtensions on double {
  /// Creates a linear text scaler with this scale factor
  TextScaler get textScaler => TextScaler.linear(this);
}
