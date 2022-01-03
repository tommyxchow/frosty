import 'package:flutter/material.dart';
import 'package:frosty/models/category.dart';
import 'package:frosty/screens/categories/category_card.dart';

class SearchResultsCategories extends StatelessWidget {
  final List<CategoryTwitch> categories;

  const SearchResultsCategories({Key? key, required this.categories}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverGrid.count(
      crossAxisCount: 2,
      mainAxisSpacing: 20,
      children: categories.map((category) => GridTile(child: CategoryCard(category: category))).toList(),
    );
  }
}
