import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frosty/screens/channel/video/cast_aware_pointer_blocker.dart';
import 'package:frosty/services/cast_state.dart';
import 'package:frosty/services/stream_proxy_bridge.dart';

void main() {
  tearDown(() {
    StreamProxyBridge.castState.value = const CastState.disconnected();
  });

  testWidgets('absorbs child pointer events while casting', (tester) async {
    StreamProxyBridge.castState.value = const CastState(isCasting: true);

    await tester.pumpWidget(
      const MaterialApp(home: CastAwarePointerBlocker(child: Text('video'))),
    );

    final blocker = _videoBlocker(tester);

    expect(blocker.absorbing, isTrue);
  });

  testWidgets('lets child pointer events through when not casting', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: CastAwarePointerBlocker(child: Text('video'))),
    );

    final blocker = _videoBlocker(tester);

    expect(blocker.absorbing, isFalse);
  });
}

AbsorbPointer _videoBlocker(WidgetTester tester) {
  return tester
      .widgetList<AbsorbPointer>(find.byType(AbsorbPointer))
      .singleWhere((widget) => widget.child is Text);
}
