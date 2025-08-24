import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/models/category.dart';
import 'package:frosty/screens/home/search/search_store.dart';
import 'package:frosty/screens/home/top/categories/category_card.dart';
import 'package:frosty/widgets/alert_message.dart';
import 'package:frosty/widgets/skeleton_loader.dart';
import 'package:mobx/mobx.dart';

class SearchResultsCategories extends StatelessWidget {
  final SearchStore searchStore;

  const SearchResultsCategories({super.key, required this.searchStore});

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) {
        final future = searchStore.categoryFuture;

        if (future == null) {
          return const SliverToBoxAdapter(
            child: SizedBox.shrink(),
          );
        }

        switch (future.status) {
          case FutureStatus.pending:
            return SliverList.builder(
              itemCount: 4,
              itemBuilder: (context, index) => const CategorySkeletonLoader(),
            );
          case FutureStatus.rejected:
            return const SliverToBoxAdapter(
              child: SizedBox(
                height: 100.0,
                child: AlertMessage(
                  message: 'Unable to load categories',
                  vertical: true,
                ),
              ),
            );
          case FutureStatus.fulfilled:
            final CategoriesTwitch? categories = future.result;

            if (categories == null) {
              return const SliverToBoxAdapter(
                child: SizedBox(
                  height: 100.0,
                  child: AlertMessage(
                    message: 'Failed to get categories',
                    vertical: true,
                  ),
                ),
              );
            }

            if (categories.data.isEmpty) {
              return const SliverToBoxAdapter(
                child: SizedBox(
                  height: 100.0,
                  child: AlertMessage(
                    message: 'No matching categories',
                    vertical: true,
                  ),
                ),
              );
            }

            return SliverList.builder(
              itemCount: categories.data.length,
              itemBuilder: (context, index) => CategoryCard(
                category: categories.data[index],
              ),
            );
        }
      },
    );
  }
}
