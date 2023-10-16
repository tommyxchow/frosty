import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

class FrostyPageView extends StatefulWidget {
  final List<String> headers;
  final List<Widget> children;

  const FrostyPageView({
    Key? key,
    required this.headers,
    required this.children,
  })  : assert(headers.length == children.length),
        super(key: key);

  @override
  State<FrostyPageView> createState() => _FrostyPageViewState();
}

class _FrostyPageViewState extends State<FrostyPageView> {
  var currentIndex = 0;

  late final PageController _pageContoller =
      PageController(initialPage: currentIndex);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ...widget.headers.mapIndexed(
                (index, section) => TextButton(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                    ),
                    foregroundColor: index == currentIndex ? null : Colors.grey,
                  ),
                  onPressed: () => _pageContoller.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                  ),
                  child: Text(
                    section,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: PageView.builder(
            onPageChanged: (index) => setState(() => currentIndex = index),
            controller: _pageContoller,
            itemBuilder: (context, index) => widget.children[index],
            itemCount: widget.children.length,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _pageContoller.dispose();
    super.dispose();
  }
}
