// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$AuthStore on AuthBase, Store {
  Computed<Map<String, String>>? _$headersTwitchComputed;

  @override
  Map<String, String> get headersTwitch => (_$headersTwitchComputed ??=
          Computed<Map<String, String>>(() => super.headersTwitch,
              name: 'AuthBase.headersTwitch'))
      .value;

  late final _$_tokenAtom = Atom(name: 'AuthBase._token', context: context);

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

  late final _$_isLoggedInAtom =
      Atom(name: 'AuthBase._isLoggedIn', context: context);

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

  late final _$_errorAtom = Atom(name: 'AuthBase._error', context: context);

  String? get error {
    _$_errorAtom.reportRead();
    return super._error;
  }

  @override
  String? get _error => error;

  @override
  set _error(String? value) {
    _$_errorAtom.reportWrite(value, super._error, () {
      super._error = value;
    });
  }

  late final _$initAsyncAction = AsyncAction('AuthBase.init', context: context);

  @override
  Future<void> init() {
    return _$initAsyncAction.run(() => super.init());
  }

  late final _$loginAsyncAction =
      AsyncAction('AuthBase.login', context: context);

  @override
  Future<void> login({required String token}) {
    return _$loginAsyncAction.run(() => super.login(token: token));
  }

  late final _$logoutAsyncAction =
      AsyncAction('AuthBase.logout', context: context);

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
