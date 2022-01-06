// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'categories_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$CategoriesStore on _CategoriesStoreBase, Store {
  final _$showJumpButtonAtom =
      Atom(name: '_CategoriesStoreBase.showJumpButton');

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

  final _$_categoriesAtom = Atom(name: '_CategoriesStoreBase._categories');

  ObservableList<CategoryTwitch> get categories {
    _$_categoriesAtom.reportRead();
    return super._categories;
  }

  @override
  ObservableList<CategoryTwitch> get _categories => categories;

  @override
  set _categories(ObservableList<CategoryTwitch> value) {
    _$_categoriesAtom.reportWrite(value, super._categories, () {
      super._categories = value;
    });
  }

  final _$_isLoadingAtom = Atom(name: '_CategoriesStoreBase._isLoading');

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

  final _$getCategoriesAsyncAction =
      AsyncAction('_CategoriesStoreBase.getCategories');

  @override
  Future<void> getCategories() {
    return _$getCategoriesAsyncAction.run(() => super.getCategories());
  }

  final _$_CategoriesStoreBaseActionController =
      ActionController(name: '_CategoriesStoreBase');

  @override
  Future<void> refreshCategories() {
    final _$actionInfo = _$_CategoriesStoreBaseActionController.startAction(
        name: '_CategoriesStoreBase.refreshCategories');
    try {
      return super.refreshCategories();
    } finally {
      _$_CategoriesStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
showJumpButton: ${showJumpButton}
    ''';
  }
}
