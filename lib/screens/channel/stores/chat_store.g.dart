// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$ChatStore on ChatStoreBase, Store {
  Computed<List<IRCMessage>>? _$renderMessagesComputed;

  @override
  List<IRCMessage> get renderMessages => (_$renderMessagesComputed ??=
          Computed<List<IRCMessage>>(() => super.renderMessages,
              name: 'ChatStoreBase.renderMessages'))
      .value;

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

  late final _$_showSendButtonAtom =
      Atom(name: 'ChatStoreBase._showSendButton', context: context);

  bool get showSendButton {
    _$_showSendButtonAtom.reportRead();
    return super._showSendButton;
  }

  @override
  bool get _showSendButton => showSendButton;

  @override
  set _showSendButton(bool value) {
    _$_showSendButtonAtom.reportWrite(value, super._showSendButton, () {
      super._showSendButton = value;
    });
  }

  late final _$_showEmoteAutocompleteAtom =
      Atom(name: 'ChatStoreBase._showEmoteAutocomplete', context: context);

  bool get showEmoteAutocomplete {
    _$_showEmoteAutocompleteAtom.reportRead();
    return super._showEmoteAutocomplete;
  }

  @override
  bool get _showEmoteAutocomplete => showEmoteAutocomplete;

  @override
  set _showEmoteAutocomplete(bool value) {
    _$_showEmoteAutocompleteAtom
        .reportWrite(value, super._showEmoteAutocomplete, () {
      super._showEmoteAutocomplete = value;
    });
  }

  late final _$_showMentionAutocompleteAtom =
      Atom(name: 'ChatStoreBase._showMentionAutocomplete', context: context);

  bool get showMentionAutocomplete {
    _$_showMentionAutocompleteAtom.reportRead();
    return super._showMentionAutocomplete;
  }

  @override
  bool get _showMentionAutocomplete => showMentionAutocomplete;

  @override
  set _showMentionAutocomplete(bool value) {
    _$_showMentionAutocompleteAtom
        .reportWrite(value, super._showMentionAutocomplete, () {
      super._showMentionAutocomplete = value;
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

  late final _$expandChatAtom =
      Atom(name: 'ChatStoreBase.expandChat', context: context);

  @override
  bool get expandChat {
    _$expandChatAtom.reportRead();
    return super.expandChat;
  }

  @override
  set expandChat(bool value) {
    _$expandChatAtom.reportWrite(value, super.expandChat, () {
      super.expandChat = value;
    });
  }

  late final _$notificationAtom =
      Atom(name: 'ChatStoreBase.notification', context: context);

  @override
  String? get notification {
    _$notificationAtom.reportRead();
    return super.notification;
  }

  @override
  set notification(String? value) {
    _$notificationAtom.reportWrite(value, super.notification, () {
      super.notification = value;
    });
  }

  late final _$getAssetsAsyncAction =
      AsyncAction('ChatStoreBase.getAssets', context: context);

  @override
  Future<void> getAssets() {
    return _$getAssetsAsyncAction.run(() => super.getAssets());
  }

  late final _$ChatStoreBaseActionController =
      ActionController(name: 'ChatStoreBase', context: context);

  @override
  void _handleIRCData(String data) {
    final _$actionInfo = _$ChatStoreBaseActionController.startAction(
        name: 'ChatStoreBase._handleIRCData');
    try {
      return super._handleIRCData(data);
    } finally {
      _$ChatStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void resumeScroll() {
    final _$actionInfo = _$ChatStoreBaseActionController.startAction(
        name: 'ChatStoreBase.resumeScroll');
    try {
      return super.resumeScroll();
    } finally {
      _$ChatStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void connectToChat() {
    final _$actionInfo = _$ChatStoreBaseActionController.startAction(
        name: 'ChatStoreBase.connectToChat');
    try {
      return super.connectToChat();
    } finally {
      _$ChatStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void addMessages() {
    final _$actionInfo = _$ChatStoreBaseActionController.startAction(
        name: 'ChatStoreBase.addMessages');
    try {
      return super.addMessages();
    } finally {
      _$ChatStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void sendMessage(String message) {
    final _$actionInfo = _$ChatStoreBaseActionController.startAction(
        name: 'ChatStoreBase.sendMessage');
    try {
      return super.sendMessage(message);
    } finally {
      _$ChatStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void addEmote(Emote emote, {bool autocompleteMode = false}) {
    final _$actionInfo = _$ChatStoreBaseActionController.startAction(
        name: 'ChatStoreBase.addEmote');
    try {
      return super.addEmote(emote, autocompleteMode: autocompleteMode);
    } finally {
      _$ChatStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
expandChat: ${expandChat},
notification: ${notification},
renderMessages: ${renderMessages}
    ''';
  }
}
