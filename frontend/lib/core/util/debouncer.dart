import 'dart:async';
import 'dart:ui';

class Debouncer {
  final Duration delay;
  Timer? _timer;

  Debouncer({required this.delay});

  void run(VoidCallback action) {
    _timer?.cancel(); // Cancel previous
    _timer = Timer(delay, action); // Schedule new
  }

  void cancel() {
    _timer?.cancel();
  }
}