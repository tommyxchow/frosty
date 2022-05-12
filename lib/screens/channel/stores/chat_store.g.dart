// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$ChatStore on ChatStoreBase, Store {
  late final _$_messagesAtom =
      Atom(name: 'ChatStoreBase._messages', context: context);

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

  late final _$_autoScrollAtom =
      Atom(name: 'ChatStoreBase._autoScroll', context: context);

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

  late final _$_showAutocompleteAtom =
      Atom(name: 'ChatStoreBase._showAutocomplete', context: context);

  bool get showAutocomplete {
    _$_showAutocompleteAtom.reportRead();
    return super._showAutocomplete;
  }

  @override
  bool get _showAutocomplete => showAutocomplete;

  @override
  set _showAutocomplete(bool value) {
    _$_showAutocompleteAtom.reportWrite(value, super._showAutocomplete, () {
      super._showAutocomplete = value;
    });
  }

  late final _$_userStateAtom =
      Atom(name: 'ChatStoreBase._userState', context: context);

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

  late final _$ChatStoreBaseActionController =
      ActionController(name: 'ChatStoreBase', context: context);

  @override
  void _handleIRCData(String data) {
    final $actionInfo = _$ChatStoreBaseActionController.startAction(
        name: 'ChatStoreBase._handleIRCData');
    try {
      return super._handleIRCData(data);
    } finally {
      _$ChatStoreBaseActionController.endAction($actionInfo);
    }
  }

  @override
  void resumeScroll() {
    final $actionInfo = _$ChatStoreBaseActionController.startAction(
        name: 'ChatStoreBase.resumeScroll');
    try {
      return super.resumeScroll();
    } finally {
      _$ChatStoreBaseActionController.endAction($actionInfo);
    }
  }

  @override
  void connectToChat() {
    final $actionInfo = _$ChatStoreBaseActionController.startAction(
        name: 'ChatStoreBase.connectToChat');
    try {
      return super.connectToChat();
    } finally {
      _$ChatStoreBaseActionController.endAction($actionInfo);
    }
  }

  @override
  void sendMessage(String message) {
    final $actionInfo = _$ChatStoreBaseActionController.startAction(
        name: 'ChatStoreBase.sendMessage');
    try {
      return super.sendMessage(message);
    } finally {
      _$ChatStoreBaseActionController.endAction($actionInfo);
    }
  }

  @override
  void addEmote(Emote emote, {bool autocompleteMode = false}) {
    final $actionInfo = _$ChatStoreBaseActionController.startAction(
        name: 'ChatStoreBase.addEmote');
    try {
      return super.addEmote(emote, autocompleteMode: autocompleteMode);
    } finally {
      _$ChatStoreBaseActionController.endAction($actionInfo);
    }
  }

  @override
  String toString() {
    return '''

    ''';
  }
}
