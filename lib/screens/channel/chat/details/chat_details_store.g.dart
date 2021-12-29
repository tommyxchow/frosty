// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_details_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$ChatDetailsStore on _ChatDetailsStoreBase, Store {
  final _$roomStateAtom = Atom(name: '_ChatDetailsStoreBase.roomState');

  @override
  ROOMSTATE get roomState {
    _$roomStateAtom.reportRead();
    return super.roomState;
  }

  @override
  set roomState(ROOMSTATE value) {
    _$roomStateAtom.reportWrite(value, super.roomState, () {
      super.roomState = value;
    });
  }

  final _$_chatUsersAtom = Atom(name: '_ChatDetailsStoreBase._chatUsers');

  ChatUsers? get chatUsers {
    _$_chatUsersAtom.reportRead();
    return super._chatUsers;
  }

  @override
  ChatUsers? get _chatUsers => chatUsers;

  @override
  set _chatUsers(ChatUsers? value) {
    _$_chatUsersAtom.reportWrite(value, super._chatUsers, () {
      super._chatUsers = value;
    });
  }

  final _$updateChattersAsyncAction =
      AsyncAction('_ChatDetailsStoreBase.updateChatters');

  @override
  Future<void> updateChatters(String userLogin) {
    return _$updateChattersAsyncAction
        .run(() => super.updateChatters(userLogin));
  }

  @override
  String toString() {
    return '''
roomState: ${roomState}
    ''';
  }
}
