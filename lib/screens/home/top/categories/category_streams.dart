import 'package:flutter/material.dart';
import 'package:frosty/screens/home/stream_list/stream_list_store.dart';
import 'package:frosty/screens/home/stream_list/streams_list.dart';

/// A widget that displays a list of streams under the provided [categoryId].
class CategoryStreams extends StatelessWidget {
  /// The category id, used for fetching the relevant streams in the [ListStore].
  final String categoryId;

  const CategoryStreams({
    super.key,
    required this.categoryId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Back',
          icon: Icon(Icons.adaptive.arrow_back_rounded),
          onPressed: Navigator.of(context).pop,
        ),
        shape: const Border(),
      ),
      body: StreamsList(
        listType: ListType.category,
        categoryId: categoryId,
        showJumpButton: true,
      ),
    );
  }
}
