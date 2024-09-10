import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/models/channel.dart';
import 'package:frosty/screens/channel/channel.dart';
import 'package:frosty/screens/home/search/search_store.dart';
import 'package:frosty/utils.dart';
import 'package:frosty/widgets/alert_message.dart';
import 'package:frosty/widgets/loading_indicator.dart';
import 'package:frosty/widgets/profile_picture.dart';
import 'package:frosty/widgets/uptime.dart';
import 'package:frosty/widgets/user_actions_modal.dart';
import 'package:mobx/mobx.dart';

class SearchResultsChannels extends StatefulWidget {
  final SearchStore searchStore;
  final String query;

  const SearchResultsChannels({
    super.key,
    required this.searchStore,
    required this.query,
  });

  @override
  State<SearchResultsChannels> createState() => _SearchResultsChannelsState();
}

class _SearchResultsChannelsState extends State<SearchResultsChannels> {
  Future<void> _handleSearch(BuildContext context, String search) async {
    try {
      final channelInfo = await widget.searchStore.searchChannel(search);

      if (!context.mounted) return;

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
    } catch (error) {
      final snackBar = SnackBar(
        content: AlertMessage(
          message: error.toString(),
          centered: false,
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) {
        final future = widget.searchStore.channelFuture;

        switch (future!.status) {
          case FutureStatus.pending:
            return const SliverToBoxAdapter(
              child: LoadingIndicator(
                subtitle: 'Loading channels...',
              ),
            );
          case FutureStatus.rejected:
            return const SliverToBoxAdapter(
              child: SizedBox(
                height: 100.0,
                child: AlertMessage(message: 'Failed to get channels'),
              ),
            );
          case FutureStatus.fulfilled:
            final results = (future.result as List<ChannelQuery>).where(
              (channel) => !widget.searchStore.authStore.user.blockedUsers
                  .map((blockedUser) => blockedUser.userId)
                  .contains(channel.id),
            );

            return SliverList.list(
              children: [
                ...results.map(
                  (channel) {
                    final displayName = getReadableName(
                      channel.displayName,
                      channel.broadcasterLogin,
                    );

                    return InkWell(
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
                      onLongPress: () {
                        HapticFeedback.lightImpact();

                        showModalBottomSheet(
                          context: context,
                          builder: (context) => UserActionsModal(
                            authStore: widget.searchStore.authStore,
                            name: displayName,
                            userLogin: channel.broadcasterLogin,
                            userId: channel.id,
                          ),
                        );
                      },
                      child: ListTile(
                        title: Text(displayName),
                        leading: ProfilePicture(
                          userLogin: channel.broadcasterLogin,
                          radius: 16,
                        ),
                        subtitle: channel.isLive
                            ? Row(
                                children: [
                                  const Icon(
                                    Icons.circle,
                                    color: Colors.red,
                                    size: 10,
                                  ),
                                  const SizedBox(width: 5),
                                  Uptime(startTime: channel.startedAt),
                                ],
                              )
                            : null,
                      ),
                    );
                  },
                ),
                ListTile(
                  title: Text('Go to channel "${widget.query}"'),
                  onTap: () => _handleSearch(context, widget.query),
                  trailing: const Icon(Icons.chevron_right_rounded),
                ),
              ],
            );
        }
      },
    );
  }
}
