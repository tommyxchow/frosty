import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:frosty/apis/twitch_api.dart';
import 'package:frosty/screens/channel/chat/details/chat_details_store.dart';
import 'package:frosty/screens/channel/chat/stores/chat_store.dart';
import 'package:frosty/screens/channel/chat/widgets/chat_user_modal.dart';
import 'package:frosty/screens/settings/stores/auth_store.dart';
import 'package:frosty/widgets/alert_message.dart';
import 'package:frosty/widgets/button.dart';
import 'package:frosty/widgets/loading_indicator.dart';
import 'package:frosty/widgets/scroll_to_top_button.dart';
import 'package:frosty/widgets/section_header.dart';
import 'package:heroicons/heroicons.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ChattersList extends StatelessWidget {
  final ChatDetailsStore chatDetailsStore;
  final ChatStore chatStore;
  final String userLogin;

  const ChattersList({
    Key? key,
    required this.chatDetailsStore,
    required this.chatStore,
    required this.userLogin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const headers = [
      'Broadcaster',
      'Staff',
      'Admins',
      'Global Moderators',
      'Moderators',
      'VIPs',
      'Viewers',
    ];

    return Observer(
      builder: (context) {
        if (chatDetailsStore.error != null) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const AlertMessage(
                message: 'Failed to get chatters',
              ),
              const SizedBox(height: 10.0),
              Button(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                onPressed: chatDetailsStore.updateChatters,
                child: const Text('Try Again'),
              )
            ],
          );
        }

        if (chatDetailsStore.chatUsers == null) {
          return const LoadingIndicator(subtitle: 'Getting chatters...');
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Observer(
                builder: (context) {
                  return TextField(
                    controller: chatDetailsStore.textController,
                    focusNode: chatDetailsStore.textFieldFocusNode,
                    autocorrect: false,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.zero,
                      prefixIcon: const Icon(Icons.filter_list),
                      hintText: 'Filter chatters',
                      suffixIcon: chatDetailsStore.textFieldFocusNode.hasFocus || chatDetailsStore.filterText.isNotEmpty
                          ? IconButton(
                              tooltip: chatDetailsStore.filterText.isEmpty ? 'Cancel' : 'Clear',
                              onPressed: () {
                                if (chatDetailsStore.filterText.isEmpty) chatDetailsStore.textFieldFocusNode.unfocus();
                                chatDetailsStore.textController.clear();
                              },
                              icon: const HeroIcon(
                                HeroIcons.xMark,
                                style: HeroIconStyle.solid,
                              ),
                            )
                          : null,
                    ),
                  );
                },
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  HapticFeedback.lightImpact();

                  chatDetailsStore.updateChatters();
                },
                child: Stack(
                  alignment: AlignmentDirectional.bottomCenter,
                  children: [
                    Observer(
                      builder: (context) {
                        return CustomScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          controller: chatDetailsStore.scrollController,
                          slivers: [
                            if (chatDetailsStore.filterText.isEmpty)
                              SliverPadding(
                                padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 20.0),
                                sliver: SliverToBoxAdapter(
                                  child: Text(
                                    '${NumberFormat().format(chatDetailsStore.chatUsers?.chatterCount)} ${chatDetailsStore.chatUsers?.chatterCount == 1 ? 'Chatter' : 'Chatters'}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18.0,
                                    ),
                                  ),
                                ),
                              ),
                            if (chatDetailsStore.chatUsers?.chatterCount == 0)
                              const SliverFillRemaining(
                                hasScrollBody: false,
                                child: Center(
                                  child: AlertMessage(message: 'No chatters found'),
                                ),
                              )
                            else if (chatDetailsStore.filteredUsers.expand((element) => element).isEmpty)
                              const SliverFillRemaining(
                                hasScrollBody: false,
                                child: Center(
                                  child: AlertMessage(message: 'No matching chatters'),
                                ),
                              )
                            else
                              ...chatDetailsStore.filteredUsers.expandIndexed(
                                (index, users) => [
                                  if (users.isNotEmpty) ...[
                                    SliverPadding(
                                      padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 20.0),
                                      sliver: SliverToBoxAdapter(
                                        child: SectionHeader(
                                          headers[index],
                                          padding: const EdgeInsets.symmetric(vertical: 5.0),
                                        ),
                                      ),
                                    ),
                                    SliverList(
                                      delegate: SliverChildBuilderDelegate(
                                        (context, index) => InkWell(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                                            child: Text(users[index]),
                                          ),
                                          onLongPress: () async {
                                            HapticFeedback.lightImpact();

                                            final userInfo = await context.read<TwitchApi>().getUser(
                                                headers: context.read<AuthStore>().headersTwitch,
                                                userLogin: users[index]);

                                            showModalBottomSheet(
                                              backgroundColor: Colors.transparent,
                                              isScrollControlled: true,
                                              context: context,
                                              builder: (context) => ChatUserModal(
                                                chatStore: chatStore,
                                                username: userInfo.login,
                                                userId: userInfo.id,
                                                displayName: userInfo.displayName,
                                              ),
                                            );
                                          },
                                        ),
                                        childCount: users.length,
                                      ),
                                    ),
                                  ]
                                ],
                              ),
                          ],
                        );
                      },
                    ),
                    Observer(
                      builder: (context) => AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
                        child: chatDetailsStore.showJumpButton
                            ? ScrollToTopButton(scrollController: chatDetailsStore.scrollController)
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
