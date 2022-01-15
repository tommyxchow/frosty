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

  final _$_errorAtom = Atom(name: '_CategoriesStoreBase._error');

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
