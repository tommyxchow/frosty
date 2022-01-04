import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/screens/home/stores/list_store.dart';
import 'package:frosty/screens/home/top/categories/category_card.dart';

class Categories extends StatelessWidget {
  final ListStore store;

  const Categories({
    Key? key,
    required this.store,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: store.refresh,
      child: Observer(
        builder: (_) {
          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
            ),
            itemCount: store.categories.length,
            itemBuilder: (context, index) {
              if (index > store.categories.length / 2 && store.hasMore) {
                store.getGames();
              }
              return CategoryCard(category: store.categories[index]);
            },
          );
        },
      ),
    );
  }
}
