// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$UserStore on UserStoreBase, Store {
  late final _$_detailsAtom =
      Atom(name: 'UserStoreBase._details', context: context);

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

  late final _$_blockedUsersAtom =
      Atom(name: 'UserStoreBase._blockedUsers', context: context);

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

  late final _$initAsyncAction =
      AsyncAction('UserStoreBase.init', context: context);

  @override
  Future<void> init({required Map<String, String> headers}) {
    return _$initAsyncAction.run(() => super.init(headers: headers));
  }

  late final _$blockAsyncAction =
      AsyncAction('UserStoreBase.block', context: context);

  @override
  Future<void> block(
      {required String targetId,
      required String displayName,
      required Map<String, String> headers}) {
    return _$blockAsyncAction.run(() => super
        .block(targetId: targetId, displayName: displayName, headers: headers));
  }

  late final _$unblockAsyncAction =
      AsyncAction('UserStoreBase.unblock', context: context);

  @override
  Future<void> unblock(
      {required String targetId, required Map<String, String> headers}) {
    return _$unblockAsyncAction
        .run(() => super.unblock(targetId: targetId, headers: headers));
  }

  late final _$refreshBlockedUsersAsyncAction =
      AsyncAction('UserStoreBase.refreshBlockedUsers', context: context);

  @override
  Future<void> refreshBlockedUsers({required Map<String, String> headers}) {
    return _$refreshBlockedUsersAsyncAction
        .run(() => super.refreshBlockedUsers(headers: headers));
  }

  late final _$UserStoreBaseActionController =
      ActionController(name: 'UserStoreBase', context: context);

  @override
  void dispose() {
    final _$actionInfo = _$UserStoreBaseActionController.startAction(
        name: 'UserStoreBase.dispose');
    try {
      return super.dispose();
    } finally {
      _$UserStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''

    ''';
  }
}
