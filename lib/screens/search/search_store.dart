import 'package:flutter/material.dart';
import 'package:frosty/api/twitch_api.dart';
import 'package:frosty/core/auth/auth_store.dart';
import 'package:frosty/models/channel.dart';
import 'package:frosty/screens/channel/video_chat.dart';
import 'package:mobx/mobx.dart';
import 'package:provider/provider.dart';

part 'search_store.g.dart';

class SearchStore = _SearchStoreBase with _$SearchStore;

abstract class _SearchStoreBase with Store {
  final textController = TextEditingController();

  final AuthStore authStore;

  @observable
  var _searchResults = ObservableList<ChannelQuery>();
  ObservableList<ChannelQuery> get searchResults => _searchResults;

  _SearchStoreBase({required this.authStore});

  @action
  Future<void> handleQuery(String query) async {
    final results = await Twitch.searchChannels(query: query, headers: authStore.headersTwitch);
    results.sort((c1, c2) => c2.isLive ? 1 : -1);

    _searchResults = ObservableList.of(results);
  }

  Future<void> handleSearch(String search, BuildContext context) async {
    final user = await Twitch.getUser(userLogin: search, headers: authStore.headersTwitch);
    if (user != null) {
      final channelInfo = await Twitch.getChannel(userId: user.id, headers: context.read<AuthStore>().headersTwitch);
      if (channelInfo != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) {
              return VideoChat(
                title: channelInfo.title,
                userName: channelInfo.broadcasterName,
                userLogin: channelInfo.broadcasterLogin,
              );
            },
          ),
        );
      } else {
        const snackBar = SnackBar(content: Text('Failed to get channel info :('));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } else {
      const snackBar = SnackBar(content: Text('User does not exist :('));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
    textController.clear();
  }

  void dispose() {
    textController.dispose();
  }
}
