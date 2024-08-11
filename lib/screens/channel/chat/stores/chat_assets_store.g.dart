// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_assets_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$ChatAssetsStore on ChatAssetsStoreBase, Store {
  Computed<List<Emote>>? _$bttvEmotesComputed;

  @override
  List<Emote> get bttvEmotes =>
      (_$bttvEmotesComputed ??= Computed<List<Emote>>(() => super.bttvEmotes,
              name: 'ChatAssetsStoreBase.bttvEmotes'))
          .value;
  Computed<List<Emote>>? _$ffzEmotesComputed;

  @override
  List<Emote> get ffzEmotes =>
      (_$ffzEmotesComputed ??= Computed<List<Emote>>(() => super.ffzEmotes,
              name: 'ChatAssetsStoreBase.ffzEmotes'))
          .value;
  Computed<List<Emote>>? _$sevenTVEmotesComputed;

  @override
  List<Emote> get sevenTVEmotes => (_$sevenTVEmotesComputed ??=
          Computed<List<Emote>>(() => super.sevenTVEmotes,
              name: 'ChatAssetsStoreBase.sevenTVEmotes'))
      .value;

  late final _$_recentEmotesAtom =
      Atom(name: 'ChatAssetsStoreBase._recentEmotes', context: context);

  ObservableList<Emote> get recentEmotes {
    _$_recentEmotesAtom.reportRead();
    return super._recentEmotes;
  }

  @override
  ObservableList<Emote> get _recentEmotes => recentEmotes;

  @override
  set _recentEmotes(ObservableList<Emote> value) {
    _$_recentEmotesAtom.reportWrite(value, super._recentEmotes, () {
      super._recentEmotes = value;
    });
  }

  late final _$_emoteToObjectAtom =
      Atom(name: 'ChatAssetsStoreBase._emoteToObject', context: context);

  ObservableMap<String, Emote> get emoteToObject {
    _$_emoteToObjectAtom.reportRead();
    return super._emoteToObject;
  }

  @override
  ObservableMap<String, Emote> get _emoteToObject => emoteToObject;

  @override
  set _emoteToObject(ObservableMap<String, Emote> value) {
    _$_emoteToObjectAtom.reportWrite(value, super._emoteToObject, () {
      super._emoteToObject = value;
    });
  }

  late final _$_userEmoteToObjectAtom =
      Atom(name: 'ChatAssetsStoreBase._userEmoteToObject', context: context);

  Map<String, Emote> get userEmoteToObject {
    _$_userEmoteToObjectAtom.reportRead();
    return super._userEmoteToObject;
  }

  @override
  Map<String, Emote> get _userEmoteToObject => userEmoteToObject;

  @override
  set _userEmoteToObject(Map<String, Emote> value) {
    _$_userEmoteToObjectAtom.reportWrite(value, super._userEmoteToObject, () {
      super._userEmoteToObject = value;
    });
  }

  late final _$_userEmoteSectionToEmotesAtom = Atom(
      name: 'ChatAssetsStoreBase._userEmoteSectionToEmotes', context: context);

  Map<String, List<Emote>> get userEmoteSectionToEmotes {
    _$_userEmoteSectionToEmotesAtom.reportRead();
    return super._userEmoteSectionToEmotes;
  }

  @override
  Map<String, List<Emote>> get _userEmoteSectionToEmotes =>
      userEmoteSectionToEmotes;

  @override
  set _userEmoteSectionToEmotes(Map<String, List<Emote>> value) {
    _$_userEmoteSectionToEmotesAtom
        .reportWrite(value, super._userEmoteSectionToEmotes, () {
      super._userEmoteSectionToEmotes = value;
    });
  }

  late final _$_userToFFZBadgesAtom =
      Atom(name: 'ChatAssetsStoreBase._userToFFZBadges', context: context);

  Map<String, List<ChatBadge>> get userToFFZBadges {
    _$_userToFFZBadgesAtom.reportRead();
    return super._userToFFZBadges;
  }

  @override
  Map<String, List<ChatBadge>> get _userToFFZBadges => userToFFZBadges;

  @override
  set _userToFFZBadges(Map<String, List<ChatBadge>> value) {
    _$_userToFFZBadgesAtom.reportWrite(value, super._userToFFZBadges, () {
      super._userToFFZBadges = value;
    });
  }

  late final _$_userTo7TVBadgesAtom =
      Atom(name: 'ChatAssetsStoreBase._userTo7TVBadges', context: context);

  Map<String, List<ChatBadge>> get userTo7TVBadges {
    _$_userTo7TVBadgesAtom.reportRead();
    return super._userTo7TVBadges;
  }

  @override
  Map<String, List<ChatBadge>> get _userTo7TVBadges => userTo7TVBadges;

  @override
  set _userTo7TVBadges(Map<String, List<ChatBadge>> value) {
    _$_userTo7TVBadgesAtom.reportWrite(value, super._userTo7TVBadges, () {
      super._userTo7TVBadges = value;
    });
  }

  late final _$_userToBTTVBadgesAtom =
      Atom(name: 'ChatAssetsStoreBase._userToBTTVBadges', context: context);

  Map<String, ChatBadge> get userToBTTVBadges {
    _$_userToBTTVBadgesAtom.reportRead();
    return super._userToBTTVBadges;
  }

  @override
  Map<String, ChatBadge> get _userToBTTVBadges => userToBTTVBadges;

  @override
  set _userToBTTVBadges(Map<String, ChatBadge> value) {
    _$_userToBTTVBadgesAtom.reportWrite(value, super._userToBTTVBadges, () {
      super._userToBTTVBadges = value;
    });
  }

  late final _$showEmoteMenuAtom =
      Atom(name: 'ChatAssetsStoreBase.showEmoteMenu', context: context);

  @override
  bool get showEmoteMenu {
    _$showEmoteMenuAtom.reportRead();
    return super.showEmoteMenu;
  }

  @override
  set showEmoteMenu(bool value) {
    _$showEmoteMenuAtom.reportWrite(value, super.showEmoteMenu, () {
      super.showEmoteMenu = value;
    });
  }

  late final _$initAsyncAction =
      AsyncAction('ChatAssetsStoreBase.init', context: context);

  @override
  Future<void> init() {
    return _$initAsyncAction.run(() => super.init());
  }

  late final _$userEmotesFutureAsyncAction =
      AsyncAction('ChatAssetsStoreBase.userEmotesFuture', context: context);

  @override
  Future<void> userEmotesFuture(
      {required List<String> emoteSets,
      required Map<String, String> headers,
      required Function onError}) {
    return _$userEmotesFutureAsyncAction.run(() => super.userEmotesFuture(
        emoteSets: emoteSets, headers: headers, onError: onError));
  }

  late final _$ChatAssetsStoreBaseActionController =
      ActionController(name: 'ChatAssetsStoreBase', context: context);

  @override
  Future<void> assetsFuture(
      {required String channelId,
      required Map<String, String> headers,
      required Function onEmoteError,
      required Function onBadgeError,
      bool showTwitchEmotes = true,
      bool showTwitchBadges = true,
      bool show7TVEmotes = true,
      bool showBTTVEmotes = true,
      bool showBTTVBadges = true,
      bool showFFZEmotes = true,
      bool showFFZBadges = true}) {
    final _$actionInfo = _$ChatAssetsStoreBaseActionController.startAction(
        name: 'ChatAssetsStoreBase.assetsFuture');
    try {
      return super.assetsFuture(
          channelId: channelId,
          headers: headers,
          onEmoteError: onEmoteError,
          onBadgeError: onBadgeError,
          showTwitchEmotes: showTwitchEmotes,
          showTwitchBadges: showTwitchBadges,
          show7TVEmotes: show7TVEmotes,
          showBTTVEmotes: showBTTVEmotes,
          showBTTVBadges: showBTTVBadges,
          showFFZEmotes: showFFZEmotes,
          showFFZBadges: showFFZBadges);
    } finally {
      _$ChatAssetsStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
showEmoteMenu: ${showEmoteMenu},
bttvEmotes: ${bttvEmotes},
ffzEmotes: ${ffzEmotes},
sevenTVEmotes: ${sevenTVEmotes}
    ''';
  }
}
