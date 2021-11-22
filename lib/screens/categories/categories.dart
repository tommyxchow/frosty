import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/core/auth/auth_store.dart';
import 'package:frosty/screens/categories/categories_store.dart';
import 'package:frosty/screens/categories/category_card.dart';
import 'package:provider/provider.dart';

class Categories extends StatelessWidget {
  const Categories({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final categoriesStore = CategoriesStore(authStore: context.read<AuthStore>());
    return Observer(
      builder: (_) {
        return ListView.builder(
          itemCount: categoriesStore.categories.length,
          itemBuilder: (context, index) {
            if (index > categoriesStore.categories.length / 2 && categoriesStore.hasMore) {
              categoriesStore.getGames();
            }
            return CategoryCard(category: categoriesStore.categories[index]);
          },
        );
      },
    );
  }
}
