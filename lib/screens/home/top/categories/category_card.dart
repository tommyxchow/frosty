import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:frosty/core/auth/auth_store.dart';
import 'package:frosty/models/category.dart';
import 'package:frosty/screens/home/stores/list_store.dart';
import 'package:frosty/screens/home/top/categories/category_streams.dart';
import 'package:provider/provider.dart';

/// A tappable card widget that displays a category's box art and name.
class CategoryCard extends StatelessWidget {
  final CategoryTwitch category;

  const CategoryCard({Key? key, required this.category}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CategoryStreams(
            store: ListStore(
              authStore: context.read<AuthStore>(),
              listType: ListType.category,
              categoryInfo: category,
            ),
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
        child: Column(
          children: [
            Expanded(
              child: CachedNetworkImage(
                imageUrl: category.boxArtUrl.replaceRange(category.boxArtUrl.lastIndexOf('-') + 1, null, '300x400.jpg'),
              ),
            ),
            const SizedBox(height: 5.0),
            Tooltip(
              message: category.name,
              preferBelow: false,
              padding: const EdgeInsets.all(10.0),
              child: Text(
                category.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
