import 'package:flutter/material.dart';

class FrostyPageView extends StatefulWidget {
  final List<String> headers;
  final List<Widget> children;

  /// Actions keyed by tab index, shown trailing the tab bar
  /// when that tab is selected.
  final Map<int, Widget> tabActions;

  const FrostyPageView({
    super.key,
    required this.headers,
    required this.children,
    this.tabActions = const {},
  }) : assert(headers.length == children.length);

  @override
  State<FrostyPageView> createState() => _FrostyPageViewState();
}

class _FrostyPageViewState extends State<FrostyPageView>
    with TickerProviderStateMixin {
  late TabController _tabController;

  void _handleTabChange() => setState(() {});

  void _initTabController(int length) {
    _tabController = TabController(length: length, vsync: this);
    _tabController.addListener(_handleTabChange);
  }

  @override
  void initState() {
    super.initState();
    _initTabController(widget.headers.length);
  }

  @override
  void didUpdateWidget(FrostyPageView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_tabController.length != widget.headers.length) {
      _tabController.removeListener(_handleTabChange);
      _tabController.dispose();
      _initTabController(widget.headers.length);
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Avoid layout overflow during animated height transitions
        // (e.g., when the emote menu is opening/closing and height is tiny).
        const double minHeight = kTextTabBarHeight + 1;
        if (constraints.maxHeight < minHeight) {
          return const SizedBox.expand();
        }

        final trailingAction = widget.tabActions[_tabController.index];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    labelStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    labelPadding:
                        const EdgeInsets.symmetric(horizontal: 12),
                    tabs: widget.headers
                        .map((header) => Tab(text: header))
                        .toList(),
                  ),
                ),
                ?trailingAction,
              ],
            ),
            const Divider(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: widget.children,
              ),
            ),
          ],
        );
      },
    );
  }
}
