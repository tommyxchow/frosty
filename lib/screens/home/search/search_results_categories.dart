import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/models/category.dart';
import 'package:frosty/screens/home/stores/search_store.dart';
import 'package:frosty/screens/home/widgets/category_card.dart';
import 'package:frosty/widgets/loading_indicator.dart';
import 'package:mobx/mobx.dart';

class SearchResultsCategories extends StatelessWidget {
  final SearchStore searchStore;

  const SearchResultsCategories({Key? key, required this.searchStore}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final pixelRatio = MediaQuery.of(context).devicePixelRatio;

    final artWidth = (size.width * pixelRatio) ~/ 3;
    final artHeight = (artWidth * (4 / 3)).toInt();

    return Observer(
      builder: (context) {
        final future = searchStore.categoryFuture;

        switch (future!.status) {
          case FutureStatus.pending:
            return const SliverToBoxAdapter(
              child: LoadingIndicator(
                subtitle: Text('Loading categories...'),
              ),
            );
          case FutureStatus.rejected:
            return const SliverToBoxAdapter(
              child: Center(
                child: Text('Failed to get categories'),
              ),
            );
          case FutureStatus.fulfilled:
            final CategoriesTwitch? categories = future.result;

            if (categories == null) {
              return const SliverToBoxAdapter(
                child: Center(
                  child: Text('Failed to get categories'),
                ),
              );
            }

            if (categories.data.isEmpty) {
              return const SliverToBoxAdapter(
                child: SizedBox(
                  height: 100.0,
                  child: Center(child: Text('No matching categories')),
                ),
              );
            }

            return SliverGrid.count(
              crossAxisCount: 2,
              mainAxisSpacing: 20,
              children: categories.data
                  .map(
                    (category) => GridTile(
                      child: CategoryCard(
                        category: category,
                        width: artWidth,
                        height: artHeight,
                      ),
                    ),
                  )
                  .toList(),
            );
        }
      },
    );
  }
}
