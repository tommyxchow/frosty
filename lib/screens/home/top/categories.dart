import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/screens/home/stores/categories_store.dart';
import 'package:frosty/screens/home/widgets/category_card.dart';
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

    return RefreshIndicator(
      onRefresh: () async {
        HapticFeedback.lightImpact();
        await store.refreshCategories();
      },
      child: Observer(
        builder: (_) {
          return Stack(
            alignment: AlignmentDirectional.bottomCenter,
            children: [
              GridView.builder(
                controller: store.scrollController,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                ),
                itemCount: store.categories.length,
                itemBuilder: (context, index) {
                  if (index > store.categories.length / 2 && store.hasMore) {
                    store.getCategories();
                  }
                  return CategoryCard(category: store.categories[index]);
                },
              ),
              Observer(
                builder: (context) => AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: store.showJumpButton ? ScrollToTopButton(scrollController: store.scrollController) : const SizedBox(),
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
