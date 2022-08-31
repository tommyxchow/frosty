import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/apis/twitch_api.dart';
import 'package:frosty/screens/home/top/categories/categories_store.dart';
import 'package:frosty/screens/home/top/categories/category_card.dart';
import 'package:frosty/screens/settings/stores/auth_store.dart';
import 'package:frosty/widgets/alert_message.dart';
import 'package:frosty/widgets/loading_indicator.dart';
import 'package:provider/provider.dart';

class Categories extends StatefulWidget {
  final ScrollController scrollController;

  const Categories({
    Key? key,
    required this.scrollController,
  }) : super(key: key);

  @override
  State<Categories> createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories> with AutomaticKeepAliveClientMixin {
  late final _categoriesStore = CategoriesStore(
    authStore: context.read<AuthStore>(),
    twitchApi: context.read<TwitchApi>(),
  );

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return RefreshIndicator(
      onRefresh: () async {
        HapticFeedback.lightImpact();
        await _categoriesStore.refreshCategories();

        if (_categoriesStore.error != null) {
          final snackBar = SnackBar(
            content: AlertMessage(
              message: _categoriesStore.error!,
              icon: Icons.error,
            ),
            behavior: SnackBarBehavior.floating,
          );

          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      },
      child: Observer(
        builder: (_) {
          Widget? statusWidget;

          if (_categoriesStore.error != null) {
            statusWidget = AlertMessage(
              message: _categoriesStore.error!,
              icon: Icons.error,
            );
          }

          if (_categoriesStore.categories.isEmpty) {
            if (_categoriesStore.isLoading && _categoriesStore.error == null) {
              statusWidget = const LoadingIndicator(subtitle: 'Loading categories...');
            } else {
              statusWidget = const AlertMessage(message: 'No top categories');
            }
          }

          if (statusWidget != null) {
            return CustomScrollView(
              slivers: [
                SliverFillRemaining(
                  child: Center(
                    child: statusWidget,
                  ),
                )
              ],
            );
          }

          return GridView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            controller: widget.scrollController,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
            ),
            itemCount: _categoriesStore.categories.length,
            itemBuilder: (context, index) {
              if (index > _categoriesStore.categories.length - 10 && _categoriesStore.hasMore) {
                _categoriesStore.getCategories();
              }
              return CategoryCard(
                category: _categoriesStore.categories[index],
              );
            },
          );
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
