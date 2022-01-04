import 'package:flutter/material.dart';
import 'package:frosty/screens/home/stores/list_store.dart';
import 'package:frosty/screens/home/streams_list.dart';
import 'package:frosty/screens/home/top/categories/categories.dart';

class TopSection extends StatelessWidget {
  final ListStore topSectionStore;

  const TopSection({
    Key? key,
    required this.topSectionStore,
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
                StreamsList(store: topSectionStore),
                Categories(store: topSectionStore),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
