import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:frosty/widgets/button.dart';

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

  late final PageController _pageContoller = PageController(initialPage: currentIndex);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(
          height: 5.0,
          thickness: 1.0,
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ...widget.headers.mapIndexed(
                (index, section) => SizedBox(
                  height: 40,
                  child: Button(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                    onPressed: () => _pageContoller.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                    ),
                    color: index == currentIndex ? Theme.of(context).colorScheme.secondary : Colors.grey,
                    child: Text(
                      section,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
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
