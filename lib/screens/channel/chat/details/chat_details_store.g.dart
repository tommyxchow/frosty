// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_details_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$ChatDetailsStore on ChatDetailsStoreBase, Store {
  Computed<Iterable<String>>? _$filteredUsersComputed;

  @override
  Iterable<String> get filteredUsers => (_$filteredUsersComputed ??=
          Computed<Iterable<String>>(() => super.filteredUsers,
              name: 'ChatDetailsStoreBase.filteredUsers'))
      .value;

  late final _$roomStateAtom =
      Atom(name: 'ChatDetailsStoreBase.roomState', context: context);

  @override
  ROOMSTATE get roomState {
    _$roomStateAtom.reportRead();
    return super.roomState;
  }

  @override
  set roomState(ROOMSTATE value) {
    _$roomStateAtom.reportWrite(value, super.roomState, () {
      super.roomState = value;
    });
  }

  late final _$showJumpButtonAtom =
      Atom(name: 'ChatDetailsStoreBase.showJumpButton', context: context);

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

  late final _$_filterTextAtom =
      Atom(name: 'ChatDetailsStoreBase._filterText', context: context);

  String get filterText {
    _$_filterTextAtom.reportRead();
    return super._filterText;
  }

  @override
  String get _filterText => filterText;

  @override
  set _filterText(String value) {
    _$_filterTextAtom.reportWrite(value, super._filterText, () {
      super._filterText = value;
    });
  }

  @override
  String toString() {
    return '''
roomState: ${roomState},
showJumpButton: ${showJumpButton},
filteredUsers: ${filteredUsers}
    ''';
  }
}
