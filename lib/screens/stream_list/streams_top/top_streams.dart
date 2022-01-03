import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/screens/stream_list/stream_card.dart';
import 'package:frosty/screens/stream_list/streams_top/top_streams_store.dart';
import 'package:frosty/widgets/loading_indicator.dart';

class TopStreams extends StatelessWidget {
  final TopStreamsStore store;

  const TopStreams({Key? key, required this.store}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: store.refresh,
      child: Observer(
        builder: (_) {
          if (store.topStreams.isEmpty && store.isLoading) {
            return const LoadingIndicator(subtitle: Text('Loading top streams...'));
          }
          return ListView.builder(
            itemCount: store.topStreams.length,
            itemBuilder: (context, index) {
              if (index > store.topStreams.length / 2 && store.hasMore) {
                store.getTopStreams();
              }
              return StreamCard(streamInfo: store.topStreams[index]);
            },
          );
        },
      ),
    );
  }
}
