import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/screens/followed_streams/followed_streams_store.dart';
import 'package:frosty/widgets/loading_indicator.dart';
import 'package:frosty/widgets/stream_card.dart';

class FollowedStreams extends StatelessWidget {
  final FollowedStreamsStore store;

  const FollowedStreams({Key? key, required this.store}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: store.refresh,
      child: Observer(
        builder: (_) {
          if (store.followedStreams.isEmpty && store.isLoading) {
            return const LoadingIndicator(
              subtitle: Text('Loading followed streams...'),
            );
          }
          return ListView.builder(
            itemCount: store.followedStreams.length,
            itemBuilder: (context, index) {
              if (index > store.followedStreams.length / 2 && store.hasMore) {
                store.getFollowedStreams();
              }
              return StreamCard(streamInfo: store.followedStreams[index]);
            },
          );
        },
      ),
    );
  }
}
