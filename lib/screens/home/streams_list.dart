import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/screens/home/stores/list_store.dart';
import 'package:frosty/screens/settings/stores/settings_store.dart';
import 'package:frosty/widgets/loading_indicator.dart';
import 'package:frosty/widgets/stream_card.dart';
import 'package:provider/provider.dart';

class StreamsList extends StatelessWidget {
  final ListStore store;

  const StreamsList({Key? key, required this.store}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: store.refresh,
      child: Observer(
        builder: (_) {
          if (store.streams.isEmpty && store.isLoading) {
            return const LoadingIndicator(subtitle: Text('Loading streams...'));
          }
          return ListView.builder(
            itemCount: store.streams.length,
            itemBuilder: (context, index) {
              if (index > store.streams.length / 2 && store.hasMore) {
                store.getData();
              }
              return Observer(
                builder: (context) => StreamCard(
                  streamInfo: store.streams[index],
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
