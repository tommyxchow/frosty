// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$SearchStore on _SearchStoreBase, Store {
  final _$_searchResultsAtom = Atom(name: '_SearchStoreBase._searchResults');

  ObservableList<ChannelQuery> get searchResults {
    _$_searchResultsAtom.reportRead();
    return super._searchResults;
  }

  @override
  ObservableList<ChannelQuery> get _searchResults => searchResults;

  @override
  set _searchResults(ObservableList<ChannelQuery> value) {
    _$_searchResultsAtom.reportWrite(value, super._searchResults, () {
      super._searchResults = value;
    });
  }

  final _$handleQueryAsyncAction = AsyncAction('_SearchStoreBase.handleQuery');

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
