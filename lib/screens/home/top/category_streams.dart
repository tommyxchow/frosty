import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/api/twitch_api.dart';
import 'package:frosty/core/auth/auth_store.dart';
import 'package:frosty/models/category.dart';
import 'package:frosty/screens/home/stores/list_store.dart';
import 'package:frosty/screens/home/widgets/stream_card.dart';
import 'package:frosty/screens/settings/stores/settings_store.dart';
import 'package:frosty/widgets/loading_indicator.dart';
import 'package:frosty/widgets/scroll_to_top_button.dart';
import 'package:provider/provider.dart';

/// A widget that displays a list of streams depending on the provided [listType].
/// This differs from the normal [StreamsList] in that it uses Slivers to display the box art on top.
class CategoryStreams extends StatefulWidget {
  final ListStore listStore;
  final String categoryName;

  const CategoryStreams({
    Key? key,
    required this.listStore,
    required this.categoryName,
  }) : super(key: key);

  @override
  State<CategoryStreams> createState() => _CategoryStreamsState();
}

class _CategoryStreamsState extends State<CategoryStreams> {
  @override
  Widget build(BuildContext context) {
    // Calculate the dimmensions of the box art based on the screen width.
    final size = MediaQuery.of(context).size;
    final pixelRatio = MediaQuery.of(context).devicePixelRatio;
    final artWidth = (size.width * pixelRatio).toInt();
    final artHeight = (artWidth * (4 / 3)).toInt();

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          HapticFeedback.lightImpact();
          await widget.listStore.refreshStreams();

          if (widget.listStore.error != null) {
            final snackBar = SnackBar(
              content: Text(widget.listStore.error!),
              behavior: SnackBarBehavior.floating,
            );

            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          }
        },
        child: Observer(
          builder: (context) {
            if (widget.listStore.streams.isEmpty && widget.listStore.isLoading && widget.listStore.error == null) {
              return const LoadingIndicator(subtitle: Text('Loading streams...'));
            }
            return Stack(
              alignment: AlignmentDirectional.bottomCenter,
              children: [
                CustomScrollView(
                  physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                  controller: widget.listStore.scrollController,
                  slivers: [
                    SliverAppBar(
                      stretch: true,
                      pinned: true,
                      expandedHeight: MediaQuery.of(context).size.height / 3,
                      flexibleSpace: FlexibleSpaceBar(
                        stretchModes: const [
                          StretchMode.fadeTitle,
                          StretchMode.zoomBackground,
                        ],
                        centerTitle: true,
                        title: Text(
                          widget.categoryName,
                          style: Theme.of(context).textTheme.headline6?.copyWith(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        background: FutureBuilder(
                          future: context.read<TwitchApi>().getCategory(
                                headers: context.read<AuthStore>().headersTwitch,
                                gameId: widget.listStore.categoryId!,
                              ),
                          builder: (context, AsyncSnapshot<CategoriesTwitch> snapshot) {
                            return snapshot.hasData
                                ? CachedNetworkImage(
                                    imageUrl: snapshot.data!.data.first.boxArtUrl.replaceRange(
                                      snapshot.data!.data.first.boxArtUrl.lastIndexOf('-') + 1,
                                      null,
                                      '${artWidth}x$artHeight.jpg',
                                    ),
                                    placeholder: (context, url) => const LoadingIndicator(),
                                    color: const Color.fromRGBO(255, 255, 255, 0.5),
                                    colorBlendMode: BlendMode.modulate,
                                    fit: BoxFit.cover,
                                  )
                                : const SizedBox();
                          },
                        ),
                      ),
                    ),
                    SliverSafeArea(
                      top: false,
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            if (index > widget.listStore.streams.length / 2 && widget.listStore.hasMore) {
                              widget.listStore.getStreams();
                            }
                            return Observer(
                              builder: (context) => StreamCard(
                                listStore: widget.listStore,
                                streamInfo: widget.listStore.streams[index],
                                showUptime: context.read<SettingsStore>().showThumbnailUptime,
                                showThumbnail: context.read<SettingsStore>().showThumbnails,
                                large: context.read<SettingsStore>().largeStreamCard,
                                showCategory: false,
                              ),
                            );
                          },
                          childCount: widget.listStore.streams.length,
                        ),
                      ),
                    ),
                  ],
                ),
                SafeArea(
                  child: Observer(
                    builder: (context) => AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: widget.listStore.showJumpButton ? ScrollToTopButton(scrollController: widget.listStore.scrollController) : null,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
