import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/screens/home/stores/categories_store.dart';
import 'package:frosty/screens/home/widgets/category_card.dart';
import 'package:frosty/widgets/loading_indicator.dart';
import 'package:frosty/widgets/scroll_to_top_button.dart';

class Categories extends StatefulWidget {
  final CategoriesStore store;

  const Categories({
    Key? key,
    required this.store,
  }) : super(key: key);

  @override
  _CategoriesState createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    final store = widget.store;

    final size = MediaQuery.of(context).size;
    final pixelRatio = MediaQuery.of(context).devicePixelRatio;

    final artWidth = (size.width * pixelRatio) ~/ 3;
    final artHeight = (artWidth * (4 / 3)).toInt();

    return RefreshIndicator(
      onRefresh: () async {
        HapticFeedback.lightImpact();
        await store.refreshCategories();

        if (store.error != null) {
          final snackBar = SnackBar(
            content: Text(store.error!),
            behavior: SnackBarBehavior.floating,
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      },
      child: Observer(
        builder: (_) {
          if (store.categories.isEmpty && store.isLoading && store.error == null) {
            return const LoadingIndicator(subtitle: Text('Loading categories...'));
          }
          return Stack(
            alignment: AlignmentDirectional.bottomCenter,
            children: [
              GridView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                controller: store.scrollController,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                ),
                itemCount: store.categories.length,
                itemBuilder: (context, index) {
                  if (index > store.categories.length / 2 && store.hasMore) {
                    store.getCategories();
                  }
                  return CategoryCard(
                    category: store.categories[index],
                    width: artWidth,
                    height: artHeight,
                  );
                },
              ),
              Observer(
                builder: (context) => AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: store.showJumpButton ? ScrollToTopButton(scrollController: store.scrollController) : null,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    widget.store.dispose();
    super.dispose();
  }
}
