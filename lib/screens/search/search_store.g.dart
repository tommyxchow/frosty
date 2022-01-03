// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$SearchStore on _SearchStoreBase, Store {
  final _$_searchHistoryAtom = Atom(name: '_SearchStoreBase._searchHistory');

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

  final _$_channelSearchResultsAtom =
      Atom(name: '_SearchStoreBase._channelSearchResults');

  List<ChannelQuery> get channelSearchResults {
    _$_channelSearchResultsAtom.reportRead();
    return super._channelSearchResults;
  }

  @override
  List<ChannelQuery> get _channelSearchResults => channelSearchResults;

  @override
  set _channelSearchResults(List<ChannelQuery> value) {
    _$_channelSearchResultsAtom.reportWrite(value, super._channelSearchResults,
        () {
      super._channelSearchResults = value;
    });
  }

  final _$_categorySearchResultsAtom =
      Atom(name: '_SearchStoreBase._categorySearchResults');

  List<CategoryTwitch> get categorySearchResults {
    _$_categorySearchResultsAtom.reportRead();
    return super._categorySearchResults;
  }

  @override
  List<CategoryTwitch> get _categorySearchResults => categorySearchResults;

  @override
  set _categorySearchResults(List<CategoryTwitch> value) {
    _$_categorySearchResultsAtom
        .reportWrite(value, super._categorySearchResults, () {
      super._categorySearchResults = value;
    });
  }

  final _$initAsyncAction = AsyncAction('_SearchStoreBase.init');

  @override
  Future<void> init() {
    return _$initAsyncAction.run(() => super.init());
  }

  final _$handleQueryAsyncAction = AsyncAction('_SearchStoreBase.handleQuery');

  @override
  Future<void> handleQuery(String query) {
    return _$handleQueryAsyncAction.run(() => super.handleQuery(query));
  }

  final _$_SearchStoreBaseActionController =
      ActionController(name: '_SearchStoreBase');

  @override
  void clearSearch() {
    final _$actionInfo = _$_SearchStoreBaseActionController.startAction(
        name: '_SearchStoreBase.clearSearch');
    try {
      return super.clearSearch();
    } finally {
      _$_SearchStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''

    ''';
  }
}
