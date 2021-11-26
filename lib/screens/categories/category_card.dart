import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:frosty/core/auth/auth_store.dart';
import 'package:frosty/models/category.dart';
import 'package:frosty/screens/categories/category_streams_list/category_streams.dart';
import 'package:frosty/screens/categories/category_streams_list/category_streams_store.dart';
import 'package:provider/provider.dart';

/// A tappable card widget that displays a category's box art and name.
class CategoryCard extends StatelessWidget {
  final CategoryTwitch category;

  const CategoryCard({Key? key, required this.category}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return CategoryStreams(
                store: CategoryStreamsStore(
                  categoryInfo: category,
                  authStore: context.read<AuthStore>(),
                ),
              );
            },
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
        child: Row(
          children: [
            Flexible(
              flex: 1,
              child: CachedNetworkImage(
                imageUrl: category.boxArtUrl.replaceFirst('-{width}x{height}', '-138x184'),
              ),
            ),
            const SizedBox(width: 10),
            Flexible(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Text('0 Viewers')
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
