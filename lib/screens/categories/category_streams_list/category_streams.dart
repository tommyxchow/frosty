import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/screens/categories/category_streams_list/category_streams_store.dart';
import 'package:frosty/screens/stream_list/stream_card.dart';

class CategoryStreams extends StatelessWidget {
  final CategoryStreamsStore store;

  const CategoryStreams({Key? key, required this.store}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: store.refresh,
        child: Observer(
          builder: (_) {
            return CustomScrollView(
              physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
              slivers: [
                SliverAppBar(
                  stretch: true,
                  pinned: true,
                  expandedHeight: MediaQuery.of(context).size.height / 3,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(
                      store.categoryInfo.name,
                      style: Theme.of(context).textTheme.headline6?.copyWith(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    background: Hero(
                      tag: store.categoryInfo.id,
                      child: CachedNetworkImage(
                        imageUrl: store.categoryInfo.boxArtUrl.replaceFirst('-{width}x{height}', '-300x400'),
                        color: const Color.fromRGBO(255, 255, 255, 0.5),
                        colorBlendMode: BlendMode.modulate,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index > store.streams.length / 2 && store.hasMore) {
                        store.getStreams();
                      }
                      return StreamCard(streamInfo: store.streams[index]);
                    },
                    childCount: store.streams.length,
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
