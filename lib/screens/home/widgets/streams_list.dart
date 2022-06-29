import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/api/twitch_api.dart';
import 'package:frosty/core/auth/auth_store.dart';
import 'package:frosty/screens/home/stores/list_store.dart';
import 'package:frosty/screens/home/widgets/stream_card.dart';
import 'package:frosty/screens/settings/stores/settings_store.dart';
import 'package:frosty/widgets/alert_message.dart';
import 'package:frosty/widgets/loading_indicator.dart';
import 'package:frosty/widgets/scroll_to_top_button.dart';
import 'package:provider/provider.dart';

/// A widget that displays a list of streams depending on the provided [listType].
/// If the [listType] is [ListType.category], [categoryId] must be provided.
class StreamsList extends StatefulWidget {
  /// The type of list to display.
  final ListType listType;

  /// The category to display streams from if the [listType] is [ListType.category].
  final String? categoryId;

  const StreamsList({
    Key? key,
    required this.listType,
    this.categoryId,
  }) : super(key: key);

  @override
  State<StreamsList> createState() => _StreamsListState();
}

class _StreamsListState extends State<StreamsList> with AutomaticKeepAliveClientMixin {
  late final _listStore = ListStore(
    authStore: context.read<AuthStore>(),
    twitchApi: context.read<TwitchApi>(),
    listType: widget.listType,
    categoryId: widget.categoryId,
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
            content: AlertMessage(
              message: _listStore.error!,
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
          if (_listStore.isLoading && _listStore.error == null) {
            return const Center(
              child: LoadingIndicator(subtitle: 'Loading streams...'),
            );
          }

          if (_listStore.streams.isEmpty) {
            return const Center(
              child: AlertMessage(message: 'No followed streams'),
            );
          }

          return Stack(
            alignment: AlignmentDirectional.bottomCenter,
            children: [
              ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                controller: _listStore.scrollController,
                itemCount: _listStore.streams.length,
                itemBuilder: (context, index) {
                  if (index > _listStore.streams.length - 8 && _listStore.hasMore) {
                    debugPrint('$index ${_listStore.streams.length}');

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
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
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
