// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$SearchStore on SearchStoreBase, Store {
  late final _$_searchHistoryAtom =
      Atom(name: 'SearchStoreBase._searchHistory', context: context);

  ObservableList<String> get searchHistory {
    _$_searchHistoryAtom.reportRead();
    return super._searchHistory;
  }

  @override
  ObservableList<String> get _searchHistory => searchHistory;

  @override
  set _searchHistory(ObservableList<String> value) {
    _$_searchHistoryAtom.reportWrite(value, super._searchHistory, () {
      super._searchHistory = value;
    });
  }

  late final _$_channelFutureAtom =
      Atom(name: 'SearchStoreBase._channelFuture', context: context);

  ObservableFuture<List<ChannelQuery>>? get channelFuture {
    _$_channelFutureAtom.reportRead();
    return super._channelFuture;
  }

  @override
  ObservableFuture<List<ChannelQuery>>? get _channelFuture => channelFuture;

  @override
  set _channelFuture(ObservableFuture<List<ChannelQuery>>? value) {
    _$_channelFutureAtom.reportWrite(value, super._channelFuture, () {
      super._channelFuture = value;
    });
  }

  late final _$_categoryFutureAtom =
      Atom(name: 'SearchStoreBase._categoryFuture', context: context);

  ObservableFuture<CategoriesTwitch?>? get categoryFuture {
    _$_categoryFutureAtom.reportRead();
    return super._categoryFuture;
  }

  @override
  ObservableFuture<CategoriesTwitch?>? get _categoryFuture => categoryFuture;

  @override
  set _categoryFuture(ObservableFuture<CategoriesTwitch?>? value) {
    _$_categoryFutureAtom.reportWrite(value, super._categoryFuture, () {
      super._categoryFuture = value;
    });
  }

  late final _$initAsyncAction =
      AsyncAction('SearchStoreBase.init', context: context);

  @override
  Future<void> init() {
    return _$initAsyncAction.run(() => super.init());
  }

  late final _$handleQueryAsyncAction =
      AsyncAction('SearchStoreBase.handleQuery', context: context);

  @override
  Future<void> handleQuery(String query) {
    return _$handleQueryAsyncAction.run(() => super.handleQuery(query));
  }

  @override
  String toString() {
    return '''

    ''';
  }
}
