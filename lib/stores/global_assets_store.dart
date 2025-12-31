import 'package:flutter/foundation.dart';
import 'package:frosty/apis/bttv_api.dart';
import 'package:frosty/apis/ffz_api.dart';
import 'package:frosty/apis/seventv_api.dart';
import 'package:frosty/apis/twitch_api.dart';
import 'package:frosty/models/badges.dart';
import 'package:frosty/models/emotes.dart';
import 'package:mobx/mobx.dart';

part 'global_assets_store.g.dart';

/// Singleton-like store for caching global emotes and badges.
/// Provided at app root level via Provider, shared across all chat tabs.
class GlobalAssetsStore = GlobalAssetsStoreBase with _$GlobalAssetsStore;

abstract class GlobalAssetsStoreBase with Store {
  final TwitchApi twitchApi;
  final BTTVApi bttvApi;
  final FFZApi ffzApi;
  final SevenTVApi sevenTVApi;

  GlobalAssetsStoreBase({
    required this.twitchApi,
    required this.bttvApi,
    required this.ffzApi,
    required this.sevenTVApi,
  });

  // ============= Loading State =============

  /// Whether global assets have been loaded at least once.
  @readonly
  var _isLoaded = false;

  /// Whether global assets are currently being fetched.
  @readonly
  var _isLoading = false;

  /// Completer to allow multiple callers to await the same load operation.
  Future<void>? _loadingFuture;

  // ============= Global Emotes =============

  /// Global Twitch emotes.
  @readonly
  var _twitchGlobalEmotes = <Emote>[];

  /// Global 7TV emotes.
  @readonly
  var _sevenTVGlobalEmotes = <Emote>[];

  /// Global BTTV emotes.
  @readonly
  var _bttvGlobalEmotes = <Emote>[];

  /// Global FFZ emotes.
  @readonly
  var _ffzGlobalEmotes = <Emote>[];

  // ============= Global Badges =============

  /// Global Twitch badges (badge key -> ChatBadge).
  @readonly
  var _twitchGlobalBadges = <String, ChatBadge>{};

  /// BTTV badges (providerId -> ChatBadge).
  @readonly
  var _bttvBadges = <String, ChatBadge>{};

  /// FFZ badges (userId to list of ChatBadge).
  @readonly
  var _ffzBadges = <String, List<ChatBadge>>{};

  // ============= Computed Properties =============

  /// All global emotes combined into a single map (name -> Emote).
  @computed
  Map<String, Emote> get globalEmoteMap {
    final result = <String, Emote>{};
    for (final emote in _twitchGlobalEmotes) {
      result[emote.name] = emote;
    }
    for (final emote in _sevenTVGlobalEmotes) {
      result[emote.name] = emote;
    }
    for (final emote in _bttvGlobalEmotes) {
      result[emote.name] = emote;
    }
    for (final emote in _ffzGlobalEmotes) {
      result[emote.name] = emote;
    }
    return result;
  }

  // ============= Methods =============

  /// Ensures global assets are loaded. Safe to call multiple times.
  /// Returns immediately if already loaded, or waits for in-progress load.
  @action
  Future<void> ensureLoaded({
    bool showTwitchEmotes = true,
    bool showTwitchBadges = true,
    bool show7TVEmotes = true,
    bool showBTTVEmotes = true,
    bool showBTTVBadges = true,
    bool showFFZEmotes = true,
    bool showFFZBadges = true,
  }) async {
    // Already loaded - return immediately
    if (_isLoaded) return;

    // Currently loading - wait for existing operation
    if (_isLoading && _loadingFuture != null) {
      await _loadingFuture;
      return;
    }

    // Start new load operation
    _isLoading = true;
    _loadingFuture = _fetchGlobalAssets(
      showTwitchEmotes: showTwitchEmotes,
      showTwitchBadges: showTwitchBadges,
      show7TVEmotes: show7TVEmotes,
      showBTTVEmotes: showBTTVEmotes,
      showBTTVBadges: showBTTVBadges,
      showFFZEmotes: showFFZEmotes,
      showFFZBadges: showFFZBadges,
    );

    await _loadingFuture;
    _isLoading = false;
    _isLoaded = true;
    _loadingFuture = null;
  }

