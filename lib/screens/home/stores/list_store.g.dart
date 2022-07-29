// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'list_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$ListStore on ListStoreBase, Store {
  Computed<bool>? _$hasMoreComputed;

  @override
  bool get hasMore => (_$hasMoreComputed ??=
          Computed<bool>(() => super.hasMore, name: 'ListStoreBase.hasMore'))
      .value;
  Computed<ObservableList<StreamTwitch>>? _$streamsComputed;

  @override
  ObservableList<StreamTwitch> get streams => (_$streamsComputed ??=
          Computed<ObservableList<StreamTwitch>>(() => super.streams,
              name: 'ListStoreBase.streams'))
      .value;

  late final _$_isLoadingAtom =
      Atom(name: 'ListStoreBase._isLoading', context: context);

  bool get isLoading {
    _$_isLoadingAtom.reportRead();
    return super._isLoading;
  }

  @override
  bool get _isLoading => isLoading;

  @override
  set _isLoading(bool value) {
    _$_isLoadingAtom.reportWrite(value, super._isLoading, () {
      super._isLoading = value;
    });
  }

  late final _$_allStreamsAtom =
      Atom(name: 'ListStoreBase._allStreams', context: context);

  ObservableList<StreamTwitch> get allStreams {
    _$_allStreamsAtom.reportRead();
    return super._allStreams;
  }

  @override
  ObservableList<StreamTwitch> get _allStreams => allStreams;

  @override
  set _allStreams(ObservableList<StreamTwitch> value) {
    _$_allStreamsAtom.reportWrite(value, super._allStreams, () {
      super._allStreams = value;
    });
  }

  late final _$showJumpButtonAtom =
      Atom(name: 'ListStoreBase.showJumpButton', context: context);

  @override
  bool get showJumpButton {
    _$showJumpButtonAtom.reportRead();
    return super.showJumpButton;
  }

  @override
  set showJumpButton(bool value) {
    _$showJumpButtonAtom.reportWrite(value, super.showJumpButton, () {
      super.showJumpButton = value;
    });
  }

  late final _$_errorAtom =
      Atom(name: 'ListStoreBase._error', context: context);

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

  late final _$getStreamsAsyncAction =
      AsyncAction('ListStoreBase.getStreams', context: context);

  @override
  Future<void> getStreams() {
    return _$getStreamsAsyncAction.run(() => super.getStreams());
  }

  late final _$ListStoreBaseActionController =
      ActionController(name: 'ListStoreBase', context: context);

  @override
  Future<void> refreshStreams() {
    final _$actionInfo = _$ListStoreBaseActionController.startAction(
        name: 'ListStoreBase.refreshStreams');
    try {
      return super.refreshStreams();
    } finally {
      _$ListStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
showJumpButton: ${showJumpButton},
hasMore: ${hasMore},
streams: ${streams}
    ''';
  }
}
