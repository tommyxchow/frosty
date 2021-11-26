import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/screens/categories/categories_store.dart';
import 'package:frosty/screens/categories/category_card.dart';

class Categories extends StatelessWidget {
  final CategoriesStore store;

  const Categories({
    Key? key,
    required this.store,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Observer(
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
    );
  }
}
