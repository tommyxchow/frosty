import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/stores/channel_list_store.dart';
import 'package:frosty/widgets/channel_card.dart';

class ChannelList extends StatefulWidget {
  final ChannelCategory category;
  final ChannelListStore channelListStore;

  const ChannelList({Key? key, required this.category, required this.channelListStore}) : super(key: key);

  @override
  _ChannelListState createState() => _ChannelListState();
}

class _ChannelListState extends State<ChannelList> with AutomaticKeepAliveClientMixin<ChannelList> {
  @override
  Widget build(BuildContext context) {
    debugPrint('build channel list');
    super.build(context);

    return RefreshIndicator(
      child: Observer(
        builder: (_) {
          final channels = widget.channelListStore.channels(category: widget.category);
          return ListView.builder(
            itemCount: channels.length,
            padding: const EdgeInsets.all(5.0),
            itemBuilder: (context, index) {
              if (index > channels.length / 2 && widget.channelListStore.hasMore(category: widget.category)) {
                widget.channelListStore.getChannels(category: widget.category);
              }
              return ChannelCard(channelInfo: channels.elementAt(index));
            },
          );
        },
      ),
      onRefresh: () => widget.channelListStore.refresh(category: widget.category),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
