import 'package:flutter/material.dart';
import 'package:frosty/screens/home/stores/list_store.dart';
import 'package:frosty/screens/home/top/categories.dart';
import 'package:frosty/screens/home/widgets/streams_list.dart';

class TopSection extends StatelessWidget {
  const TopSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: const [
          TabBar(
            indicatorColor: Color(0xff9146ff),
            tabs: [
              Tab(
                child: Text(
                  'Streams',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Tab(
                child: Text(
                  'Categories',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                StreamsList(listType: ListType.top),
                Categories(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
