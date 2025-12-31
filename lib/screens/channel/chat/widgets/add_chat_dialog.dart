import 'dart:async';

import 'package:flutter/material.dart';
import 'package:frosty/apis/twitch_api.dart';
import 'package:frosty/models/channel.dart';
import 'package:frosty/utils.dart';
import 'package:frosty/utils/modal_bottom_sheet.dart';
import 'package:frosty/widgets/alert_message.dart';
import 'package:frosty/widgets/animated_scroll_border.dart';
import 'package:frosty/widgets/live_indicator.dart';
import 'package:frosty/widgets/profile_picture.dart';
import 'package:frosty/widgets/section_header.dart';
import 'package:frosty/widgets/skeleton_loader.dart';
import 'package:frosty/widgets/uptime.dart';

/// Data class returned when a channel is selected in the AddChatSheet.
class AddChatResult {
  final String channelId;
  final String channelLogin;
  final String displayName;

  const AddChatResult({
    required this.channelId,
    required this.channelLogin,
    required this.displayName,
  });
}

/// Bottom sheet for adding a new chat tab by searching for a Twitch channel.
class AddChatSheet extends StatefulWidget {
  final TwitchApi twitchApi;

  const AddChatSheet({super.key, required this.twitchApi});

  /// Shows the bottom sheet and returns the selected channel info, or null if cancelled.
  static Future<AddChatResult?> show(
    BuildContext context,
    TwitchApi twitchApi,
  ) {
    return showModalBottomSheetWithProperFocus<AddChatResult>(
      context: context,
      isScrollControlled: true,
      builder: (context) => AddChatSheet(twitchApi: twitchApi),
    );
  }

  @override
  State<AddChatSheet> createState() => _AddChatSheetState();
}

class _AddChatSheetState extends State<AddChatSheet> {
  final _textController = TextEditingController();
  final _focusNode = FocusNode();
  final _scrollController = ScrollController();

  Timer? _debounce;
  bool _isLoading = false;
  String? _errorMessage;
  List<ChannelQuery> _results = [];

  @override
  void initState() {
    super.initState();
    _textController.addListener(() => setState(() {}));
    _focusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _textController.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    // Cancel any existing debounce
    _debounce?.cancel();

    if (query.isEmpty) {
      setState(() {
        _results = [];
        _errorMessage = null;
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Debounce the search by 300ms
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      try {
        final channels = await widget.twitchApi.searchChannels(query: query);
        if (mounted) {
          setState(() {
            _results = channels;
            _isLoading = false;
            _errorMessage = null;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _results = [];
            _isLoading = false;
            _errorMessage = 'Failed to search channels';
          });
        }
      }
    });
  }

  void _selectChannel(ChannelQuery channel) {
    Navigator.of(context).pop(
      AddChatResult(
        channelId: channel.id,
        channelLogin: channel.broadcasterLogin,
        displayName: channel.displayName,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.8,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader('Add Chat', isFirst: true),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              child: TextField(
                controller: _textController,
                focusNode: _focusNode,
                autocorrect: false,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search_rounded),
                  hintText: 'Search for a channel',
                  suffixIcon:
                      _focusNode.hasFocus || _textController.text.isNotEmpty
                      ? IconButton(
                          tooltip: _textController.text.isEmpty
                              ? 'Cancel'
                              : 'Clear',
                          onPressed: () {
                            if (_textController.text.isEmpty) {
                              _focusNode.unfocus();
                            }
                            _textController.clear();
                            _onSearchChanged('');
                          },
                          icon: const Icon(Icons.close_rounded),
                        )
                      : null,
                ),
                onChanged: _onSearchChanged,
                textInputAction: TextInputAction.search,
              ),
            ),
            AnimatedScrollBorder(scrollController: _scrollController),
            Expanded(child: _buildResults()),
          ],
        ),
      ),
    );
  }

  Widget _buildResults() {
    if (_textController.text.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Search for a channel to add',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    if (_isLoading) {
      return ListView.builder(
        controller: _scrollController,
        itemCount: 8,
        itemBuilder: (context, index) => ChannelSkeletonLoader(index: index),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: AlertMessage(message: _errorMessage!),
        ),
      );
    }

    if (_results.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'No channels found',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.zero,
      itemCount: _results.length,
      itemBuilder: (context, index) {
        final channel = _results[index];
        final displayName = getReadableName(
          channel.displayName,
          channel.broadcasterLogin,
        );

        return ListTile(
          leading: ProfilePicture(
            userLogin: channel.broadcasterLogin,
            radius: 16,
          ),
          title: Text(displayName),
          subtitle: channel.isLive
              ? Row(
                  spacing: 6,
                  children: [
                    const LiveIndicator(),
                    Uptime(startTime: channel.startedAt),
                  ],
                )
              : null,
          onTap: () => _selectChannel(channel),
        );
      },
    );
  }
}

// Keep backward compatibility alias
typedef AddChatDialog = AddChatSheet;
