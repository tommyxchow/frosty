import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:frosty/api/twitch_api.dart';
import 'package:frosty/core/auth/auth_store.dart';
import 'package:frosty/models/category.dart';
import 'package:frosty/screens/home/stores/list_store.dart';
import 'package:frosty/screens/home/top/category_streams.dart';
import 'package:frosty/widgets/loading_indicator.dart';
import 'package:provider/provider.dart';

/// A tappable card widget that displays a category's box art and name.
class CategoryCard extends StatelessWidget {
  final CategoryTwitch category;
  final int width;
  final int height;

  const CategoryCard({
    Key? key,
    required this.category,
    required this.width,
    required this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CategoryStreams(
            store: ListStore(
              twitchApi: context.read<TwitchApi>(),
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
                imageUrl: category.boxArtUrl.replaceRange(category.boxArtUrl.lastIndexOf('-') + 1, null, '${width}x$height.jpg'),
                placeholder: (context, url) => const LoadingIndicator(),
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
