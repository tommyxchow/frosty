import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'webview latency tracker keeps two decimal places in overlay labels',
    () {
      final source = File(
        'lib/screens/channel/video/video_store.dart',
      ).readAsStringSync();

      expect(source, contains("parseFloat(match[1]).toFixed(2) + 's'"));
      expect(source, isNot(contains("Math.round(parseFloat(match[1])) + 's'")));
    },
  );
}
