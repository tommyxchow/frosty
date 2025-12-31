import 'dart:async';

import 'package:flutter/material.dart';
import 'package:frosty/apis/twitch_api.dart';
import 'package:frosty/models/channel.dart';
import 'package:frosty/utils.dart';
import 'package:frosty/widgets/alert_message.dart';
import 'package:frosty/widgets/live_indicator.dart';
import 'package:frosty/widgets/profile_picture.dart';
import 'package:frosty/widgets/uptime.dart';

/// Data class returned when a channel is selected in the AddChatDialog.
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

/// Dialog for adding a new chat tab by searching for a Twitch channel.
class AddChatDialog extends StatefulWidget {
  final TwitchApi twitchApi;

  const AddChatDialog({super.key, required this.twitchApi});

  /// Shows the dialog and returns the selected channel info, or null if cancelled.
  static Future<AddChatResult?> show(
    BuildContext context,
    TwitchApi twitchApi,
  ) {
    return showDialog<AddChatResult>(
      context: context,
      builder: (context) => AddChatDialog(twitchApi: twitchApi),
    );
  }

  @override
  State<AddChatDialog> createState() => _AddChatDialogState();
}

class _AddChatDialogState extends State<AddChatDialog> {
  final _textController = TextEditingController();
  final _focusNode = FocusNode();

  Timer? _debounce;
  bool _isLoading = false;
  String? _errorMessage;
  List<ChannelQuery> _results = [];

  @override
  void initState() {
    super.initState();
    // Auto-focus the text field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _textController.dispose();
    _focusNode.dispose();
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
    return AlertDialog(
      title: const Text('Add Chat'),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _textController,
              focusNode: _focusNode,
              decoration: InputDecoration(
                hintText: 'Search for a channel...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _textController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _textController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
              ),
              onChanged: _onSearchChanged,
              textInputAction: TextInputAction.search,
            ),
            const SizedBox(height: 16),
            Expanded(child: _buildResults()),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }

  Widget _buildResults() {
    if (_textController.text.isEmpty) {
      return const Center(
        child: Text(
          'Enter a channel name to search',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: AlertMessage(message: _errorMessage!),
      );
    }

    if (_results.isEmpty) {
      return const Center(
        child: Text(
          'No channels found',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
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
          ),
          title: Text(displayName),
          subtitle: channel.isLive && channel.startedAt.isNotEmpty
              ? Row(
                  spacing: 6,
                  children: [
                    const LiveIndicator(),
                    Uptime(startTime: channel.startedAt),
                  ],
                )
              : Text(channel.isLive ? 'Live' : 'Offline'),
          onTap: () => _selectChannel(channel),
        );
      },
    );
  }
}
