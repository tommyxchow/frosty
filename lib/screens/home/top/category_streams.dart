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

class CategoryStreams extends StatelessWidget {
  final ListStore listStore;

  const CategoryStreams({Key? key, required this.listStore}) : super(key: key);

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
          await listStore.refreshStreams();

          if (listStore.error != null) {
            final snackBar = SnackBar(
              content: Text(listStore.error!),
              behavior: SnackBarBehavior.floating,
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          }
        },
        child: Observer(
          builder: (context) {
            if (listStore.streams.isEmpty && listStore.isLoading && listStore.error == null) {
              return const LoadingIndicator(subtitle: Text('Loading streams...'));
            }
            return Stack(
              alignment: AlignmentDirectional.bottomCenter,
              children: [
                CustomScrollView(
                  physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                  controller: listStore.scrollController,
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
                          listStore.categoryInfo!.name,
                          style: Theme.of(context).textTheme.headline6?.copyWith(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        background: CachedNetworkImage(
                          imageUrl: listStore.categoryInfo!.boxArtUrl.replaceRange(
                            listStore.categoryInfo!.boxArtUrl.lastIndexOf('-') + 1,
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
                            if (index > listStore.streams.length / 2 && listStore.hasMore) {
                              listStore.getStreams();
                            }
                            return Observer(
                              builder: (context) => StreamCard(
                                listStore: listStore,
                                streamInfo: listStore.streams[index],
                                width: thumbnailWidth,
                                height: thumbnailHeight,
                                showUptime: context.read<SettingsStore>().showThumbnailUptime,
                              ),
                            );
                          },
                          childCount: listStore.streams.length,
                        ),
                      ),
                    ),
                  ],
                ),
                SafeArea(
                  child: Observer(
                    builder: (context) => AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: listStore.showJumpButton ? ScrollToTopButton(scrollController: listStore.scrollController) : null,
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
