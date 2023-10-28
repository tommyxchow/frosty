import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/models/category.dart';
import 'package:frosty/screens/home/search/search_store.dart';
import 'package:frosty/screens/home/top/categories/category_card.dart';
import 'package:frosty/widgets/alert_message.dart';
import 'package:frosty/widgets/loading_indicator.dart';
import 'package:mobx/mobx.dart';

class SearchResultsCategories extends StatelessWidget {
  final SearchStore searchStore;

  const SearchResultsCategories({super.key, required this.searchStore});

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) {
        final future = searchStore.categoryFuture;

        switch (future!.status) {
          case FutureStatus.pending:
            return const SliverToBoxAdapter(
              child: SizedBox(
                height: 100.0,
                child: LoadingIndicator(
                  subtitle: 'Loading categories...',
                ),
              ),
            );
          case FutureStatus.rejected:
            return const SliverToBoxAdapter(
              child: SizedBox(
                height: 100.0,
                child: AlertMessage(message: 'Failed to get categories'),
              ),
            );
          case FutureStatus.fulfilled:
            final CategoriesTwitch? categories = future.result;

            if (categories == null) {
              return const SliverToBoxAdapter(
                child: SizedBox(
                  height: 100.0,
                  child: AlertMessage(message: 'Failed to get categories'),
                ),
              );
            }

            if (categories.data.isEmpty) {
              return const SliverToBoxAdapter(
                child: SizedBox(
                  height: 100.0,
                  child: AlertMessage(message: 'No matching categories'),
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
