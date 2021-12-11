// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$AuthStore on _AuthBase, Store {
  Computed<Map<String, String>>? _$headersTwitchComputed;

  @override
  Map<String, String> get headersTwitch => (_$headersTwitchComputed ??=
          Computed<Map<String, String>>(() => super.headersTwitch,
              name: '_AuthBase.headersTwitch'))
      .value;

  final _$_tokenAtom = Atom(name: '_AuthBase._token');

  String? get token {
    _$_tokenAtom.reportRead();
    return super._token;
  }

  @override
  String? get _token => token;

  @override
  set _token(String? value) {
    _$_tokenAtom.reportWrite(value, super._token, () {
      super._token = value;
    });
  }

  final _$_userAtom = Atom(name: '_AuthBase._user');

  UserTwitch? get user {
    _$_userAtom.reportRead();
    return super._user;
  }

  @override
  UserTwitch? get _user => user;

  @override
  set _user(UserTwitch? value) {
    _$_userAtom.reportWrite(value, super._user, () {
      super._user = value;
    });
  }

  final _$_blockedUsersAtom = Atom(name: '_AuthBase._blockedUsers');

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

  final _$_isLoggedInAtom = Atom(name: '_AuthBase._isLoggedIn');

  bool get isLoggedIn {
    _$_isLoggedInAtom.reportRead();
    return super._isLoggedIn;
  }

  @override
  bool get _isLoggedIn => isLoggedIn;

  @override
  set _isLoggedIn(bool value) {
    _$_isLoggedInAtom.reportWrite(value, super._isLoggedIn, () {
      super._isLoggedIn = value;
    });
  }

  final _$initAsyncAction = AsyncAction('_AuthBase.init');

  @override
  Future<void> init() {
    return _$initAsyncAction.run(() => super.init());
  }

  final _$loginAsyncAction = AsyncAction('_AuthBase.login');

  @override
  Future<void> login() {
    return _$loginAsyncAction.run(() => super.login());
  }

  final _$logoutAsyncAction = AsyncAction('_AuthBase.logout');

  @override
  Future<void> logout() {
    return _$logoutAsyncAction.run(() => super.logout());
  }

  @override
  String toString() {
    return '''
headersTwitch: ${headersTwitch}
    ''';
  }
}
