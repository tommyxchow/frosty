import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/core/settings/settings_store.dart';
import 'package:frosty/screens/top/streams/top_streams_store.dart';
import 'package:frosty/widgets/loading_indicator.dart';
import 'package:frosty/widgets/stream_card.dart';
import 'package:provider/provider.dart';

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
              return Observer(
                builder: (context) => StreamCard(
                  streamInfo: store.topStreams[index],
                  showUptime: context.read<SettingsStore>().showThumbnailUptime,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
