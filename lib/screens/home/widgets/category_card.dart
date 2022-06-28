import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:frosty/api/twitch_api.dart';
import 'package:frosty/core/auth/auth_store.dart';
import 'package:frosty/models/category.dart';
import 'package:frosty/screens/home/stores/list_store.dart';
import 'package:frosty/screens/home/top/category_streams.dart';
import 'package:frosty/widgets/animate_scale.dart';
import 'package:frosty/widgets/loading_indicator.dart';
import 'package:provider/provider.dart';

/// A tappable card widget that displays a category's box art and name.
class CategoryCard extends StatelessWidget {
  final CategoryTwitch category;

  const CategoryCard({
    Key? key,
    required this.category,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final pixelRatio = MediaQuery.of(context).devicePixelRatio;

    final artWidth = (size.width * pixelRatio) ~/ 3;
    final artHeight = (artWidth * (4 / 3)).toInt();

    return AnimateScale(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CategoryStreams(
            listStore: ListStore(
              twitchApi: context.read<TwitchApi>(),
              authStore: context.read<AuthStore>(),
              listType: ListType.category,
              categoryInfo: widget.category,
            ),
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                child: AspectRatio(
                  aspectRatio: 3 / 4,
                  child: CachedNetworkImage(
                    imageUrl: category.boxArtUrl.replaceRange(category.boxArtUrl.lastIndexOf('-') + 1, null, '${artWidth}x$artHeight.jpg'),
                    placeholder: (context, url) => const LoadingIndicator(),
                  ),
                ),
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
