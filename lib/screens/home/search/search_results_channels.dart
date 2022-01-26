import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/constants/constants.dart';
import 'package:frosty/models/channel.dart';
import 'package:frosty/screens/channel/video_chat.dart';
import 'package:frosty/screens/home/stores/search_store.dart';
import 'package:frosty/widgets/loading_indicator.dart';
import 'package:frosty/widgets/profile_picture.dart';
import 'package:mobx/mobx.dart';

class SearchResultsChannels extends StatelessWidget {
  final SearchStore searchStore;
  final String query;

  const SearchResultsChannels({
    Key? key,
    required this.searchStore,
    required this.query,
  }) : super(key: key);

  Future<void> _handleSearch(BuildContext context, String search) async {
    try {
      final channelInfo = await searchStore.searchChannel(search);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VideoChat(
            userId: channelInfo.broadcasterId,
            userName: channelInfo.broadcasterName,
            userLogin: channelInfo.broadcasterLogin,
          ),
        ),
      );
    } catch (e) {
      final snackBar = SnackBar(
        content: Text(e.toString()),
        behavior: SnackBarBehavior.floating,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) {
        final future = searchStore.channelFuture;

        switch (future!.status) {
          case FutureStatus.pending:
            return const SliverToBoxAdapter(
              child: LoadingIndicator(
                subtitle: Text('Loading channels...'),
              ),
            );
          case FutureStatus.rejected:
            return const SliverToBoxAdapter(
              child: Center(
                child: Text('Failed to get channels'),
              ),
            );
          case FutureStatus.fulfilled:
            final List<ChannelQuery> results = future.result;

            return SliverList(
              delegate: SliverChildListDelegate.fixed([
                ...results.map(
                  (channel) => ListTile(
                    title: Text(
                        regexEnglish.hasMatch(channel.displayName) ? channel.displayName : channel.displayName + ' (${channel.broadcasterLogin})'),
                    leading: ProfilePicture(userLogin: channel.broadcasterLogin),
                    trailing: channel.isLive
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(5.0),
                            child: Container(
                              color: const Color(0xFFF44336),
                              padding: const EdgeInsets.all(10.0),
                              child: const Text(
                                'LIVE',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          )
                        : null,
                    subtitle: channel.isLive
                        ? Text('Uptime: ${DateTime.now().difference(DateTime.parse(channel.startedAt)).toString().split('.')[0]}')
                        : null,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VideoChat(
                          userId: channel.id,
                          userName: channel.displayName,
                          userLogin: channel.broadcasterLogin,
                        ),
                      ),
                    ),
                  ),
                ),
                ListTile(
                  title: Text('Go to channel "$query"'),
                  onTap: () => _handleSearch(context, query),
                  trailing: Icon(Icons.adaptive.arrow_forward),
                )
              ]),
            );
        }
      },
    );
  }
}
