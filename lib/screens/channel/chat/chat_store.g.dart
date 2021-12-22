// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$ChatStore on _ChatStoreBase, Store {
  Computed<List<Emote>>? _$bttvEmotesComputed;

  @override
  List<Emote> get bttvEmotes =>
      (_$bttvEmotesComputed ??= Computed<List<Emote>>(() => super.bttvEmotes,
              name: '_ChatStoreBase.bttvEmotes'))
          .value;
  Computed<List<Emote>>? _$ffzEmotesComputed;

  @override
  List<Emote> get ffzEmotes =>
      (_$ffzEmotesComputed ??= Computed<List<Emote>>(() => super.ffzEmotes,
              name: '_ChatStoreBase.ffzEmotes'))
          .value;
  Computed<List<Emote>>? _$sevenTvEmotesComputed;

  @override
  List<Emote> get sevenTvEmotes => (_$sevenTvEmotesComputed ??=
          Computed<List<Emote>>(() => super.sevenTvEmotes,
              name: '_ChatStoreBase.sevenTvEmotes'))
      .value;

  final _$_userEmotesAtom = Atom(name: '_ChatStoreBase._userEmotes');

  ObservableList<Emote> get userEmotes {
    _$_userEmotesAtom.reportRead();
    return super._userEmotes;
  }

  @override
  ObservableList<Emote> get _userEmotes => userEmotes;

  @override
  set _userEmotes(ObservableList<Emote> value) {
    _$_userEmotesAtom.reportWrite(value, super._userEmotes, () {
      super._userEmotes = value;
    });
  }

  final _$emoteMenuIndexAtom = Atom(name: '_ChatStoreBase.emoteMenuIndex');

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

  final _$showEmoteMenuAtom = Atom(name: '_ChatStoreBase.showEmoteMenu');

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

  final _$_messagesAtom = Atom(name: '_ChatStoreBase._messages');

  ObservableList<IRCMessage> get messages {
    _$_messagesAtom.reportRead();
    return super._messages;
  }

  @override
  ObservableList<IRCMessage> get _messages => messages;

  @override
  set _messages(ObservableList<IRCMessage> value) {
    _$_messagesAtom.reportWrite(value, super._messages, () {
      super._messages = value;
    });
  }

  final _$_autoScrollAtom = Atom(name: '_ChatStoreBase._autoScroll');

  bool get autoScroll {
    _$_autoScrollAtom.reportRead();
    return super._autoScroll;
  }

  @override
  bool get _autoScroll => autoScroll;

  @override
  set _autoScroll(bool value) {
    _$_autoScrollAtom.reportWrite(value, super._autoScroll, () {
      super._autoScroll = value;
    });
  }

  final _$_userStateAtom = Atom(name: '_ChatStoreBase._userState');

  USERSTATE get userState {
    _$_userStateAtom.reportRead();
    return super._userState;
  }

  @override
  USERSTATE get _userState => userState;

  @override
  set _userState(USERSTATE value) {
    _$_userStateAtom.reportWrite(value, super._userState, () {
      super._userState = value;
    });
  }

  final _$_roomStateAtom = Atom(name: '_ChatStoreBase._roomState');

  ROOMSTATE get roomState {
    _$_roomStateAtom.reportRead();
    return super._roomState;
  }

  @override
  ROOMSTATE get _roomState => roomState;

  @override
  set _roomState(ROOMSTATE value) {
    _$_roomStateAtom.reportWrite(value, super._roomState, () {
      super._roomState = value;
    });
  }

  final _$getAssetsAsyncAction = AsyncAction('_ChatStoreBase.getAssets');

  @override
  Future<void> getAssets({List<String>? emoteSets}) {
    return _$getAssetsAsyncAction
        .run(() => super.getAssets(emoteSets: emoteSets));
  }

  final _$_ChatStoreBaseActionController =
      ActionController(name: '_ChatStoreBase');

  @override
  void _handleIRCData(String data) {
    final _$actionInfo = _$_ChatStoreBaseActionController.startAction(
        name: '_ChatStoreBase._handleIRCData');
    try {
      return super._handleIRCData(data);
    } finally {
      _$_ChatStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void _deleteAndScrollToEnd() {
    final _$actionInfo = _$_ChatStoreBaseActionController.startAction(
        name: '_ChatStoreBase._deleteAndScrollToEnd');
    try {
      return super._deleteAndScrollToEnd();
    } finally {
      _$_ChatStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void resumeScroll() {
    final _$actionInfo = _$_ChatStoreBaseActionController.startAction(
        name: '_ChatStoreBase.resumeScroll');
    try {
      return super.resumeScroll();
    } finally {
      _$_ChatStoreBaseActionController.endAction(_$actionInfo);
    }
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
