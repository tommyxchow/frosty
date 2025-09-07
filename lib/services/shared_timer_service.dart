import 'dart:async';

import 'package:flutter/foundation.dart';

/// A singleton service that provides a shared timer for synchronizing uptime displays
/// across all stream cards. This prevents multiple independent timers from running
/// and ensures all uptime displays update simultaneously.
class SharedTimerService extends ChangeNotifier {
  static final SharedTimerService _instance = SharedTimerService._internal();
  static SharedTimerService get instance => _instance;

  SharedTimerService._internal();

  Timer? _timer;
  int _listenerCount = 0;
  DateTime _lastTick = DateTime.now();

  /// The current time that should be used for all uptime calculations
  DateTime get currentTime => _lastTick;

  /// Starts the shared timer when the first listener is added
  @override
  void addListener(VoidCallback listener) {
    super.addListener(listener);
    _listenerCount++;

    // Start the timer when we get the first listener
    if (_listenerCount == 1) {
      _startTimer();
    }
  }

  /// Stops the shared timer when the last listener is removed
  @override
  void removeListener(VoidCallback listener) {
    super.removeListener(listener);
    _listenerCount--;

    // Stop the timer when we have no more listeners
    if (_listenerCount == 0) {
      _stopTimer();
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _lastTick = DateTime.now();
      notifyListeners();
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }
}
