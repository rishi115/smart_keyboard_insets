import 'dart:async';

import 'package:flutter/widgets.dart';

import '../keyboard_metrics.dart';

/// Keyboard metrics for platforms without the native implementation
/// (web, macOS, Windows, Linux), read from Flutter's own view metrics.
///
/// The keyboard height comes from the view's bottom `viewInsets`, which
/// changes every frame while an on-screen keyboard animates, and is usually
/// 0 on desktop.
class ViewMetricsFallback with WidgetsBindingObserver {
  late final StreamController<KeyboardMetrics> _controller =
      StreamController<KeyboardMetrics>.broadcast(
        onListen: _start,
        onCancel: _stop,
      );

  KeyboardMetrics? _last;

  /// Emits the current metrics on listen, then whenever they change.
  Stream<KeyboardMetrics> get stream => _controller.stream;

  /// The metrics of the app's first view right now.
  KeyboardMetrics read() {
    final views =
        WidgetsFlutterBinding.ensureInitialized().platformDispatcher.views;
    if (views.isEmpty) return KeyboardMetrics.hidden;
    final view = views.first;
    final ratio = view.devicePixelRatio;
    final keyboardHeight = view.viewInsets.bottom / ratio;
    return KeyboardMetrics(
      keyboardHeight: keyboardHeight,
      safeAreaBottom: view.viewPadding.bottom / ratio,
      isKeyboardVisible: keyboardHeight > 0,
    );
  }

  void _start() {
    WidgetsFlutterBinding.ensureInitialized().addObserver(this);
    // Deliver the current state after the listener is attached.
    scheduleMicrotask(_emit);
  }

  void _stop() {
    WidgetsBinding.instance.removeObserver(this);
    _last = null;
  }

  @override
  void didChangeMetrics() => _emit();

  void _emit() {
    if (!_controller.hasListener) return;
    final metrics = read();
    if (metrics == _last) return;
    _last = metrics;
    _controller.add(metrics);
  }
}
