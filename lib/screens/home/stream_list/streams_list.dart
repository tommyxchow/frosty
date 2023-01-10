import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/apis/twitch_api.dart';
import 'package:frosty/screens/home/stream_list/large_stream_card.dart';
import 'package:frosty/screens/home/stream_list/stream_card.dart';
import 'package:frosty/screens/home/stream_list/stream_list_store.dart';
import 'package:frosty/screens/settings/stores/auth_store.dart';
import 'package:frosty/screens/settings/stores/settings_store.dart';
import 'package:frosty/widgets/alert_message.dart';
import 'package:frosty/widgets/loading_indicator.dart';
import 'package:provider/provider.dart';

/// A widget that displays a list of followed or top streams based on the provided [listType].
/// For a widget that displays the top streams under a category, refer to [CategoryStreams].
class StreamsList extends StatefulWidget {
  /// The type of list to display.
  final ListType listType;

  /// The scroll controller to use for scroll to top functionality.
  final ScrollController scrollController;

  const StreamsList({
    Key? key,
    required this.listType,
    required this.scrollController,
  }) : super(key: key);

  @override
  State<StreamsList> createState() => _StreamsListState();
}

class _StreamsListState extends State<StreamsList> with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  late final _listStore = ListStore(
    authStore: context.read<AuthStore>(),
    twitchApi: context.read<TwitchApi>(),
    listType: widget.listType,
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

    if (state == AppLifecycleState.resumed) _listStore.checkLastTimeRefreshedAndUpdate();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    _listStore.checkLastTimeRefreshedAndUpdate();

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
              statusWidget = AlertMessage(
                  message: widget.listType == ListType.followed ? 'No followed streams' : 'No top streams');
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
                builder: (context) => context.read<SettingsStore>().largeStreamCard
                    ? LargeStreamCard(
                        streamInfo: _listStore.streams[index],
                        showThumbnail: context.read<SettingsStore>().showThumbnails)
                    : StreamCard(
                        streamInfo: _listStore.streams[index],
                        showThumbnail: context.read<SettingsStore>().showThumbnails,
                      ),
              );
            },
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
