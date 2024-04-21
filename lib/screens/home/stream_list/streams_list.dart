import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/apis/twitch_api.dart';
import 'package:frosty/screens/home/stream_list/large_stream_card.dart';
import 'package:frosty/screens/home/stream_list/stream_card.dart';
import 'package:frosty/screens/home/stream_list/stream_list_store.dart';
import 'package:frosty/screens/home/top/categories/category_card.dart';
import 'package:frosty/screens/settings/stores/auth_store.dart';
import 'package:frosty/screens/settings/stores/settings_store.dart';
import 'package:frosty/widgets/alert_message.dart';
import 'package:frosty/widgets/loading_indicator.dart';
import 'package:frosty/widgets/scroll_to_top_button.dart';
import 'package:provider/provider.dart';

/// A widget that displays a list of followed or top streams based on the provided [listType].
/// For a widget that displays the top streams under a category, refer to [CategoryStreams].
class StreamsList extends StatefulWidget {
  /// The type of list to display.
  final ListType listType;

  final String? categoryId;

  /// The scroll controller to use for scroll to top functionality.
  final ScrollController? scrollController;

  final bool showJumpButton;

  const StreamsList({
    super.key,
    required this.listType,
    this.categoryId,
    this.scrollController,
    this.showJumpButton = false,
  });

  @override
  State<StreamsList> createState() => _StreamsListState();
}

class _StreamsListState extends State<StreamsList>
    with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  late final _listStore = ListStore(
    authStore: context.read<AuthStore>(),
    twitchApi: context.read<TwitchApi>(),
    listType: widget.listType,
    categoryId: widget.categoryId,
    scrollController: widget.scrollController ??
        (widget.showJumpButton ? ScrollController() : null),
  );

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      _listStore.checkLastTimeRefreshedAndUpdate();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    _listStore.checkLastTimeRefreshedAndUpdate();

    return RefreshIndicator.adaptive(
      onRefresh: () async {
        HapticFeedback.lightImpact();

        await _listStore.refreshStreams();

        if (_listStore.error != null) {
          final snackBar = SnackBar(
            content: AlertMessage(
              message: _listStore.error!,
              centered: false,
            ),
          );

          if (!context.mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      },
      child: Observer(
        builder: (_) {
          Widget? statusWidget;

          if (_listStore.error != null) {
            statusWidget = AlertMessage(message: _listStore.error!);
          }

          if (_listStore.streams.isEmpty) {
            if (_listStore.isLoading && _listStore.error == null) {
              statusWidget =
                  const LoadingIndicator(subtitle: 'Loading streams...');
            } else {
              statusWidget = AlertMessage(
                message: widget.listType == ListType.followed
                    ? 'No followed streams'
                    : 'No top streams',
              );
            }
          }

          if (statusWidget != null) {
            return CustomScrollView(
              slivers: [
                SliverFillRemaining(
                  child: Center(
                    child: statusWidget,
                  ),
                ),
              ],
            );
          }

          return Stack(
            alignment: AlignmentDirectional.bottomCenter,
            children: [
              Column(
                children: [
                  if (widget.categoryId != null &&
                      _listStore.categoryDetails != null)
                    CategoryCard(
                      category: _listStore.categoryDetails!,
                      isTappable: false,
                    ),
                  Expanded(
                    child: Scrollbar(
                      controller: _listStore.scrollController,
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        controller: _listStore.scrollController,
                        itemCount: _listStore.streams.length,
                        itemBuilder: (context, index) {
                          if (index > _listStore.streams.length - 10 &&
                              _listStore.hasMore) {
                            debugPrint('$index ${_listStore.streams.length}');

                            _listStore.getStreams();
                          }
                          return Observer(
                            builder: (context) =>
                                context.read<SettingsStore>().largeStreamCard
                                    ? LargeStreamCard(
                                        key: ValueKey(
                                          _listStore.streams[index].userId,
                                        ),
                                        streamInfo: _listStore.streams[index],
                                        showThumbnail: context
                                            .read<SettingsStore>()
                                            .showThumbnails,
                                        showCategory: widget.categoryId == null,
                                      )
                                    : StreamCard(
                                        key: ValueKey(
                                          _listStore.streams[index].userId,
                                        ),
                                        streamInfo: _listStore.streams[index],
                                        showThumbnail: context
                                            .read<SettingsStore>()
                                            .showThumbnails,
                                        showCategory: widget.categoryId == null,
                                      ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
              if (widget.showJumpButton)
                Observer(
                  builder: (context) => AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    child: _listStore.showJumpButton
                        ? ScrollToTopButton(
                            scrollController: _listStore.scrollController!,
                          )
                        : null,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _listStore.dispose();
    super.dispose();
  }
}
