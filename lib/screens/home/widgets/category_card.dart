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
class CategoryCard extends StatefulWidget {
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
  State<CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<CategoryCard> with SingleTickerProviderStateMixin {
  late final _animationController = AnimationController(
    vsync: this,
    upperBound: 0.05,
  );

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      child: InkWell(
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
        onTapDown: (_) => _animationController.animateTo(
          _animationController.upperBound,
          curve: Curves.easeOutBack,
          duration: const Duration(milliseconds: 200),
        ),
        onTapUp: (_) => _animationController.animateTo(
          _animationController.lowerBound,
          curve: Curves.easeOutBack,
          duration: const Duration(milliseconds: 300),
        ),
        onTapCancel: () => _animationController.animateTo(
          _animationController.lowerBound,
          curve: Curves.easeOutBack,
          duration: const Duration(milliseconds: 300),
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
                      imageUrl: widget.category.boxArtUrl
                          .replaceRange(widget.category.boxArtUrl.lastIndexOf('-') + 1, null, '${widget.width}x${widget.height}.jpg'),
                      placeholder: (context, url) => const LoadingIndicator(),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 5.0),
              Tooltip(
                message: widget.category.name,
                preferBelow: false,
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  widget.category.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
      builder: (context, child) => Transform.scale(
        scale: 1 - _animationController.value,
        child: child,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
