import 'package:frosty/api/twitch_api.dart';
import 'package:mobx/mobx.dart';
import 'package:frosty/stores/auth_store.dart';
import 'package:frosty/models/channel.dart';

part 'channel_list_store.g.dart';

// TODO: Fix followed list refresh when log in.
class ChannelListStore = _ChannelListBase with _$ChannelListStore;

abstract class _ChannelListBase with Store {
  /// The list of the fetched top channels
  @observable
  var _topChannels = ObservableList<Channel>();

  /// The list of the fetched followed channels
  @observable
  var _followedChannels = ObservableList<Channel>();

  /// The loading status for pagination.
  bool _isLoading = false;

  /// The pagination cursor for top channels.
  String? _topChannelsCurrentCursor;

  /// The pagination cursor for followed channels.
  String? _followedChannelsCurrentCursor;

  /// The authentication store.
  final AuthStore authStore;

  _ChannelListBase({required this.authStore}) {
    getChannels(category: ChannelCategory.top);

    if (authStore.user?.id != null) {
      getChannels(category: ChannelCategory.followed);
    }
  }

  /// Returns the appropriate channels the [category].
  ObservableList<Channel> channels({required ChannelCategory category}) {
    switch (category) {
      case ChannelCategory.top:
        return _topChannels;
      case ChannelCategory.followed:
        return _followedChannels;
    }
  }

  /// Returns whether or not there are more channels for the [category].
  bool hasMore({required ChannelCategory category}) {
    switch (category) {
      case ChannelCategory.top:
        return _isLoading == false && _topChannelsCurrentCursor != null;
      case ChannelCategory.followed:
        return _isLoading == false && _followedChannelsCurrentCursor != null;
    }
  }

  /// Resets the cursor and then fetches the channels for the [category].
  @action
  Future<void> refresh({required ChannelCategory category}) async {
    switch (category) {
      case ChannelCategory.top:
        _topChannelsCurrentCursor = null;
        break;
      case ChannelCategory.followed:
        _followedChannelsCurrentCursor = null;
        break;
    }

    await getChannels(category: category);
  }

  /// Fetches the channels for the [category] based on the current cursor.
  @action
  Future<void> getChannels({required ChannelCategory category}) async {
    _isLoading = true;

    switch (category) {
      case ChannelCategory.top:
        final newTopChannels = await Twitch.getTopChannels(headers: authStore.headersTwitch, cursor: _topChannelsCurrentCursor);

        if (newTopChannels != null) {
          if (_topChannelsCurrentCursor == null) {
            _topChannels = ObservableList.of(newTopChannels['channels']);
          } else {
            _topChannels.addAll(newTopChannels['channels']);
          }
          _topChannelsCurrentCursor = newTopChannels['cursor'];
        }
        break;
      case ChannelCategory.followed:
        final newFollowedChannels =
            await Twitch.getFollowedChannels(id: authStore.user!.id, headers: authStore.headersTwitch, cursor: _followedChannelsCurrentCursor);

        if (newFollowedChannels != null) {
          if (_followedChannelsCurrentCursor == null) {
            _followedChannels = ObservableList.of(newFollowedChannels['channels']);
          } else {
            _followedChannels.addAll(newFollowedChannels['channels']);
          }
          _followedChannelsCurrentCursor = newFollowedChannels['cursor'];
        }
        break;
    }

    _isLoading = false;
  }
}

/// The type of category for channels.
enum ChannelCategory { top, followed }
