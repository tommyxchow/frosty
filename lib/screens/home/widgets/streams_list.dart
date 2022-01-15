import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/screens/home/stores/list_store.dart';
import 'package:frosty/screens/home/widgets/stream_card.dart';
import 'package:frosty/screens/settings/stores/settings_store.dart';
import 'package:frosty/widgets/loading_indicator.dart';
import 'package:frosty/widgets/scroll_to_top_button.dart';
import 'package:provider/provider.dart';

class StreamsList extends StatefulWidget {
  final ListStore store;

  const StreamsList({Key? key, required this.store}) : super(key: key);

  @override
  _StreamsListState createState() => _StreamsListState();
}

class _StreamsListState extends State<StreamsList> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    final store = widget.store;

    return RefreshIndicator(
      onRefresh: () async {
        HapticFeedback.lightImpact();
        await store.refreshStreams();

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
          if (store.streams.isEmpty && store.isLoading && store.error == null) {
            return const LoadingIndicator(subtitle: Text('Loading streams...'));
          }
          return Stack(
            alignment: AlignmentDirectional.bottomCenter,
            children: [
              ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                controller: store.scrollController,
                itemCount: store.streams.length,
                itemBuilder: (context, index) {
                  if (index > store.streams.length / 2 && store.hasMore) {
                    store.getStreams();
                  }
                  return Observer(
                    builder: (context) => StreamCard(
                      streamInfo: store.streams[index],
                      showUptime: context.read<SettingsStore>().showThumbnailUptime,
                    ),
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
