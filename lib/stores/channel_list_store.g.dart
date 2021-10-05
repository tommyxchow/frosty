// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'channel_list_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$ChannelListStore on _ChannelListBase, Store {
  final _$_topChannelsAtom = Atom(name: '_ChannelListBase._topChannels');

  @override
  ObservableList<Channel> get _topChannels {
    _$_topChannelsAtom.reportRead();
    return super._topChannels;
  }

  @override
  set _topChannels(ObservableList<Channel> value) {
    _$_topChannelsAtom.reportWrite(value, super._topChannels, () {
      super._topChannels = value;
    });
  }

  final _$_followedChannelsAtom =
      Atom(name: '_ChannelListBase._followedChannels');

  @override
  ObservableList<Channel> get _followedChannels {
    _$_followedChannelsAtom.reportRead();
    return super._followedChannels;
  }

  @override
  set _followedChannels(ObservableList<Channel> value) {
    _$_followedChannelsAtom.reportWrite(value, super._followedChannels, () {
      super._followedChannels = value;
    });
  }

  final _$refreshAsyncAction = AsyncAction('_ChannelListBase.refresh');

  @override
  Future<void> refresh({required ChannelCategory category}) {
    return _$refreshAsyncAction.run(() => super.refresh(category: category));
  }

  final _$getChannelsAsyncAction = AsyncAction('_ChannelListBase.getChannels');

  @override
  Future<void> getChannels({required ChannelCategory category}) {
    return _$getChannelsAsyncAction
        .run(() => super.getChannels(category: category));
  }

  @override
  String toString() {
    return '''

    ''';
  }
}
