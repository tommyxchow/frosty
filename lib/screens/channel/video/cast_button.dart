import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:frosty/services/cast_route_picker_state.dart';
import 'package:frosty/services/cast_state.dart';
import 'package:frosty/services/stream_proxy_bridge.dart';
import 'package:frosty/utils/modal_bottom_sheet.dart';
import 'package:frosty/widgets/section_header.dart';

class CastButton extends StatelessWidget {
  final Color? color;
  final List<Shadow>? shadows;
  final bool? isSupported;

  const CastButton({super.key, this.color, this.shadows, this.isSupported});

  @override
  Widget build(BuildContext context) {
    if (!(isSupported ?? Platform.isAndroid)) return const SizedBox.shrink();

    return ValueListenableBuilder<CastState>(
      valueListenable: StreamProxyBridge.castState,
      builder: (context, castState, _) {
        if (castState.isCasting) return const SizedBox.shrink();

        return SizedBox.square(
          dimension: 48,
          child: IconButton(
            tooltip: 'Cast',
            icon: Icon(Icons.cast_rounded, color: color, shadows: shadows),
            onPressed: () => showCastPicker(context),
          ),
        );
      },
    );
  }
}

class CastStatusButton extends StatelessWidget {
  final CastState castState;
  final Color? color;
  final List<Shadow>? shadows;

  const CastStatusButton({
    super.key,
    required this.castState,
    this.color,
    this.shadows,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: _castTooltip(castState),
      iconSize: 56,
      icon: Icon(Icons.cast_connected_rounded, color: color, shadows: shadows),
      onPressed: () => showCastPicker(context),
    );
  }
}

String _castTooltip(CastState castState) {
  if (castState.receiverName == null) return 'Casting';

  return 'Casting to ${castState.receiverName}';
}

Future<void> showCastPicker(BuildContext context) {
  return showModalBottomSheetWithProperFocus<void>(
    context: context,
    showDragHandle: true,
    builder: (context) => const _CastRoutePickerSheet(),
  );
}

class _CastRoutePickerSheet extends StatefulWidget {
  const _CastRoutePickerSheet();

  @override
  State<_CastRoutePickerSheet> createState() => _CastRoutePickerSheetState();
}

class _CastRoutePickerSheetState extends State<_CastRoutePickerSheet> {
  @override
  void initState() {
    super.initState();
    unawaited(StreamProxyBridge.startCastRouteDiscovery());
  }

  @override
  void dispose() {
    unawaited(StreamProxyBridge.stopCastRouteDiscovery());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ValueListenableBuilder<CastState>(
        valueListenable: StreamProxyBridge.castState,
        builder: (context, castState, _) =>
            ValueListenableBuilder<CastRoutePickerState>(
              valueListenable: StreamProxyBridge.castRoutePickerState,
              builder: (context, pickerState, _) => _CastRoutePickerContent(
                castState: castState,
                pickerState: pickerState,
              ),
            ),
      ),
    );
  }
}

class _CastRoutePickerContent extends StatelessWidget {
  final CastState castState;
  final CastRoutePickerState pickerState;

  const _CastRoutePickerContent({
    required this.castState,
    required this.pickerState,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          'Cast to device',
          padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
          isFirst: true,
        ),
        if (castState.isCasting)
          _ConnectedCastControls(castState: castState)
        else if (pickerState.isConnecting)
          const ListTile(
            leading: SizedBox.square(
              dimension: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            title: Text('Connecting...'),
          )
        else ...[
          if (pickerState.error != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(
                pickerState.error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          if (pickerState.routes.isEmpty)
            _EmptyRouteListTile(
              isSearching: pickerState.isSearching,
              hasError: pickerState.error != null,
            )
          else
            Flexible(
              child: ListView(
                shrinkWrap: true,
                primary: false,
                children: pickerState.routes
                    .map((route) => _CastRouteTile(route: route))
                    .toList(),
              ),
            ),
        ],
      ],
    );
  }
}

class _CastRouteTile extends StatelessWidget {
  final CastRoute route;

  const _CastRouteTile({required this.route});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.tv_rounded),
      title: Text(route.name),
      subtitle: route.description == null ? null : Text(route.description!),
      onTap: () => StreamProxyBridge.selectCastRoute(route),
    );
  }
}

class _EmptyRouteListTile extends StatelessWidget {
  final bool isSearching;
  final bool hasError;

  const _EmptyRouteListTile({
    required this.isSearching,
    required this.hasError,
  });

  @override
  Widget build(BuildContext context) {
    if (isSearching) {
      return const ListTile(
        leading: SizedBox.square(
          dimension: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        title: Text('Searching for devices...'),
      );
    }

    return ListTile(
      leading: const Icon(Icons.cast_rounded),
      title: Text(hasError ? 'Unable to find devices' : 'No devices found'),
      trailing: TextButton(
        onPressed: StreamProxyBridge.startCastRouteDiscovery,
        child: const Text('Retry'),
      ),
    );
  }
}

class _ConnectedCastControls extends StatelessWidget {
  final CastState castState;

  const _ConnectedCastControls({required this.castState});

  @override
  Widget build(BuildContext context) {
    final receiverName = castState.receiverName ?? 'Cast device';
    final latency = castState.formattedLatency;

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListTile(
            leading: const Icon(Icons.cast_connected_rounded),
            title: Text(receiverName),
            subtitle: latency == null
                ? const Text('Casting')
                : Text('Casting - $latency latency'),
            trailing: TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await StreamProxyBridge.stopCasting();
              },
              child: const Text('Disconnect'),
            ),
          ),
        ],
      ),
    );
  }
}
