import 'package:frosty/api/twitch_api.dart';
import 'package:mobx/mobx.dart';
import 'package:frosty/stores/auth_store.dart';
import 'package:frosty/models/channel.dart';

part 'channel_list_store.g.dart';

class ChannelListStore = _ChannelListBase with _$ChannelListStore;

abstract class _ChannelListBase with Store {
  @observable
  ObservableList<Channel> topChannels = ObservableList<Channel>();

  @observable
  ObservableList<Channel> followedChannels = ObservableList<Channel>();

  bool isLoading = false;

  String? topChannelsCurrentCursor;

  String? followedChannelsCurrentCursor;

  ObservableList<Channel> channels({required ChannelCategory category}) {
    switch (category) {
      case ChannelCategory.top:
        return topChannels;
      case ChannelCategory.followed:
        return followedChannels;
    }
  }

  final AuthStore auth;

  _ChannelListBase({required this.auth}) {
    getChannels(category: ChannelCategory.top);

    if (auth.user?.id != null) {
      getChannels(category: ChannelCategory.followed);
    }
  }

  bool hasMore({required ChannelCategory category}) {
    switch (category) {
      case ChannelCategory.top:
        return isLoading == false && topChannelsCurrentCursor != null;
      case ChannelCategory.followed:
        return isLoading == false && followedChannelsCurrentCursor != null;
    }
  }

  @action
  Future<void> refresh({required ChannelCategory category}) async {
    switch (category) {
      case ChannelCategory.top:
        topChannelsCurrentCursor = null;
        break;
      case ChannelCategory.followed:
        followedChannelsCurrentCursor = null;
        break;
    }

    await getChannels(category: category);
  }

  @action
  Future<void> getChannels({required ChannelCategory category}) async {
    isLoading = true;

    switch (category) {
      case ChannelCategory.top:
        final newTopChannels = await Twitch.getTopChannels(headers: auth.headersTwitch, cursor: topChannelsCurrentCursor);

        if (newTopChannels != null) {
          if (topChannelsCurrentCursor == null) {
            topChannels = ObservableList.of(newTopChannels['channels']);
          } else {
            topChannels.addAll(newTopChannels['channels']);
          }
          topChannelsCurrentCursor = newTopChannels['cursor'];
        }
        break;
      case ChannelCategory.followed:
        final newFollowedChannels = await Twitch.getFollowedChannels(id: auth.user!.id, headers: auth.headersTwitch, cursor: followedChannelsCurrentCursor);

        if (newFollowedChannels != null) {
          if (followedChannelsCurrentCursor == null) {
            followedChannels = ObservableList.of(newFollowedChannels['channels']);
          } else {
            followedChannels.addAll(newFollowedChannels['channels']);
          }
          followedChannelsCurrentCursor = newFollowedChannels['cursor'];
        }
        break;
    }

    isLoading = false;
  }
}

enum ChannelCategory { top, followed }
