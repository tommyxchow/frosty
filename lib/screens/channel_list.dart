import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/stores/channel_list_store.dart';
import 'package:frosty/widgets/channel_card.dart';
import 'package:provider/provider.dart';

class ChannelList extends StatefulWidget {
  final Category category;

  const ChannelList({Key? key, required this.category}) : super(key: key);

  @override
  _ChannelListState createState() => _ChannelListState();
}

class _ChannelListState extends State<ChannelList> with AutomaticKeepAliveClientMixin<ChannelList> {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    final channelListStore = context.read<ChannelListStore>();
    return Observer(
      builder: (_) {
        final channels = channelListStore.channels(category: widget.category);
        return RefreshIndicator(
          child: ListView.builder(
            itemCount: channels.length,
            padding: const EdgeInsets.all(5.0),
            itemBuilder: (context, index) {
              if (index > channels.length / 2 && channelListStore.isLoading == false && channelListStore.currentCursor(category: widget.category) != null) {
                channelListStore.getMoreChannels(category: widget.category);
              }
              return ChannelCard(channelInfo: channels[index]);
            },
          ),
          onRefresh: () => channelListStore.update(category: widget.category),
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
