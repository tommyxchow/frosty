// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_assets_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$ChatAssetsStore on _ChatAssetsStoreBase, Store {
  Computed<List<Emote>>? _$bttvEmotesComputed;

  @override
  List<Emote> get bttvEmotes =>
      (_$bttvEmotesComputed ??= Computed<List<Emote>>(() => super.bttvEmotes,
              name: '_ChatAssetsStoreBase.bttvEmotes'))
          .value;
  Computed<List<Emote>>? _$ffzEmotesComputed;

  @override
  List<Emote> get ffzEmotes =>
      (_$ffzEmotesComputed ??= Computed<List<Emote>>(() => super.ffzEmotes,
              name: '_ChatAssetsStoreBase.ffzEmotes'))
          .value;
  Computed<List<Emote>>? _$sevenTvEmotesComputed;

  @override
  List<Emote> get sevenTvEmotes => (_$sevenTvEmotesComputed ??=
          Computed<List<Emote>>(() => super.sevenTvEmotes,
              name: '_ChatAssetsStoreBase.sevenTvEmotes'))
      .value;

  final _$_emoteToObjectAtom =
      Atom(name: '_ChatAssetsStoreBase._emoteToObject');

  Map<String, Emote> get emoteToObject {
    _$_emoteToObjectAtom.reportRead();
    return super._emoteToObject;
  }

  @override
  Map<String, Emote> get _emoteToObject => emoteToObject;

  @override
  set _emoteToObject(Map<String, Emote> value) {
    _$_emoteToObjectAtom.reportWrite(value, super._emoteToObject, () {
      super._emoteToObject = value;
    });
  }

  final _$_userEmoteToObjectAtom =
      Atom(name: '_ChatAssetsStoreBase._userEmoteToObject');

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

  final _$_twitchBadgesToObjectAtom =
      Atom(name: '_ChatAssetsStoreBase._twitchBadgesToObject');

  Map<String, BadgeInfoTwitch> get twitchBadgesToObject {
    _$_twitchBadgesToObjectAtom.reportRead();
    return super._twitchBadgesToObject;
  }

  @override
  Map<String, BadgeInfoTwitch> get _twitchBadgesToObject =>
      twitchBadgesToObject;

  @override
  set _twitchBadgesToObject(Map<String, BadgeInfoTwitch> value) {
    _$_twitchBadgesToObjectAtom.reportWrite(value, super._twitchBadgesToObject,
        () {
      super._twitchBadgesToObject = value;
    });
  }

  final _$_userToFFZBadgesAtom =
      Atom(name: '_ChatAssetsStoreBase._userToFFZBadges');

  Map<String, List<BadgeInfoFFZ>> get userToFFZBadges {
    _$_userToFFZBadgesAtom.reportRead();
    return super._userToFFZBadges;
  }

  @override
  Map<String, List<BadgeInfoFFZ>> get _userToFFZBadges => userToFFZBadges;

  @override
  set _userToFFZBadges(Map<String, List<BadgeInfoFFZ>> value) {
    _$_userToFFZBadgesAtom.reportWrite(value, super._userToFFZBadges, () {
      super._userToFFZBadges = value;
    });
  }

  final _$_userTo7TVBadgesAtom =
      Atom(name: '_ChatAssetsStoreBase._userTo7TVBadges');

  Map<String, List<BadgeInfo7TV>> get userTo7TVBadges {
    _$_userTo7TVBadgesAtom.reportRead();
    return super._userTo7TVBadges;
  }

  @override
  Map<String, List<BadgeInfo7TV>> get _userTo7TVBadges => userTo7TVBadges;

  @override
  set _userTo7TVBadges(Map<String, List<BadgeInfo7TV>> value) {
    _$_userTo7TVBadgesAtom.reportWrite(value, super._userTo7TVBadges, () {
      super._userTo7TVBadges = value;
    });
  }

  final _$_userToBTTVBadgesAtom =
      Atom(name: '_ChatAssetsStoreBase._userToBTTVBadges');

  Map<String, BadgeInfoBTTV> get userToBTTVBadges {
    _$_userToBTTVBadgesAtom.reportRead();
    return super._userToBTTVBadges;
  }

  @override
  Map<String, BadgeInfoBTTV> get _userToBTTVBadges => userToBTTVBadges;

  @override
  set _userToBTTVBadges(Map<String, BadgeInfoBTTV> value) {
    _$_userToBTTVBadgesAtom.reportWrite(value, super._userToBTTVBadges, () {
      super._userToBTTVBadges = value;
    });
  }

  final _$emoteMenuIndexAtom =
      Atom(name: '_ChatAssetsStoreBase.emoteMenuIndex');

  @override
  int get emoteMenuIndex {
    _$emoteMenuIndexAtom.reportRead();
    return super.emoteMenuIndex;
  }

  @override
  set emoteMenuIndex(int value) {
    _$emoteMenuIndexAtom.reportWrite(value, super.emoteMenuIndex, () {
      super.emoteMenuIndex = value;
    });
  }

  final _$showEmoteMenuAtom = Atom(name: '_ChatAssetsStoreBase.showEmoteMenu');

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

  final _$getAssetsAsyncAction = AsyncAction('_ChatAssetsStoreBase.getAssets');

  @override
  Future<void> getAssets(
      {required String channelName, required Map<String, String> headers}) {
    return _$getAssetsAsyncAction
        .run(() => super.getAssets(channelName: channelName, headers: headers));
  }

  final _$getUserEmotesAsyncAction =
      AsyncAction('_ChatAssetsStoreBase.getUserEmotes');

  @override
  Future<void> getUserEmotes(
      {List<String>? emoteSets, required Map<String, String> headers}) {
    return _$getUserEmotesAsyncAction
        .run(() => super.getUserEmotes(emoteSets: emoteSets, headers: headers));
  }

  @override
  String toString() {
    return '''
emoteMenuIndex: ${emoteMenuIndex},
showEmoteMenu: ${showEmoteMenu},
bttvEmotes: ${bttvEmotes},
ffzEmotes: ${ffzEmotes},
sevenTvEmotes: ${sevenTvEmotes}
    ''';
  }
}