  /// Force refresh global assets (e.g., when settings change).
  @action
  Future<void> refresh({
    bool showTwitchEmotes = true,
    bool showTwitchBadges = true,
    bool show7TVEmotes = true,
    bool showBTTVEmotes = true,
    bool showBTTVBadges = true,
    bool showFFZEmotes = true,
    bool showFFZBadges = true,
  }) async {
    _isLoaded = false;
    await ensureLoaded(
      showTwitchEmotes: showTwitchEmotes,
      showTwitchBadges: showTwitchBadges,
      show7TVEmotes: show7TVEmotes,
      showBTTVEmotes: showBTTVEmotes,
      showBTTVBadges: showBTTVBadges,
      showFFZEmotes: showFFZEmotes,
      showFFZBadges: showFFZBadges,
    );
  }

  @action
  Future<void> _fetchGlobalAssets({
    required bool showTwitchEmotes,
    required bool showTwitchBadges,
    required bool show7TVEmotes,
    required bool showBTTVEmotes,
    required bool showBTTVBadges,
    required bool showFFZEmotes,
    required bool showFFZBadges,
  }) async {
    // Error handler for emotes
    List<Emote> onEmoteError(dynamic error) {
      debugPrint('GlobalAssetsStore emote error: $error');
      return <Emote>[];
    }

    await Future.wait([
      // Twitch global emotes
      if (showTwitchEmotes)
        twitchApi
            .getEmotesGlobal()
            .then((emotes) => _twitchGlobalEmotes = emotes)
            .catchError((e) {
              _twitchGlobalEmotes = onEmoteError(e);
              return _twitchGlobalEmotes;
            }),
      // 7TV global emotes
      if (show7TVEmotes)
        sevenTVApi
            .getEmotesGlobal()
            .then((emotes) => _sevenTVGlobalEmotes = emotes)
            .catchError((e) {
              _sevenTVGlobalEmotes = onEmoteError(e);
              return _sevenTVGlobalEmotes;
            }),
      // BTTV global emotes
      if (showBTTVEmotes)
        bttvApi
            .getEmotesGlobal()
            .then((emotes) => _bttvGlobalEmotes = emotes)
            .catchError((e) {
              _bttvGlobalEmotes = onEmoteError(e);
              return _bttvGlobalEmotes;
            }),
      // FFZ global emotes
      if (showFFZEmotes)
        ffzApi
            .getEmotesGlobal()
            .then((emotes) => _ffzGlobalEmotes = emotes)
            .catchError((e) {
              _ffzGlobalEmotes = onEmoteError(e);
              return _ffzGlobalEmotes;
            }),

      // Twitch global badges
      if (showTwitchBadges)
        twitchApi
            .getBadgesGlobal()
            .then((badges) => _twitchGlobalBadges = badges)
            .catchError((e) {
              debugPrint('GlobalAssetsStore badge error: $e');
              _twitchGlobalBadges = <String, ChatBadge>{};
              return _twitchGlobalBadges;
            }),
      // BTTV badges (global - provider ID to badge mapping)
      if (showBTTVBadges)
        bttvApi
            .getBadges()
            .then((badges) => _bttvBadges = badges)
            .catchError((e) {
              debugPrint('GlobalAssetsStore badge error: $e');
              _bttvBadges = <String, ChatBadge>{};
              return _bttvBadges;
            }),
      // FFZ badges (global - user ID to badges mapping)
      if (showFFZBadges)
        ffzApi
            .getBadges()
            .then((badges) => _ffzBadges = badges)
            .catchError((e) {
              debugPrint('GlobalAssetsStore badge error: $e');
              _ffzBadges = <String, List<ChatBadge>>{};
              return _ffzBadges;
            }),
    ]);
  }
}
