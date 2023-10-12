import 'package:flutter/material.dart';
import 'package:frosty/models/category.dart';
import 'package:frosty/screens/home/top/categories/category_streams.dart';
import 'package:frosty/widgets/cached_image.dart';
import 'package:frosty/widgets/loading_indicator.dart';

/// A tappable card widget that displays a category's box art and name under.
class CategoryCard extends StatelessWidget {
  final CategoryTwitch category;

  const CategoryCard({
    Key? key,
    required this.category,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Calculate the dimmensions of the box art based on the current dimmensions of the screen.
    final size = MediaQuery.of(context).size;
    final pixelRatio = MediaQuery.of(context).devicePixelRatio;
    final artWidth = (size.width * pixelRatio) ~/ 3;
    final artHeight = (artWidth * (4 / 3)).toInt();

    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CategoryStreams(
            categoryName: category.name,
            categoryId: category.id,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
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
            const SizedBox(height: 8),
            Tooltip(
              message: category.name,
              preferBelow: false,
              child: Text(
                category.name,
                style: const TextStyle(fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
