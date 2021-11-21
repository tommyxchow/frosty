import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/stores/stream_list_store.dart';
import 'package:frosty/widgets/stream_card.dart';

class StreamList extends StatelessWidget {
  final StreamCategory category;
  final StreamListStore streamListStore;

  const StreamList({Key? key, required this.category, required this.streamListStore}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => streamListStore.refresh(category: category),
      child: Observer(
        builder: (_) {
          return ListView.builder(
            itemCount: streamListStore.streams(category: category).length,
            itemBuilder: (context, index) {
              if (index > streamListStore.streams(category: category).length / 2 && streamListStore.hasMore(category: category)) {
                streamListStore.getStreams(category: category);
              }
              return StreamCard(streamInfo: streamListStore.streams(category: category)[index]);
            },
          );
        },
      ),
    );
  }
}
