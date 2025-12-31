// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'global_assets_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$GlobalAssetsStore on GlobalAssetsStoreBase, Store {
  Computed<Map<String, Emote>>? _$globalEmoteMapComputed;

  @override
  Map<String, Emote> get globalEmoteMap =>
      (_$globalEmoteMapComputed ??= Computed<Map<String, Emote>>(
        () => super.globalEmoteMap,
        name: 'GlobalAssetsStoreBase.globalEmoteMap',
      )).value;

  late final _$_isLoadedAtom = Atom(
    name: 'GlobalAssetsStoreBase._isLoaded',
    context: context,
  );

  bool get isLoaded {
    _$_isLoadedAtom.reportRead();
    return super._isLoaded;
  }

  @override
  bool get _isLoaded => isLoaded;

  @override
  set _isLoaded(bool value) {
    _$_isLoadedAtom.reportWrite(value, super._isLoaded, () {
      super._isLoaded = value;
    });
  }

  late final _$_isLoadingAtom = Atom(
    name: 'GlobalAssetsStoreBase._isLoading',
    context: context,
  );

  bool get isLoading {
    _$_isLoadingAtom.reportRead();
    return super._isLoading;
  }

  @override
  bool get _isLoading => isLoading;

  @override
  set _isLoading(bool value) {
    _$_isLoadingAtom.reportWrite(value, super._isLoading, () {
      super._isLoading = value;
    });
  }

  late final _$_twitchGlobalEmotesAtom = Atom(
    name: 'GlobalAssetsStoreBase._twitchGlobalEmotes',
    context: context,
  );

  List<Emote> get twitchGlobalEmotes {
    _$_twitchGlobalEmotesAtom.reportRead();
    return super._twitchGlobalEmotes;
  }

  @override
  List<Emote> get _twitchGlobalEmotes => twitchGlobalEmotes;

  @override
  set _twitchGlobalEmotes(List<Emote> value) {
    _$_twitchGlobalEmotesAtom.reportWrite(value, super._twitchGlobalEmotes, () {
      super._twitchGlobalEmotes = value;
    });
  }

  late final _$_sevenTVGlobalEmotesAtom = Atom(
    name: 'GlobalAssetsStoreBase._sevenTVGlobalEmotes',
    context: context,
  );

  List<Emote> get sevenTVGlobalEmotes {
    _$_sevenTVGlobalEmotesAtom.reportRead();
    return super._sevenTVGlobalEmotes;
  }

  @override
  List<Emote> get _sevenTVGlobalEmotes => sevenTVGlobalEmotes;

  @override
  set _sevenTVGlobalEmotes(List<Emote> value) {
    _$_sevenTVGlobalEmotesAtom.reportWrite(
      value,
      super._sevenTVGlobalEmotes,
      () {
        super._sevenTVGlobalEmotes = value;
      },
    );
  }

  late final _$_bttvGlobalEmotesAtom = Atom(
    name: 'GlobalAssetsStoreBase._bttvGlobalEmotes',
    context: context,
  );

  List<Emote> get bttvGlobalEmotes {
    _$_bttvGlobalEmotesAtom.reportRead();
    return super._bttvGlobalEmotes;
  }

  @override
  List<Emote> get _bttvGlobalEmotes => bttvGlobalEmotes;

  @override
  set _bttvGlobalEmotes(List<Emote> value) {
    _$_bttvGlobalEmotesAtom.reportWrite(value, super._bttvGlobalEmotes, () {
      super._bttvGlobalEmotes = value;
    });
  }

  late final _$_ffzGlobalEmotesAtom = Atom(
    name: 'GlobalAssetsStoreBase._ffzGlobalEmotes',
    context: context,
  );

  List<Emote> get ffzGlobalEmotes {
    _$_ffzGlobalEmotesAtom.reportRead();
    return super._ffzGlobalEmotes;
  }

  @override
  List<Emote> get _ffzGlobalEmotes => ffzGlobalEmotes;

  @override
  set _ffzGlobalEmotes(List<Emote> value) {
    _$_ffzGlobalEmotesAtom.reportWrite(value, super._ffzGlobalEmotes, () {
      super._ffzGlobalEmotes = value;
    });
  }

  late final _$_twitchGlobalBadgesAtom = Atom(
    name: 'GlobalAssetsStoreBase._twitchGlobalBadges',
    context: context,
  );

  Map<String, ChatBadge> get twitchGlobalBadges {
    _$_twitchGlobalBadgesAtom.reportRead();
    return super._twitchGlobalBadges;
  }

  @override
  Map<String, ChatBadge> get _twitchGlobalBadges => twitchGlobalBadges;

  @override
  set _twitchGlobalBadges(Map<String, ChatBadge> value) {
    _$_twitchGlobalBadgesAtom.reportWrite(value, super._twitchGlobalBadges, () {
      super._twitchGlobalBadges = value;
    });
  }

  late final _$_bttvBadgesAtom = Atom(
    name: 'GlobalAssetsStoreBase._bttvBadges',
    context: context,
  );

  Map<String, ChatBadge> get bttvBadges {
    _$_bttvBadgesAtom.reportRead();
    return super._bttvBadges;
  }

  @override
  Map<String, ChatBadge> get _bttvBadges => bttvBadges;

  @override
  set _bttvBadges(Map<String, ChatBadge> value) {
    _$_bttvBadgesAtom.reportWrite(value, super._bttvBadges, () {
      super._bttvBadges = value;
    });
  }

  late final _$_ffzBadgesAtom = Atom(
    name: 'GlobalAssetsStoreBase._ffzBadges',
    context: context,
  );

  Map<String, List<ChatBadge>> get ffzBadges {
    _$_ffzBadgesAtom.reportRead();
    return super._ffzBadges;
  }

  @override
  Map<String, List<ChatBadge>> get _ffzBadges => ffzBadges;

  @override
  set _ffzBadges(Map<String, List<ChatBadge>> value) {
    _$_ffzBadgesAtom.reportWrite(value, super._ffzBadges, () {
      super._ffzBadges = value;
    });
  }

  late final _$ensureLoadedAsyncAction = AsyncAction(
    'GlobalAssetsStoreBase.ensureLoaded',
    context: context,
  );

  @override
  Future<void> ensureLoaded({
    bool showTwitchEmotes = true,
    bool showTwitchBadges = true,
    bool show7TVEmotes = true,
    bool showBTTVEmotes = true,
    bool showBTTVBadges = true,
    bool showFFZEmotes = true,
    bool showFFZBadges = true,
  }) {
    return _$ensureLoadedAsyncAction.run(
      () => super.ensureLoaded(
        showTwitchEmotes: showTwitchEmotes,
        showTwitchBadges: showTwitchBadges,
        show7TVEmotes: show7TVEmotes,
        showBTTVEmotes: showBTTVEmotes,
        showBTTVBadges: showBTTVBadges,
        showFFZEmotes: showFFZEmotes,
        showFFZBadges: showFFZBadges,
      ),
    );
  }

  late final _$refreshAsyncAction = AsyncAction(
    'GlobalAssetsStoreBase.refresh',
    context: context,
  );

  @override
  Future<void> refresh({
    bool showTwitchEmotes = true,
    bool showTwitchBadges = true,
    bool show7TVEmotes = true,
    bool showBTTVEmotes = true,
    bool showBTTVBadges = true,
    bool showFFZEmotes = true,
    bool showFFZBadges = true,
  }) {
    return _$refreshAsyncAction.run(
      () => super.refresh(
        showTwitchEmotes: showTwitchEmotes,
        showTwitchBadges: showTwitchBadges,
        show7TVEmotes: show7TVEmotes,
        showBTTVEmotes: showBTTVEmotes,
        showBTTVBadges: showBTTVBadges,
        showFFZEmotes: showFFZEmotes,
        showFFZBadges: showFFZBadges,
      ),
    );
  }

  late final _$_fetchGlobalAssetsAsyncAction = AsyncAction(
    'GlobalAssetsStoreBase._fetchGlobalAssets',
    context: context,
  );

  @override
  Future<void> _fetchGlobalAssets({
    required bool showTwitchEmotes,
    required bool showTwitchBadges,
    required bool show7TVEmotes,
    required bool showBTTVEmotes,
    required bool showBTTVBadges,
    required bool showFFZEmotes,
    required bool showFFZBadges,
  }) {
    return _$_fetchGlobalAssetsAsyncAction.run(
      () => super._fetchGlobalAssets(
        showTwitchEmotes: showTwitchEmotes,
        showTwitchBadges: showTwitchBadges,
        show7TVEmotes: show7TVEmotes,
        showBTTVEmotes: showBTTVEmotes,
        showBTTVBadges: showBTTVBadges,
        showFFZEmotes: showFFZEmotes,
        showFFZBadges: showFFZBadges,
      ),
    );
  }

  @override
  String toString() {
    return '''
globalEmoteMap: ${globalEmoteMap}
    ''';
  }
}
