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
topChannels: ${topChannels},
followedChannels: ${followedChannels}
    ''';
  }
}
