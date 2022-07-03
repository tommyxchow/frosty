import 'package:flutter/material.dart';
import 'package:frosty/screens/home/stores/home_store.dart';
import 'package:frosty/screens/home/stores/list_store.dart';
import 'package:frosty/screens/home/top/categories.dart';
import 'package:frosty/screens/home/widgets/streams_list.dart';

class TopSection extends StatefulWidget {
  final HomeStore homeStore;

  const TopSection({
    Key? key,
    required this.homeStore,
  }) : super(key: key);

  @override
  State<TopSection> createState() => _TopSectionState();
}

class _TopSectionState extends State<TopSection> with SingleTickerProviderStateMixin {
  late final _tabBarController = TabController(length: 2, vsync: this);

  @override
  void initState() {
    super.initState();
    _tabBarController.addListener(() => widget.homeStore.topSectionCurrentIndex = _tabBarController.index);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _tabBarController,
          indicatorColor: const Color(0xff9146ff),
          tabs: const [
            Tab(
              child: Text(
                'Streams',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            Tab(
              child: Text(
                'Categories',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabBarController,
            children: [
              StreamsList(
                listType: ListType.top,
                scrollController: widget.homeStore.topSectionScrollControllers[0],
              ),
              Categories(
                scrollController: widget.homeStore.topSectionScrollControllers[1],
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
