import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/screens/home/stores/list_store.dart';
import 'package:frosty/screens/settings/stores/settings_store.dart';
import 'package:frosty/widgets/scroll_to_top_button.dart';
import 'package:frosty/widgets/stream_card.dart';
import 'package:provider/provider.dart';

class CategoryStreams extends StatelessWidget {
  final ListStore store;

  const CategoryStreams({Key? key, required this.store}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          HapticFeedback.lightImpact();
          await store.refreshStreams();
        },
        child: Observer(
          builder: (context) {
            return Stack(
              alignment: AlignmentDirectional.bottomCenter,
              children: [
                CustomScrollView(
                  physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                  controller: store.scrollController,
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
                          store.categoryInfo!.name,
                          style: Theme.of(context).textTheme.headline6?.copyWith(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        background: CachedNetworkImage(
                          imageUrl: store.categoryInfo!.boxArtUrl.replaceRange(
                            store.categoryInfo!.boxArtUrl.lastIndexOf('-') + 1,
                            null,
                            '300x400.jpg',
                          ),
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
                            if (index > store.streams.length / 2 && store.hasMore) {
                              store.getStreams();
                            }
                            return Observer(
                              builder: (context) => StreamCard(
                                streamInfo: store.streams[index],
                                showUptime: context.read<SettingsStore>().showThumbnailUptime,
                              ),
                            );
                          },
                          childCount: store.streams.length,
                        ),
                      ),
                    ),
                  ],
                ),
                SafeArea(
                  child: Observer(
                    builder: (context) => AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: store.showJumpButton ? ScrollToTopButton(scrollController: store.scrollController) : const SizedBox(),
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
