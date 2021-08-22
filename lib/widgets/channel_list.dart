import 'package:flutter/material.dart';
import 'package:frosty/providers/authentication_provider.dart';
import 'package:frosty/providers/channel_list_provider.dart';
import 'package:frosty/widgets/channel_card.dart';
import 'package:provider/provider.dart';

class ChannelList extends StatelessWidget {
  const ChannelList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer2<Authentication, ChannelListProvider>(
      builder: (context, auth, provider, child) {
        return FutureBuilder(
          future: provider.getTopChannels(token: auth.token!),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
                // TODO: Handle this case.
                break;
              case ConnectionState.waiting:
                // TODO: Handle this case.
                break;
              case ConnectionState.active:
                // TODO: Handle this case.
                break;
              case ConnectionState.done:
                return ListView.builder(
                  itemBuilder: (context, index) {
                    print(index);
                    if (index >= provider.channels.length / 2) {
                      print('fetching more channels...');
                      print(provider.channels.length);
                      provider.getTopChannels(token: auth.token!);
                    }
                    return ChannelCard(channelInfo: provider.channels[index]);
                  },
                );
            }
            return Text('loading');
          },
        );
      },
    );
  }
}
