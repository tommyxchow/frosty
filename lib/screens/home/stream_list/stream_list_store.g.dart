// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stream_list_store.dart';

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
  Computed<bool>? _$isLoadingComputed;

  @override
  bool get isLoading =>
      (_$isLoadingComputed ??= Computed<bool>(() => super.isLoading,
              name: 'ListStoreBase.isLoading'))
          .value;
  Computed<ObservableList<StreamTwitch>>? _$streamsComputed;

  @override
  ObservableList<StreamTwitch> get streams => (_$streamsComputed ??=
          Computed<ObservableList<StreamTwitch>>(() => super.streams,
              name: 'ListStoreBase.streams'))
      .value;

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

  late final _$_isAllStreamsLoadingAtom =
      Atom(name: 'ListStoreBase._isAllStreamsLoading', context: context);

  bool get isAllStreamsLoading {
    _$_isAllStreamsLoadingAtom.reportRead();
    return super._isAllStreamsLoading;
  }

  @override
  bool get _isAllStreamsLoading => isAllStreamsLoading;

  @override
  set _isAllStreamsLoading(bool value) {
    _$_isAllStreamsLoadingAtom.reportWrite(value, super._isAllStreamsLoading,
        () {
      super._isAllStreamsLoading = value;
    });
  }

  late final _$_pinnedStreamsAtom =
      Atom(name: 'ListStoreBase._pinnedStreams', context: context);

  ObservableList<StreamTwitch> get pinnedStreams {
    _$_pinnedStreamsAtom.reportRead();
    return super._pinnedStreams;
  }

  @override
  ObservableList<StreamTwitch> get _pinnedStreams => pinnedStreams;

  @override
  set _pinnedStreams(ObservableList<StreamTwitch> value) {
    _$_pinnedStreamsAtom.reportWrite(value, super._pinnedStreams, () {
      super._pinnedStreams = value;
    });
  }

  late final _$_isPinnedStreamsLoadingAtom =
      Atom(name: 'ListStoreBase._isPinnedStreamsLoading', context: context);

  bool get isPinnedStreamsLoading {
    _$_isPinnedStreamsLoadingAtom.reportRead();
    return super._isPinnedStreamsLoading;
  }

  @override
  bool get _isPinnedStreamsLoading => isPinnedStreamsLoading;

  @override
  set _isPinnedStreamsLoading(bool value) {
    _$_isPinnedStreamsLoadingAtom
        .reportWrite(value, super._isPinnedStreamsLoading, () {
      super._isPinnedStreamsLoading = value;
    });
  }

  late final _$_categoryDetailsAtom =
      Atom(name: 'ListStoreBase._categoryDetails', context: context);

  CategoryTwitch? get categoryDetails {
    _$_categoryDetailsAtom.reportRead();
    return super._categoryDetails;
  }

  @override
  CategoryTwitch? get _categoryDetails => categoryDetails;

  @override
  set _categoryDetails(CategoryTwitch? value) {
    _$_categoryDetailsAtom.reportWrite(value, super._categoryDetails, () {
      super._categoryDetails = value;
    });
  }

  late final _$_isCategoryDetailsLoadingAtom =
      Atom(name: 'ListStoreBase._isCategoryDetailsLoading', context: context);

  bool get isCategoryDetailsLoading {
    _$_isCategoryDetailsLoadingAtom.reportRead();
    return super._isCategoryDetailsLoading;
  }

  @override
  bool get _isCategoryDetailsLoading => isCategoryDetailsLoading;

  @override
  set _isCategoryDetailsLoading(bool value) {
    _$_isCategoryDetailsLoadingAtom
        .reportWrite(value, super._isCategoryDetailsLoading, () {
      super._isCategoryDetailsLoading = value;
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

  late final _$getPinnedStreamsAsyncAction =
      AsyncAction('ListStoreBase.getPinnedStreams', context: context);

  @override
  Future<void> getPinnedStreams() {
    return _$getPinnedStreamsAsyncAction.run(() => super.getPinnedStreams());
  }

  late final _$refreshStreamsAsyncAction =
      AsyncAction('ListStoreBase.refreshStreams', context: context);

  @override
  Future<void> refreshStreams() {
    return _$refreshStreamsAsyncAction.run(() => super.refreshStreams());
  }

  late final _$_getCategoryDetailsAsyncAction =
      AsyncAction('ListStoreBase._getCategoryDetails', context: context);

  @override
  Future<void> _getCategoryDetails() {
    return _$_getCategoryDetailsAsyncAction
        .run(() => super._getCategoryDetails());
  }

  @override
  String toString() {
    return '''
showJumpButton: ${showJumpButton},
hasMore: ${hasMore},
isLoading: ${isLoading},
streams: ${streams}
    ''';
  }
}
