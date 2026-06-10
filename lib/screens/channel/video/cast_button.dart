import 'dart:io';

import 'package:flutter/material.dart';
import 'package:frosty/services/cast_state.dart';
import 'package:frosty/services/stream_proxy_bridge.dart';
import 'package:frosty/utils/modal_bottom_sheet.dart';

class CastButton extends StatelessWidget {
  final Color? color;
  final List<Shadow>? shadows;

  const CastButton({super.key, this.color, this.shadows});

  @override
  Widget build(BuildContext context) {
    if (!Platform.isAndroid) return const SizedBox.shrink();

    return ValueListenableBuilder<CastState>(
      valueListenable: StreamProxyBridge.castState,
      builder: (context, castState, _) => SizedBox.square(
        dimension: 48,
        child: IconButton(
          tooltip: castState.isCasting
              ? 'Casting to ${castState.receiverName ?? 'device'}'
              : 'Cast',
          icon: Icon(
            castState.isCasting
                ? Icons.cast_connected_rounded
                : Icons.cast_rounded,
            color: castState.isCasting ? Colors.white : color,
            shadows: shadows,
          ),
          onPressed: () => _handlePressed(context, castState),
        ),
      ),
    );
  }

  Future<void> _handlePressed(BuildContext context, CastState castState) async {
    if (!castState.isCasting) {
      await StreamProxyBridge.showCastDialog();
      return;
    }

    if (!context.mounted) return;
    await _showCastControls(context, castState);
  }

  Future<void> _showCastControls(BuildContext context, CastState castState) {
    final receiverName = castState.receiverName ?? 'Cast device';
    final latency = castState.latencySeconds;

    return showModalBottomSheetWithProperFocus<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.cast_connected_rounded),
                title: Text(receiverName),
                subtitle: latency == null
                    ? const Text('Casting')
                    : Text('Casting - ${latency}s latency'),
                trailing: IconButton(
                  tooltip: 'Close',
                  icon: const Icon(Icons.close_rounded),
                  onPressed: Navigator.of(context).pop,
                ),
              ),
              const SizedBox(height: 8),
              FilledButton.icon(
                icon: const Icon(Icons.stop_rounded),
                label: const Text('Stop casting'),
                onPressed: () async {
                  Navigator.of(context).pop();
                  await StreamProxyBridge.stopCasting();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
