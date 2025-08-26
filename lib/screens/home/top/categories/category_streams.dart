import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/apis/twitch_api.dart';
import 'package:frosty/screens/home/stream_list/stream_list_store.dart';
import 'package:frosty/screens/home/stream_list/streams_list.dart';
import 'package:frosty/screens/settings/stores/auth_store.dart';
import 'package:frosty/screens/settings/stores/settings_store.dart';
import 'package:frosty/widgets/blurred_container.dart';
import 'package:frosty/widgets/cached_image.dart';
import 'package:frosty/widgets/skeleton_loader.dart';
import 'package:provider/provider.dart';

/// A widget that displays a list of streams under the provided [categoryId].
class CategoryStreams extends StatefulWidget {
  /// The category id, used for fetching the relevant streams in the [ListStore].
  final String categoryId;

  const CategoryStreams({
    super.key,
    required this.categoryId,
  });

  @override
  State<CategoryStreams> createState() => _CategoryStreamsState();
}

class _CategoryStreamsState extends State<CategoryStreams> {
  late final _listStore = ListStore(
    listType: ListType.category,
    categoryId: widget.categoryId,
    authStore: context.read<AuthStore>(),
    twitchApi: context.read<TwitchApi>(),
    settingsStore: context.read<SettingsStore>(),
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Stream list content behind the pinned elements
          Positioned.fill(
            child: StreamsList(
              listType: ListType.category,
              categoryId: widget.categoryId,
              showJumpButton: true,
            ),
          ),
          // Single blurred background spanning app bar and category card
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: BlurredContainer(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top,
                left: MediaQuery.of(context).padding.left,
                right: MediaQuery.of(context).padding.right,
              ),
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: theme.colorScheme.outlineVariant
                          .withValues(alpha: 0.3),
                      width: 0.5,
                    ),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // App bar section
                    SizedBox(
                      height: kToolbarHeight,
                      child: Row(
                        children: [
                          IconButton(
                            tooltip: 'Back',
                            icon: Icon(Icons.adaptive.arrow_back_rounded),
                            onPressed: Navigator.of(context).pop,
                          ),
                        ],
                      ),
                    ),
                    // Category card section
                    Observer(
                      builder: (_) {
                        if (_listStore.categoryDetails != null) {
                          return _TransparentCategoryCard(
                            category: _listStore.categoryDetails!,
                          );
                        } else {
                          // Skeleton loader for category card
                          return Padding(
                            padding: const EdgeInsets.only(
                              bottom: 16,
                              left: 16,
                              right: 16,
                            ),
                            child: Row(
                              children: [
                                const SizedBox(
                                  width: 80,
                                  child: AspectRatio(
                                    aspectRatio: 3 / 4,
                                    child: SkeletonLoader(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(8),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SkeletonLoader(
                                        height: 20,
                                        width: double.infinity,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      const SizedBox(height: 8),
                                      SkeletonLoader(
                                        height: 16,
                                        width: 120,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _listStore.dispose();
    super.dispose();
  }
}

/// A transparent version of CategoryCard for use in blurred overlays
class _TransparentCategoryCard extends StatelessWidget {
  final dynamic category;

  const _TransparentCategoryCard({
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate the dimensions of the box art based on the current dimensions of the screen.
    final size = MediaQuery.of(context).size;
    final pixelRatio = MediaQuery.of(context).devicePixelRatio;
    final artWidth = (size.width * pixelRatio) ~/ 5;
    final artHeight = (artWidth * (4 / 3)).toInt();

    return Padding(
      padding: const EdgeInsets.only(
        bottom: 16,
        left: 16,
        right: 16,
      ),
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
                  placeholder: (context, url) => const SkeletonLoader(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.name,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
