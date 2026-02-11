/// Smart Keyboard Insets - A Flutter plugin for accurate keyboard height
/// and safe area detection on Android and iOS.
library smart_keyboard_insets;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'keyboard_metrics.dart';

export 'animated_keyboard_padding.dart';
export 'keyboard_metrics.dart';
export 'keyboard_padding.dart';

/// Main plugin class providing keyboard metrics APIs.
///
/// This class provides multiple ways to access keyboard metrics:
/// - [metricsStream] for reactive Stream-based updates
/// - [metricsNotifier] for ValueNotifier-based updates (use with ValueListenableBuilder)
/// - [getCurrentMetrics] for one-time queries
///
/// Example usage with Stream:
/// ```dart
/// SmartKeyboardInsets.instance.metricsStream.listen((metrics) {
///   print('Keyboard height: ${metrics.keyboardHeight}');
/// });
/// ```
///
/// Example usage with ValueNotifier:
/// ```dart
/// ValueListenableBuilder<KeyboardMetrics>(
///   valueListenable: SmartKeyboardInsets.instance.metricsNotifier,
///   builder: (context, metrics, child) {
///     return Text('Keyboard visible: ${metrics.isKeyboardVisible}');
///   },
/// )
/// ```
class SmartKeyboardInsets {
  /// MethodChannel for one-time method calls like getCurrentMetrics.
  static const MethodChannel _methodChannel =
      MethodChannel('smart_keyboard_insets/method');

  /// EventChannel for continuous keyboard metric streaming.
  static const EventChannel _eventChannel =
      EventChannel('smart_keyboard_insets/event');

  /// Singleton instance.
  static SmartKeyboardInsets? _instance;

  /// Returns the singleton instance of [SmartKeyboardInsets].
  static SmartKeyboardInsets get instance =>
      _instance ??= SmartKeyboardInsets._();

  /// Private constructor for singleton pattern.
  SmartKeyboardInsets._();

  /// Cached broadcast stream for keyboard metrics.
  Stream<KeyboardMetrics>? _metricsStream;

  /// ValueNotifier for keyboard metrics, initialized with hidden state.
  final ValueNotifier<KeyboardMetrics> _metricsNotifier =
      ValueNotifier(KeyboardMetrics.hidden);

  /// Stream of keyboard metrics updates.
  ///
  /// This stream emits [KeyboardMetrics] events whenever the keyboard state
  /// changes, including during keyboard animation.
  ///
  /// The stream is a broadcast stream, allowing multiple listeners.
  /// When a listener subscribes, platform listeners are registered.
  /// When all listeners cancel, platform listeners are removed.
  ///
  /// The stream also updates [metricsNotifier] with each new event.
  Stream<KeyboardMetrics> get metricsStream {
    _metricsStream ??= _eventChannel
        .receiveBroadcastStream()
        .map((event) => KeyboardMetrics.fromMap(Map<String, dynamic>.from(event as Map)))
        .map((metrics) {
          // Update the ValueNotifier with each new event
          _metricsNotifier.value = metrics;
          return metrics;
        })
        .asBroadcastStream();
    return _metricsStream!;
  }

  /// ValueNotifier for keyboard metrics.
  ///
  /// Use this with [ValueListenableBuilder] for efficient widget rebuilds
  /// when keyboard metrics change.
  ///
  /// The notifier is initialized with [KeyboardMetrics.hidden] and is
  /// automatically updated when [metricsStream] emits new events.
  ValueNotifier<KeyboardMetrics> get metricsNotifier => _metricsNotifier;

  /// Gets the current keyboard metrics on demand.
  ///
  /// This method queries the platform for the current keyboard state
  /// without subscribing to the stream.
  ///
  /// Returns [KeyboardMetrics.hidden] if the platform query fails.
  Future<KeyboardMetrics> getCurrentMetrics() async {
    try {
      final result =
          await _methodChannel.invokeMethod<Map<dynamic, dynamic>>('getCurrentMetrics');
      if (result != null) {
        return KeyboardMetrics.fromMap(Map<String, dynamic>.from(result));
      }
    } catch (e) {
      // Return default on error - silently handle platform exceptions
      debugPrint('SmartKeyboardInsets: Failed to get current metrics: $e');
    }
    return KeyboardMetrics.hidden;
  }
}
