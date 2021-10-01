// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'channel_list_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$ChannelListStore on _ChannelListBase, Store {
  final _$topChannelsAtom = Atom(name: '_ChannelListBase.topChannels');

  @override
  ObservableList<Channel> get topChannels {
    _$topChannelsAtom.reportRead();
    return super.topChannels;
  }

  @override
  set topChannels(ObservableList<Channel> value) {
    _$topChannelsAtom.reportWrite(value, super.topChannels, () {
      super.topChannels = value;
    });
  }

  final _$followedChannelsAtom =
      Atom(name: '_ChannelListBase.followedChannels');

  @override
  ObservableList<Channel> get followedChannels {
    _$followedChannelsAtom.reportRead();
    return super.followedChannels;
  }

  @override
  set followedChannels(ObservableList<Channel> value) {
    _$followedChannelsAtom.reportWrite(value, super.followedChannels, () {
      super.followedChannels = value;
    });
  }

  final _$isLoadingAtom = Atom(name: '_ChannelListBase.isLoading');

  @override
  bool get isLoading {
    _$isLoadingAtom.reportRead();
    return super.isLoading;
  }

  @override
  set isLoading(bool value) {
    _$isLoadingAtom.reportWrite(value, super.isLoading, () {
      super.isLoading = value;
    });
  }

  final _$topChannelsCurrentCursorAtom =
      Atom(name: '_ChannelListBase.topChannelsCurrentCursor');

  @override
  String? get topChannelsCurrentCursor {
    _$topChannelsCurrentCursorAtom.reportRead();
    return super.topChannelsCurrentCursor;
  }

  @override
  set topChannelsCurrentCursor(String? value) {
    _$topChannelsCurrentCursorAtom
        .reportWrite(value, super.topChannelsCurrentCursor, () {
      super.topChannelsCurrentCursor = value;
    });
  }

  final _$followedChannelsCurrentCursorAtom =
      Atom(name: '_ChannelListBase.followedChannelsCurrentCursor');

  @override
  String? get followedChannelsCurrentCursor {
    _$followedChannelsCurrentCursorAtom.reportRead();
    return super.followedChannelsCurrentCursor;
  }

  @override
  set followedChannelsCurrentCursor(String? value) {
    _$followedChannelsCurrentCursorAtom
        .reportWrite(value, super.followedChannelsCurrentCursor, () {
      super.followedChannelsCurrentCursor = value;
    });
  }

  final _$updateAsyncAction = AsyncAction('_ChannelListBase.update');

  @override
  Future<void> update({required Category category}) {
    return _$updateAsyncAction.run(() => super.update(category: category));
  }

  final _$updateTopChannelsAsyncAction =
      AsyncAction('_ChannelListBase.updateTopChannels');

  @override
  Future<void> updateTopChannels() {
    return _$updateTopChannelsAsyncAction.run(() => super.updateTopChannels());
  }

  final _$getMoreChannelsAsyncAction =
      AsyncAction('_ChannelListBase.getMoreChannels');

  @override
  Future<void> getMoreChannels({required Category category}) {
    return _$getMoreChannelsAsyncAction
        .run(() => super.getMoreChannels(category: category));
  }

  final _$updateFollowedChannelsAsyncAction =
      AsyncAction('_ChannelListBase.updateFollowedChannels');

  @override
  Future<void> updateFollowedChannels() {
    return _$updateFollowedChannelsAsyncAction
        .run(() => super.updateFollowedChannels());
  }

  @override
  String toString() {
    return '''
topChannels: ${topChannels},
followedChannels: ${followedChannels},
isLoading: ${isLoading},
topChannelsCurrentCursor: ${topChannelsCurrentCursor},
followedChannelsCurrentCursor: ${followedChannelsCurrentCursor}
    ''';
  }
}
