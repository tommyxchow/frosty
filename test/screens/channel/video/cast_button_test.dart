import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frosty/screens/channel/video/cast_button.dart';
import 'package:frosty/services/cast_route_picker_state.dart';
import 'package:frosty/services/cast_state.dart';
import 'package:frosty/services/stream_proxy_bridge.dart';

void main() {
  tearDown(() {
    StreamProxyBridge.castState.value = const CastState.disconnected();
    StreamProxyBridge.castRoutePickerState.value =
        const CastRoutePickerState.idle();
  });

  testWidgets('hides the header cast button while casting', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: CastButton(isSupported: true))),
    );

    expect(find.byIcon(Icons.cast_rounded), findsOneWidget);

    StreamProxyBridge.castState.value = const CastState(isCasting: true);
    await tester.pump();

    expect(find.byIcon(Icons.cast_rounded), findsNothing);
    expect(find.byIcon(Icons.cast_connected_rounded), findsNothing);
  });

  testWidgets('header cast button opens the cast route sheet', (tester) async {
    StreamProxyBridge.castRoutePickerState.value = const CastRoutePickerState(
      isSearching: false,
      isConnecting: false,
      routes: [
        CastRoute(id: 'route-1', name: 'BRAVIA 4K UR1 - Living Room TV'),
        CastRoute(id: 'route-2', name: 'Chromecast - Jacoby\'s TV'),
      ],
    );

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: CastButton(isSupported: true))),
    );

    await tester.tap(find.byTooltip('Cast'));
    await tester.pumpAndSettle();

    expect(find.text('CAST TO DEVICE'), findsOneWidget);
    expect(find.text('BRAVIA 4K UR1 - Living Room TV'), findsOneWidget);
    expect(find.text('Chromecast - Jacoby\'s TV'), findsOneWidget);
  });

  testWidgets('centered cast icon opens the connected cast sheet', (
    tester,
  ) async {
    const castState = CastState(
      isCasting: true,
      receiverName: 'Jacoby\'s TV',
      latency: Duration(milliseconds: 7420),
    );
    StreamProxyBridge.castState.value = castState;

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: CastStatusButton(castState: castState)),
      ),
    );

    await tester.tap(find.byTooltip('Casting to Jacoby\'s TV'));
    await tester.pumpAndSettle();

    expect(find.text('CAST TO DEVICE'), findsOneWidget);
    expect(find.text('Jacoby\'s TV'), findsOneWidget);
    expect(find.text('Casting - 7s latency'), findsOneWidget);
    expect(find.text('Disconnect'), findsOneWidget);
  });

  testWidgets('cast route sheet shows connecting state', (tester) async {
    StreamProxyBridge.castRoutePickerState.value = const CastRoutePickerState(
      isSearching: false,
      isConnecting: true,
      connectingRouteName: 'Jacoby\'s TV',
      routes: [],
    );

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: CastButton(isSupported: true))),
    );

    await tester.tap(find.byTooltip('Cast'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('CAST TO DEVICE'), findsOneWidget);
    expect(find.text('Connecting...'), findsOneWidget);
  });
}
