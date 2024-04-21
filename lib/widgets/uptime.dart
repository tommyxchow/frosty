import 'dart:async';

import 'package:flutter/material.dart';

/// A widget that displays a timer representing the time since the given start time.
/// The timer is updated every second.
class Uptime extends StatefulWidget {
  final String startTime;
  final TextStyle? style;

  const Uptime({
    super.key,
    required this.startTime,
    this.style,
  });

  @override
  State<Uptime> createState() => _UptimeState();
}

class _UptimeState extends State<Uptime> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer =
        Timer.periodic(const Duration(seconds: 1), (timer) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      DateTime.now()
          .difference(DateTime.parse(widget.startTime))
          .toString()
          .split('.')[0],
      style: widget.style
          ?.copyWith(fontFeatures: [const FontFeature.tabularFigures()]),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
