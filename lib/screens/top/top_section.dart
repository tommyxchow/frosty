import 'package:flutter/material.dart';
import 'package:frosty/screens/top/categories/categories.dart';
import 'package:frosty/screens/top/categories/categories_store.dart';
import 'package:frosty/screens/top/streams/top_streams.dart';
import 'package:frosty/screens/top/streams/top_streams_store.dart';

class TopSection extends StatelessWidget {
  final TopStreamsStore topStreamsStore;
  final CategoriesStore categoriesStore;

  const TopSection({
    Key? key,
    required this.topStreamsStore,
    required this.categoriesStore,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(text: 'Streams'),
              Tab(text: 'Categories'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                TopStreams(store: topStreamsStore),
                Categories(store: categoriesStore),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
