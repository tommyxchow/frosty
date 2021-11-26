import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/screens/categories/category_streams_list/category_streams_store.dart';
import 'package:frosty/screens/stream_list/stream_card.dart';

class CategoryStreams extends StatelessWidget {
  final CategoryStreamsStore store;

  const CategoryStreams({Key? key, required this.store}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('test'),
      ),
      body: RefreshIndicator(
        onRefresh: store.refresh,
        child: Observer(
          builder: (_) {
            return ListView.builder(
              itemCount: store.streams.length,
              itemBuilder: (context, index) {
                if (index > store.streams.length / 2 && store.hasMore) {
                  store.getStreams();
                }
                return StreamCard(streamInfo: store.streams[index]);
              },
            );
          },
        ),
      ),
    );
  }
}
