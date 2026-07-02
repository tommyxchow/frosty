// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$UserStore on UserStoreBase, Store {
  late final _$_detailsAtom = Atom(
    name: 'UserStoreBase._details',
    context: context,
  );

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

  late final _$_blockedUsersAtom = Atom(
    name: 'UserStoreBase._blockedUsers',
    context: context,
  );

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

  late final _$_moderatedChannelsAtom = Atom(
    name: 'UserStoreBase._moderatedChannels',
    context: context,
  );

  ObservableList<String> get moderatedChannels {
    _$_moderatedChannelsAtom.reportRead();
    return super._moderatedChannels;
  }

  @override
  ObservableList<String> get _moderatedChannels => moderatedChannels;

  @override
  set _moderatedChannels(ObservableList<String> value) {
    _$_moderatedChannelsAtom.reportWrite(value, super._moderatedChannels, () {
      super._moderatedChannels = value;
    });
  }

  late final _$initAsyncAction = AsyncAction(
    'UserStoreBase.init',
    context: context,
  );

  @override
  Future<void> init() {
    return _$initAsyncAction.run(() => super.init());
  }

  late final _$blockAsyncAction = AsyncAction(
    'UserStoreBase.block',
    context: context,
  );

  @override
  Future<void> block({required String targetId, required String displayName}) {
    return _$blockAsyncAction.run(
      () => super.block(targetId: targetId, displayName: displayName),
    );
  }

  late final _$unblockAsyncAction = AsyncAction(
    'UserStoreBase.unblock',
    context: context,
  );

  @override
  Future<void> unblock({required String targetId}) {
    return _$unblockAsyncAction.run(() => super.unblock(targetId: targetId));
  }

  late final _$refreshBlockedUsersAsyncAction = AsyncAction(
    'UserStoreBase.refreshBlockedUsers',
    context: context,
  );

  @override
  Future<void> refreshBlockedUsers() {
    return _$refreshBlockedUsersAsyncAction.run(
      () => super.refreshBlockedUsers(),
    );
  }

  late final _$refreshModeratedChannelsAsyncAction = AsyncAction(
    'UserStoreBase.refreshModeratedChannels',
    context: context,
  );

  @override
  Future<void> refreshModeratedChannels() {
    return _$refreshModeratedChannelsAsyncAction.run(
      () => super.refreshModeratedChannels(),
    );
  }

  late final _$deleteMessageAsyncAction = AsyncAction(
    'UserStoreBase.deleteMessage',
    context: context,
  );

  @override
  Future<bool> deleteMessage({
    required String broadcasterId,
    required String messageId,
  }) {
    return _$deleteMessageAsyncAction.run(
      () => super.deleteMessage(
        broadcasterId: broadcasterId,
        messageId: messageId,
      ),
    );
  }

  late final _$banOrTimeoutUserAsyncAction = AsyncAction(
    'UserStoreBase.banOrTimeoutUser',
    context: context,
  );

  @override
  Future<bool> banOrTimeoutUser({
    required String broadcasterId,
    required String userIdToBan,
    int? duration,
    String? reason,
  }) {
    return _$banOrTimeoutUserAsyncAction.run(
      () => super.banOrTimeoutUser(
        broadcasterId: broadcasterId,
        userIdToBan: userIdToBan,
        duration: duration,
        reason: reason,
      ),
    );
  }

  late final _$unbanUserAsyncAction = AsyncAction(
    'UserStoreBase.unbanUser',
    context: context,
  );

  @override
  Future<bool> unbanUser({
    required String broadcasterId,
    required String userIdToUnban,
  }) {
    return _$unbanUserAsyncAction.run(
      () => super.unbanUser(
        broadcasterId: broadcasterId,
        userIdToUnban: userIdToUnban,
      ),
    );
  }

  late final _$UserStoreBaseActionController = ActionController(
    name: 'UserStoreBase',
    context: context,
  );

  @override
  void dispose() {
    final _$actionInfo = _$UserStoreBaseActionController.startAction(
      name: 'UserStoreBase.dispose',
    );
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
