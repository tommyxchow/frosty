import 'package:flutter_test/flutter_test.dart';
import 'package:frosty/services/cast_state.dart';

void main() {
  group('CastState', () {
    test('parses active cast state from method channel payload', () {
      final state = CastState.fromMethodChannelPayload({
        'isCasting': true,
        'receiverName': 'Jacoby\'s TV',
        'latencyMs': 7420,
      });

      expect(state.isCasting, isTrue);
      expect(state.receiverName, 'Jacoby\'s TV');
      expect(state.latency, const Duration(milliseconds: 7420));
      expect(state.latencySeconds, 7.42);
      expect(state.formattedLatency, '7.42s');
    });

    test('treats missing and malformed payloads as disconnected', () {
      expect(CastState.fromMethodChannelPayload(null).isCasting, isFalse);
      expect(CastState.fromMethodChannelPayload('bad').isCasting, isFalse);
      expect(
        CastState.fromMethodChannelPayload({'isCasting': false}).latency,
        isNull,
      );
    });
  });
}
