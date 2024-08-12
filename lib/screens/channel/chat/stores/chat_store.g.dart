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

  late final _$timeRemainingAtom =
      Atom(name: 'ChatStoreBase.timeRemaining', context: context);

  @override
  Duration get timeRemaining {
    _$timeRemainingAtom.reportRead();
    return super.timeRemaining;
  }

  @override
  set timeRemaining(Duration value) {
    _$timeRemainingAtom.reportWrite(value, super.timeRemaining, () {
      super.timeRemaining = value;
    });
  }

  late final _$_notificationAtom =
      Atom(name: 'ChatStoreBase._notification', context: context);

  String? get notification {
    _$_notificationAtom.reportRead();
    return super._notification;
  }

  @override
  String? get _notification => notification;

  @override
  set _notification(String? value) {
    _$_notificationAtom.reportWrite(value, super._notification, () {
      super._notification = value;
    });
  }

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

  late final _$_inputTextAtom =
      Atom(name: 'ChatStoreBase._inputText', context: context);

  String get inputText {
    _$_inputTextAtom.reportRead();
    return super._inputText;
  }

  @override
  String get _inputText => inputText;

  @override
  set _inputText(String value) {
    _$_inputTextAtom.reportWrite(value, super._inputText, () {
      super._inputText = value;
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

  late final _$replyingToMessageAtom =
      Atom(name: 'ChatStoreBase.replyingToMessage', context: context);

  @override
  IRCMessage? get replyingToMessage {
    _$replyingToMessageAtom.reportRead();
    return super.replyingToMessage;
  }

  @override
  set replyingToMessage(IRCMessage? value) {
    _$replyingToMessageAtom.reportWrite(value, super.replyingToMessage, () {
      super.replyingToMessage = value;
    });
  }

  late final _$getAssetsAsyncAction =
      AsyncAction('ChatStoreBase.getAssets', context: context);

  @override
  Future<void> getAssets() {
    return _$getAssetsAsyncAction.run(() => super.getAssets());
  }

  late final _$getRecentMessageAsyncAction =
      AsyncAction('ChatStoreBase.getRecentMessage', context: context);

  @override
  Future<void> getRecentMessage() {
    return _$getRecentMessageAsyncAction.run(() => super.getRecentMessage());
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
  void listenToSevenTVEmoteSet({required String emoteSetId}) {
    final _$actionInfo = _$ChatStoreBaseActionController.startAction(
        name: 'ChatStoreBase.listenToSevenTVEmoteSet');
    try {
      return super.listenToSevenTVEmoteSet(emoteSetId: emoteSetId);
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
  void updateNotification(String notificationMessage) {
    final _$actionInfo = _$ChatStoreBaseActionController.startAction(
        name: 'ChatStoreBase.updateNotification');
    try {
      return super.updateNotification(notificationMessage);
    } finally {
      _$ChatStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void updateSleepTimer(
      {required Duration duration, required VoidCallback onTimerFinished}) {
    final _$actionInfo = _$ChatStoreBaseActionController.startAction(
        name: 'ChatStoreBase.updateSleepTimer');
    try {
      return super.updateSleepTimer(
          duration: duration, onTimerFinished: onTimerFinished);
    } finally {
      _$ChatStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void cancelSleepTimer() {
    final _$actionInfo = _$ChatStoreBaseActionController.startAction(
        name: 'ChatStoreBase.cancelSleepTimer');
    try {
      return super.cancelSleepTimer();
    } finally {
      _$ChatStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
timeRemaining: ${timeRemaining},
expandChat: ${expandChat},
replyingToMessage: ${replyingToMessage},
renderMessages: ${renderMessages}
    ''';
  }
}
