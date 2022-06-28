import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/api/twitch_api.dart';
import 'package:frosty/core/auth/auth_store.dart';
import 'package:frosty/models/category.dart';
import 'package:frosty/screens/home/stores/list_store.dart';
import 'package:frosty/screens/home/widgets/stream_card.dart';
import 'package:frosty/screens/settings/stores/settings_store.dart';
import 'package:frosty/widgets/loading_indicator.dart';
import 'package:frosty/widgets/scroll_to_top_button.dart';
import 'package:provider/provider.dart';

class StreamsList extends StatefulWidget {
  final ListType listType;
  final CategoryTwitch? categoryTwitch;

  const StreamsList({
    Key? key,
    required this.listType,
    this.categoryTwitch,
  }) : super(key: key);

  @override
  State<StreamsList> createState() => _StreamsListState();
}

class _StreamsListState extends State<StreamsList> with AutomaticKeepAliveClientMixin {
  late final _listStore = ListStore(
    authStore: context.read<AuthStore>(),
    twitchApi: context.read<TwitchApi>(),
    listType: widget.listType,
    categoryInfo: widget.categoryTwitch,
  );

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return RefreshIndicator(
      onRefresh: () async {
        HapticFeedback.lightImpact();

        await _listStore.refreshStreams();

        if (_listStore.error != null) {
          final snackBar = SnackBar(
            content: Text(_listStore.error!),
            behavior: SnackBarBehavior.floating,
          );

          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      },
      child: Observer(
        builder: (_) {
          if (_listStore.streams.isEmpty && _listStore.isLoading && _listStore.error == null) {
            return const LoadingIndicator(subtitle: Text('Loading streams...'));
          }
          return Stack(
            alignment: AlignmentDirectional.bottomCenter,
            children: [
              ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                controller: _listStore.scrollController,
                itemCount: _listStore.streams.length,
                itemBuilder: (context, index) {
                  if (index > _listStore.streams.length / 2 && _listStore.hasMore) {
                    _listStore.getStreams();
                  }
                  return Observer(
                    builder: (context) => StreamCard(
                      listStore: _listStore,
                      streamInfo: _listStore.streams[index],
                      showThumbnail: context.read<SettingsStore>().showThumbnails,
                      large: context.read<SettingsStore>().largeStreamCard,
                      showUptime: context.read<SettingsStore>().showThumbnailUptime,
                    ),
                  );
                },
              ),
              Observer(
                builder: (context) => AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: _listStore.showJumpButton ? ScrollToTopButton(scrollController: _listStore.scrollController) : null,
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
    _listStore.dispose();
    super.dispose();
  }
}
