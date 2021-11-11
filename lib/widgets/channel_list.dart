import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/stores/channel_list_store.dart';
import 'package:frosty/widgets/channel_card.dart';

class ChannelList extends StatelessWidget {
  final ChannelCategory category;
  final ChannelListStore channelListStore;

  const ChannelList({Key? key, required this.category, required this.channelListStore}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    debugPrint('Build channel list!');

    return RefreshIndicator(
      child: Observer(
        builder: (_) {
          return ListView.builder(
            itemCount: channelListStore.channels(category: category).length,
            padding: const EdgeInsets.all(5.0),
            itemBuilder: (context, index) {
              if (index > channelListStore.channels(category: category).length / 2 && channelListStore.hasMore(category: category)) {
                channelListStore.getChannels(category: category);
              }
              return ChannelCard(channelInfo: channelListStore.channels(category: category).elementAt(index));
            },
          );
        },
      ),
      onRefresh: () => channelListStore.refresh(category: category),
    );
  }
}
