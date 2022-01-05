// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$UserStore on _UserStoreBase, Store {
  final _$_detailsAtom = Atom(name: '_UserStoreBase._details');

  UserTwitch? get details {
    _$_detailsAtom.reportRead();
    return super._details;
  }

  @override
  UserTwitch? get _details => details;

  @override
  set _details(UserTwitch? value) {
    _$_detailsAtom.reportWrite(value, super._details, () {
      super._details = value;
    });
  }

  final _$_blockedUsersAtom = Atom(name: '_UserStoreBase._blockedUsers');

  ObservableList<UserBlockedTwitch> get blockedUsers {
    _$_blockedUsersAtom.reportRead();
    return super._blockedUsers;
  }

  @override
  ObservableList<UserBlockedTwitch> get _blockedUsers => blockedUsers;

  @override
  set _blockedUsers(ObservableList<UserBlockedTwitch> value) {
    _$_blockedUsersAtom.reportWrite(value, super._blockedUsers, () {
      super._blockedUsers = value;
    });
  }

  final _$initAsyncAction = AsyncAction('_UserStoreBase.init');

  @override
  Future<void> init({required Map<String, String> headers}) {
    return _$initAsyncAction.run(() => super.init(headers: headers));
  }

  final _$blockAsyncAction = AsyncAction('_UserStoreBase.block');

  @override
  Future<void> block(
      {required String targetId, required Map<String, String> headers}) {
    return _$blockAsyncAction
        .run(() => super.block(targetId: targetId, headers: headers));
  }

  final _$unblockAsyncAction = AsyncAction('_UserStoreBase.unblock');

  @override
  Future<void> unblock(
      {required String targetId, required Map<String, String> headers}) {
    return _$unblockAsyncAction
        .run(() => super.unblock(targetId: targetId, headers: headers));
  }

  final _$refreshBlockedUsersAsyncAction =
      AsyncAction('_UserStoreBase.refreshBlockedUsers');

  @override
  Future<void> refreshBlockedUsers({required Map<String, String> headers}) {
    return _$refreshBlockedUsersAsyncAction
        .run(() => super.refreshBlockedUsers(headers: headers));
  }

  final _$_UserStoreBaseActionController =
      ActionController(name: '_UserStoreBase');

  @override
  void dispose() {
    final _$actionInfo = _$_UserStoreBaseActionController.startAction(
        name: '_UserStoreBase.dispose');
    try {
      return super.dispose();
    } finally {
      _$_UserStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''

    ''';
  }
}
