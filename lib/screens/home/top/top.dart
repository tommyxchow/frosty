import 'package:flutter/material.dart';
import 'package:frosty/screens/home/home_store.dart';
import 'package:frosty/screens/home/stream_list/stream_list_store.dart';
import 'package:frosty/screens/home/stream_list/streams_list.dart';
import 'package:frosty/screens/home/top/categories/categories.dart';

class TopSection extends StatefulWidget {
  final HomeStore homeStore;

  const TopSection({
    super.key,
    required this.homeStore,
  });

  @override
  State<TopSection> createState() => _TopSectionState();
}

class _TopSectionState extends State<TopSection>
    with SingleTickerProviderStateMixin {
  late final _tabBarController = TabController(length: 2, vsync: this);

  @override
  void initState() {
    super.initState();
    _tabBarController.addListener(
      () => widget.homeStore.topSectionCurrentIndex = _tabBarController.index,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TabBar(
          isScrollable: true,
          controller: _tabBarController,
          tabs: const [
            Tab(
              child: Text('Streams'),
            ),
            Tab(child: Text('Categories')),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabBarController,
            children: [
              StreamsList(
                listType: ListType.top,
                scrollController:
                    widget.homeStore.topSectionScrollControllers[0],
              ),
              Categories(
                scrollController:
                    widget.homeStore.topSectionScrollControllers[1],
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _tabBarController.dispose();
    super.dispose();
  }
}
