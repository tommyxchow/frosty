// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$VideoStore on _VideoStoreBase, Store {
  final _$menuVisibleAtom = Atom(name: '_VideoStoreBase.menuVisible');

  @override
  bool get menuVisible {
    _$menuVisibleAtom.reportRead();
    return super.menuVisible;
  }

  @override
  set menuVisible(bool value) {
    _$menuVisibleAtom.reportWrite(value, super.menuVisible, () {
      super.menuVisible = value;
    });
  }

  final _$pausedAtom = Atom(name: '_VideoStoreBase.paused');

  @override
  bool get paused {
    _$pausedAtom.reportRead();
    return super.paused;
  }

  @override
  set paused(bool value) {
    _$pausedAtom.reportWrite(value, super.paused, () {
      super.paused = value;
    });
  }

  @override
  String toString() {
    return '''
menuVisible: ${menuVisible},
paused: ${paused}
    ''';
  }
}
