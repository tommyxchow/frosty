import 'package:flutter/material.dart';
import 'package:frosty/models/category.dart';
import 'package:frosty/screens/home/top/categories/category_streams.dart';
import 'package:frosty/widgets/cached_image.dart';
import 'package:frosty/widgets/loading_indicator.dart';

/// A tappable card widget that displays a category's box art and name under.
class CategoryCard extends StatelessWidget {
  final CategoryTwitch category;
  final bool isTappable;

  const CategoryCard({
    Key? key,
    required this.category,
    this.isTappable = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Calculate the dimmensions of the box art based on the current dimmensions of the screen.
    final size = MediaQuery.of(context).size;
    final pixelRatio = MediaQuery.of(context).devicePixelRatio;
    final artWidth = (size.width * pixelRatio) ~/ 5;
    final artHeight = (artWidth * (4 / 3)).toInt();

    return InkWell(
      onTap: isTappable
          ? () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CategoryStreams(
                    categoryId: category.id,
                  ),
                ),
              )
          : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            SizedBox(
              width: 80,
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                child: AspectRatio(
                  aspectRatio: 3 / 4,
                  child: FrostyCachedNetworkImage(
                    imageUrl: category.boxArtUrl.replaceRange(
                      category.boxArtUrl.lastIndexOf('-') + 1,
                      null,
                      '${artWidth}x$artHeight.jpg',
                    ),
                    placeholder: (context, url) => ColoredBox(
                      color: Colors.grey.shade900,
                      child: const LoadingIndicator(),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Tooltip(
              message: category.name,
              preferBelow: false,
              child: Text(
                category.name,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
