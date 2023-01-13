import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/apis/twitch_api.dart';
import 'package:frosty/main.dart';
import 'package:frosty/models/category.dart';
import 'package:frosty/screens/home/stream_list/large_stream_card.dart';
import 'package:frosty/screens/home/stream_list/stream_card.dart';
import 'package:frosty/screens/home/stream_list/stream_list_store.dart';
import 'package:frosty/screens/settings/stores/auth_store.dart';
import 'package:frosty/screens/settings/stores/settings_store.dart';
import 'package:frosty/widgets/alert_message.dart';
import 'package:frosty/widgets/cached_image.dart';
import 'package:frosty/widgets/loading_indicator.dart';
import 'package:frosty/widgets/scroll_to_top_button.dart';
import 'package:heroicons/heroicons.dart';
import 'package:provider/provider.dart';

/// A widget that displays a list of streams under the provided [categoryId].
/// This differs from the normal [StreamsList] in that it uses slivers to display the box art on top.
class CategoryStreams extends StatefulWidget {
  /// The category name, used for the header on the box art sliver.
  final String categoryName;

  /// The category id, used for fetching the relevant streams in the [ListStore].
  final String categoryId;

  const CategoryStreams({
    Key? key,
    required this.categoryName,
    required this.categoryId,
  }) : super(key: key);

  @override
  State<CategoryStreams> createState() => _CategoryStreamsState();
}

class _CategoryStreamsState extends State<CategoryStreams> {
  late final _listStore = ListStore(
    authStore: context.read<AuthStore>(),
    twitchApi: context.read<TwitchApi>(),
    listType: ListType.category,
    categoryId: widget.categoryId,
    scrollController: ScrollController(),
  );

  @override
  Widget build(BuildContext context) {
    // Calculate the dimensions of the box art based on the screen width.
    final size = MediaQuery.of(context).size;
    final pixelRatio = MediaQuery.of(context).devicePixelRatio;
    final artWidth = (size.width * pixelRatio).toInt();
    final artHeight = (artWidth * (4 / 3)).toInt();

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          HapticFeedback.lightImpact();
          await _listStore.refreshStreams();

          if (_listStore.error != null) {
            final snackBar = SnackBar(
              content: AlertMessage(message: _listStore.error!),
              behavior: SnackBarBehavior.floating,
            );

            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          }
        },
        child: Observer(
          builder: (context) {
            return Stack(
              alignment: AlignmentDirectional.bottomCenter,
              children: [
                CustomScrollView(
                  physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                  controller: _listStore.scrollController,
                  slivers: [
                    SliverAppBar(
                      leading: IconButton(
                        icon: const HeroIcon(
                          HeroIcons.chevronLeft,
                          style: HeroIconStyle.solid,
                        ),
                        onPressed: Navigator.of(context).pop,
                      ),
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
                                gameId: _listStore.categoryId!,
                              ),
                          builder: (context, AsyncSnapshot<CategoriesTwitch> snapshot) {
                            return snapshot.hasData
                                ? FrostyCachedNetworkImage(
                                    imageUrl: snapshot.data!.data.first.boxArtUrl.replaceRange(
                                      snapshot.data!.data.first.boxArtUrl.lastIndexOf('-') + 1,
                                      null,
                                      '${artWidth}x$artHeight.jpg',
                                    ),
                                    placeholder: (context, url) =>
                                        const ColoredBox(color: lightGray, child: LoadingIndicator()),
                                    color: const Color.fromRGBO(255, 255, 255, 0.5),
                                    colorBlendMode: BlendMode.modulate,
                                    fit: BoxFit.cover,
                                  )
                                : const SizedBox();
                          },
                        ),
                      ),
                    ),
                    if (_listStore.error != null)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: AlertMessage(message: _listStore.error!),
                      )
                    else if (_listStore.streams.isEmpty)
                      if (_listStore.isLoading && _listStore.error == null)
                        const SliverFillRemaining(
                          hasScrollBody: false,
                          child: LoadingIndicator(
                            subtitle: 'Loading streams...',
                          ),
                        )
                      else
                        const SliverFillRemaining(
                          hasScrollBody: false,
                          child: AlertMessage(
                            message: 'No streams found',
                          ),
                        )
                    else
                      SliverSafeArea(
                        top: false,
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              if (index > _listStore.streams.length - 10 && _listStore.hasMore) {
                                _listStore.getStreams();
                              }
                              return Observer(
                                builder: (context) => context.read<SettingsStore>().largeStreamCard
                                    ? LargeStreamCard(
                                        streamInfo: _listStore.streams[index],
                                        showThumbnail: context.read<SettingsStore>().showThumbnails,
                                        showCategory: false,
                                      )
                                    : StreamCard(
                                        streamInfo: _listStore.streams[index],
                                        showThumbnail: context.read<SettingsStore>().showThumbnails,
                                        showCategory: false,
                                      ),
                              );
                            },
                            childCount: _listStore.streams.length,
                          ),
                        ),
                      ),
                  ],
                ),
                SafeArea(
                  child: Observer(
                    builder: (context) => AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      child: _listStore.showJumpButton
                          ? ScrollToTopButton(scrollController: _listStore.scrollController!)
                          : null,
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

  @override
  void dispose() {
    _listStore.dispose();
    super.dispose();
  }
}
