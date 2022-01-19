import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/screens/home/search/search_results_categories.dart';
import 'package:frosty/screens/home/search/search_results_channels.dart';
import 'package:frosty/screens/home/stores/search_store.dart';
import 'package:frosty/widgets/section_header.dart';

class Search extends StatefulWidget {
  final SearchStore searchStore;

  const Search({Key? key, required this.searchStore}) : super(key: key);

  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  final textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    const headerPadding = EdgeInsets.fromLTRB(15.0, 20.0, 15.0, 10.0);

    final searchStore = widget.searchStore;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
          child: TextField(
            controller: textEditingController,
            autocorrect: false,
            decoration: InputDecoration(
              isDense: true,
              hintText: 'Search for a channel or category',
              contentPadding: const EdgeInsets.all(10.0),
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(15.0)),
              ),
              suffixIcon: IconButton(
                tooltip: 'Clear Search',
                onPressed: () {
                  setState(() {
                    textEditingController.clear();
                  });
                  FocusManager.instance.primaryFocus?.unfocus();
                },
                icon: const Icon(Icons.clear),
              ),
            ),
            onSubmitted: searchStore.handleQuery,
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: FocusManager.instance.primaryFocus?.unfocus,
            child: Observer(
              builder: (context) {
                if (textEditingController.text.isEmpty || searchStore.channelFuture == null || searchStore.categoryFuture == null) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (searchStore.searchHistory.isNotEmpty)
                        const Padding(
                          padding: EdgeInsets.all(15.0),
                          child: Text(
                            'HISTORY',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      Expanded(
                        child: ListView(
                          children: searchStore.searchHistory
                              .mapIndexed(
                                (index, searchTerm) => ListTile(
                                  leading: const Icon(Icons.history),
                                  title: Text(searchTerm),
                                  trailing: IconButton(
                                    tooltip: 'Remove',
                                    icon: const Icon(Icons.cancel),
                                    onPressed: () => setState(() {
                                      searchStore.searchHistory.removeAt(index);
                                    }),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      textEditingController.text = searchTerm;
                                      searchStore.handleQuery(searchTerm);
                                    });
                                  },
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ],
                  );
                }
                return CustomScrollView(
                  slivers: [
                    const SliverToBoxAdapter(
                      child: SectionHeader(
                        'Channels',
                        padding: headerPadding,
                      ),
                    ),
                    SearchResultsChannels(
                      searchStore: searchStore,
                      query: textEditingController.text,
                    ),
                    const SliverToBoxAdapter(
                      child: SectionHeader(
                        'Categories',
                        padding: headerPadding,
                      ),
                    ),
                    SearchResultsCategories(searchStore: searchStore),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }
}
