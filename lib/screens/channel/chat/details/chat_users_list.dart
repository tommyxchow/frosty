import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/apis/twitch_api.dart';
import 'package:frosty/screens/channel/chat/details/chat_details_store.dart';
import 'package:frosty/screens/channel/chat/stores/chat_store.dart';
import 'package:frosty/screens/channel/chat/widgets/chat_user_modal.dart';
import 'package:frosty/screens/settings/stores/auth_store.dart';
import 'package:frosty/widgets/alert_message.dart';
import 'package:frosty/widgets/animated_scroll_border.dart';
import 'package:frosty/widgets/scroll_to_top_button.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ChattersList extends StatefulWidget {
  final ChatDetailsStore chatDetailsStore;
  final ChatStore chatStore;
  final String userLogin;

  const ChattersList({
    super.key,
    required this.chatDetailsStore,
    required this.chatStore,
    required this.userLogin,
  });

  @override
  State<ChattersList> createState() => _ChattersListState();
}

class _ChattersListState extends State<ChattersList> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.8,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: Observer(
              builder: (context) {
                return TextField(
                  controller: widget.chatDetailsStore.textController,
                  focusNode: widget.chatDetailsStore.textFieldFocusNode,
                  autocorrect: false,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.filter_list_rounded),
                    hintText: 'Filter chatters',
                    suffixIcon: widget
                                .chatDetailsStore.textFieldFocusNode.hasFocus ||
                            widget.chatDetailsStore.filterText.isNotEmpty
                        ? IconButton(
                            tooltip: widget.chatDetailsStore.filterText.isEmpty
                                ? 'Cancel'
                                : 'Clear',
                            onPressed: () {
                              if (widget.chatDetailsStore.filterText.isEmpty) {
                                widget.chatDetailsStore.textFieldFocusNode
                                    .unfocus();
                              }
                              widget.chatDetailsStore.textController.clear();
                            },
                            icon: const Icon(Icons.close_rounded),
                          )
                        : null,
                  ),
                );
              },
            ),
          ),
          AnimatedScrollBorder(
            scrollController: widget.chatDetailsStore.scrollController,
          ),
          Expanded(
            child: RefreshIndicator.adaptive(
              onRefresh: () async {
                HapticFeedback.lightImpact();

                setState(() {});
              },
              child: Stack(
                alignment: AlignmentDirectional.bottomCenter,
                children: [
                  Scrollbar(
                    controller: widget.chatDetailsStore.scrollController,
                    child: Observer(
                      builder: (context) {
                        return CustomScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          controller: widget.chatDetailsStore.scrollController,
                          slivers: [
                            if (widget.chatDetailsStore.filterText.isEmpty)
                              SliverPadding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                sliver: SliverToBoxAdapter(
                                  child: Text(
                                    '${NumberFormat().format(widget.chatDetailsStore.chatUsers.length)} chatters found',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18.0,
                                    ),
                                  ),
                                ),
                              ),
                            if (widget.chatDetailsStore.chatUsers.isEmpty)
                              const SliverFillRemaining(
                                hasScrollBody: false,
                                child:
                                    AlertMessage(message: 'No chatters found'),
                              )
                            else if (widget
                                .chatDetailsStore.filteredUsers.isEmpty)
                              const SliverFillRemaining(
                                hasScrollBody: false,
                                child: AlertMessage(
                                  message: 'No matching chatters',
                                ),
                              )
                            else
                              SliverList.builder(
                                itemBuilder: (context, index) => InkWell(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 4,
                                    ),
                                    child: Text(
                                      widget.chatDetailsStore.filteredUsers
                                          .elementAt(index),
                                    ),
                                  ),
                                  onTap: () async {
                                    final userInfo =
                                        await context.read<TwitchApi>().getUser(
                                              headers: context
                                                  .read<AuthStore>()
                                                  .headersTwitch,
                                              userLogin: widget.chatDetailsStore
                                                  .filteredUsers
                                                  .elementAt(index),
                                            );

                                    if (!context.mounted) return;

                                    showModalBottomSheet(
                                      isScrollControlled: true,
                                      context: context,
                                      builder: (context) => ChatUserModal(
                                        chatStore: widget.chatStore,
                                        username: userInfo.login,
                                        userId: userInfo.id,
                                        displayName: userInfo.displayName,
                                      ),
                                    );
                                  },
                                ),
                                itemCount: widget
                                    .chatDetailsStore.filteredUsers.length,
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                  Observer(
                    builder: (context) => AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      switchInCurve: Curves.easeOut,
                      switchOutCurve: Curves.easeIn,
                      child: widget.chatDetailsStore.showJumpButton
                          ? ScrollToTopButton(
                              scrollController:
                                  widget.chatDetailsStore.scrollController,
                            )
                          : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    widget.chatDetailsStore.showJumpButton = false;
    super.dispose();
  }
}
