import 'package:flutter/material.dart';
import 'package:frosty/providers/authentication_provider.dart';
import 'package:frosty/providers/channel_list_provider.dart';
import 'package:frosty/widgets/channel_card.dart';
import 'package:provider/provider.dart';

class ChannelList extends StatefulWidget {
  final Category category;

  ChannelList({Key? key, required this.category}) : super(key: key);

  @override
  _ChannelListState createState() => _ChannelListState();
}

class _ChannelListState extends State<ChannelList> with AutomaticKeepAliveClientMixin<ChannelList> {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Consumer2<AuthenticationProvider, ChannelListProvider>(
      builder: (context, auth, viewModel, child) {
        final channels = viewModel.channels(category: widget.category);
        return ListView.builder(
          itemCount: channels.length,
          padding: EdgeInsets.all(5.0),
          itemBuilder: (context, index) {
            if (index > channels.length / 2 && viewModel.isLoading == false && viewModel.currentCursor(category: widget.category) != null) {
              viewModel.getMoreChannels(category: widget.category);
            }
            return ChannelCard(channelInfo: channels[index]);
          },
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
