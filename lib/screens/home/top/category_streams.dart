import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/screens/home/stores/list_store.dart';
import 'package:frosty/screens/home/widgets/stream_card.dart';
import 'package:frosty/screens/settings/stores/settings_store.dart';
import 'package:frosty/widgets/loading_indicator.dart';
import 'package:frosty/widgets/scroll_to_top_button.dart';
import 'package:provider/provider.dart';

class CategoryStreams extends StatefulWidget {
  final ListStore listStore;

  const CategoryStreams({Key? key, required this.listStore}) : super(key: key);

  @override
  State<CategoryStreams> createState() => _CategoryStreamsState();
}

class _CategoryStreamsState extends State<CategoryStreams> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final pixelRatio = MediaQuery.of(context).devicePixelRatio;

    final artWidth = (size.width * pixelRatio).toInt();
    final artHeight = (artWidth * (4 / 3)).toInt();

    final thumbnailWidth = (size.width * pixelRatio) ~/ 3;
    final thumbnailHeight = (thumbnailWidth * (9 / 16)).toInt();

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
                          widget.listStore.categoryInfo!.name,
                          style: Theme.of(context).textTheme.headline6?.copyWith(fontWeight: FontWeight.w800),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        background: CachedNetworkImage(
                          imageUrl: widget.listStore.categoryInfo!.boxArtUrl.replaceRange(
                            widget.listStore.categoryInfo!.boxArtUrl.lastIndexOf('-') + 1,
                            null,
                            '${artWidth}x$artHeight.jpg',
                          ),
                          placeholder: (context, url) => const LoadingIndicator(),
                          color: const Color.fromRGBO(255, 255, 255, 0.5),
                          colorBlendMode: BlendMode.modulate,
                          fit: BoxFit.cover,
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
                                width: thumbnailWidth,
                                height: thumbnailHeight,
                                showUptime: context.read<SettingsStore>().showThumbnailUptime,
                                showThumbnail: context.read<SettingsStore>().showThumbnails,
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
