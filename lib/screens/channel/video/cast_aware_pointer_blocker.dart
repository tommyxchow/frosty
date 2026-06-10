import 'package:flutter/material.dart';
import 'package:frosty/services/cast_state.dart';
import 'package:frosty/services/stream_proxy_bridge.dart';

class CastAwarePointerBlocker extends StatelessWidget {
  final Widget child;

  const CastAwarePointerBlocker({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<CastState>(
      valueListenable: StreamProxyBridge.castState,
      builder: (context, castState, child) =>
          AbsorbPointer(absorbing: castState.isCasting, child: child),
      child: child,
    );
  }
}
