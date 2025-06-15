import 'package:flutter/material.dart';

class FrostyPageView extends StatelessWidget {
  final List<String> headers;
  final List<Widget> children;

  const FrostyPageView({
    super.key,
    required this.headers,
    required this.children,
  }) : assert(headers.length == children.length);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: headers.length,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TabBar(
            isScrollable: true,
            labelStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            labelPadding: const EdgeInsets.symmetric(
              horizontal: 12,
            ),
            tabs: headers
                .map(
                  (header) => Tab(
                    text: header,
                  ),
                )
                .toList(),
          ),
          const Divider(),
          Expanded(child: TabBarView(children: children)),
        ],
      ),
    );
  }
}
