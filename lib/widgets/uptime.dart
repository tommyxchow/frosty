import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// A widget that displays a timer representing the time since the given start time.
/// The timer is updated every second.
class Uptime extends HookWidget {
  final String startTime;
  final TextStyle? style;

  const Uptime({
    super.key,
    required this.startTime,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final updateTrigger = useState(0);

    useEffect(
      () {
        final timer = Timer.periodic(
          const Duration(seconds: 1),
          (timer) => updateTrigger.value++,
        );
        return timer.cancel;
      },
      [],
    );

    return Text(
      DateTime.now()
          .difference(DateTime.parse(startTime))
          .toString()
          .split('.')[0],
      style:
          style?.copyWith(fontFeatures: [const FontFeature.tabularFigures()]),
    );
  }
}
