import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/apis/twitch_api.dart';
import 'package:frosty/screens/home/stream_list/stream_card.dart';
import 'package:frosty/screens/home/stream_list/stream_list_store.dart';
import 'package:frosty/screens/settings/stores/auth_store.dart';
import 'package:frosty/screens/settings/stores/settings_store.dart';
import 'package:frosty/widgets/alert_message.dart';
import 'package:frosty/widgets/loading_indicator.dart';
import 'package:provider/provider.dart';

import '../home_store.dart';

/// A widget that displays a list of followed or top streams based on the provided [listType].
/// For a widget that displays the top streams under a category, refer to [CategoryStreams].
class StreamsList extends StatefulWidget {
  /// The type of list to display.
  final ListType listType;

  /// The scroll controller to use for scroll to top functionality.
  final ScrollController scrollController;

  final HomeStore homeStore;

  const StreamsList({
    Key? key,
    required this.listType,
    required this.scrollController,
    required this.homeStore,

  }) : super(key: key);

  @override
  State<StreamsList> createState() => _StreamsListState();
}

class _StreamsListState extends State<StreamsList> with AutomaticKeepAliveClientMixin {
  late final _listStore = ListStore(
    authStore: context.read<AuthStore>(),
    twitchApi: context.read<TwitchApi>(),
    listType: widget.listType,
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
          Widget? statusWidget;

          if (_listStore.error != null) {
            statusWidget = AlertMessage(
              message: _listStore.error!,
              icon: Icons.error,
            );
          }

          if (_listStore.streams.isEmpty) {
            if (_listStore.isLoading && _listStore.error == null) {
              statusWidget = const LoadingIndicator(subtitle: 'Loading streams...');
            } else {
              statusWidget = AlertMessage(message: widget.listType == ListType.followed ? 'No followed streams' : 'No top streams');
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

          return ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            controller: widget.scrollController,
            itemCount: _listStore.streams.length,
            itemBuilder: (context, index) {
              if (index > _listStore.streams.length - 10 && _listStore.hasMore) {
                debugPrint('$index ${_listStore.streams.length}');

                _listStore.getStreams();
              }
              return Observer(
                builder: (context) => StreamCard(
                  homeStore: widget.homeStore,
                  streamInfo: _listStore.streams[index],
                  showThumbnail: context.read<SettingsStore>().showThumbnails,
                  large: context.read<SettingsStore>().largeStreamCard,
                  showUptime: context.read<SettingsStore>().showThumbnailUptime,
                ),
              );
            },
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
