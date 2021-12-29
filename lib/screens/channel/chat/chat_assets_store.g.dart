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

  final _$_userEmoteToObjectAtom =
      Atom(name: '_ChatAssetsStoreBase._userEmoteToObject');

  ObservableMap<String, Emote> get userEmoteToObject {
    _$_userEmoteToObjectAtom.reportRead();
    return super._userEmoteToObject;
  }

  @override
  ObservableMap<String, Emote> get _userEmoteToObject => userEmoteToObject;

  @override
  set _userEmoteToObject(ObservableMap<String, Emote> value) {
    _$_userEmoteToObjectAtom.reportWrite(value, super._userEmoteToObject, () {
      super._userEmoteToObject = value;
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
