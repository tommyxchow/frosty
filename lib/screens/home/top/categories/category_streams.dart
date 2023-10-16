import 'package:flutter/material.dart';
import 'package:frosty/screens/home/stream_list/stream_list_store.dart';
import 'package:frosty/screens/home/stream_list/streams_list.dart';
import 'package:frosty/widgets/app_bar.dart';

/// A widget that displays a list of streams under the provided [categoryId].
class CategoryStreams extends StatelessWidget {
  /// The category id, used for fetching the relevant streams in the [ListStore].
  final String categoryId;

  const CategoryStreams({
    Key? key,
    required this.categoryId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const FrostyAppBar(
        title: SizedBox(),
      ),
      body: StreamsList(
        listType: ListType.category,
        categoryId: categoryId,
        showJumpButton: true,
      ),
    );
  }
}
