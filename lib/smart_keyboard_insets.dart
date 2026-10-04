/// Smart Keyboard Insets - A Flutter plugin for accurate keyboard height
/// and safe area detection, native on Android and iOS, with a fallback based
/// on Flutter's view metrics on web, macOS, Windows and Linux.
library smart_keyboard_insets;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'keyboard_metrics.dart';
import 'src/native_platform.dart'
    if (dart.library.js_interop) 'src/native_platform_web.dart';
import 'src/view_metrics_fallback.dart';

export 'animated_keyboard_padding.dart';
export 'keyboard_metrics.dart';
export 'keyboard_padding.dart';
export 'src/fallback_plugin.dart' show SmartKeyboardInsetsFallbackPlugin;

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
  static const MethodChannel _methodChannel = MethodChannel(
    'smart_keyboard_insets/method',
  );

  /// EventChannel for continuous keyboard metric streaming.
  static const EventChannel _eventChannel = EventChannel(
    'smart_keyboard_insets/event',
  );

  /// Singleton instance.
  static SmartKeyboardInsets? _instance;

  /// Returns the singleton instance of [SmartKeyboardInsets].
  static SmartKeyboardInsets get instance =>
      _instance ??= SmartKeyboardInsets._();

  /// Private constructor for singleton pattern.
  SmartKeyboardInsets._();

  /// Cached broadcast stream of native keyboard events (Android, iOS).
  Stream<KeyboardMetrics>? _nativeStream;

  /// Cached broadcast stream from the view-metrics fallback (other platforms).
  Stream<KeyboardMetrics>? _fallbackStream;

  final ViewMetricsFallback _fallback = ViewMetricsFallback();

  /// Internal subscription that keeps [metricsNotifier] up to date.
  StreamSubscription<KeyboardMetrics>? _notifierSubscription;

  /// Lets tests use the native method and event channels (normally only
  /// used on Android and iOS) on any platform, e.g. with mocked channels.
  @visibleForTesting
  static bool debugAutoSubscribeOnAnyPlatform = false;

  /// Whether to use the native Android/iOS implementation rather than the
  /// view-metrics fallback used on web, macOS, Windows and Linux.
  static bool get _useNativeChannels =>
      debugAutoSubscribeOnAnyPlatform || isNativePlatform;

  /// ValueNotifier for keyboard metrics, initialized with hidden state.
  final ValueNotifier<KeyboardMetrics> _metricsNotifier = ValueNotifier(
    KeyboardMetrics.hidden,
  );

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
  ///
  /// On web, macOS, Windows and Linux the metrics come from Flutter's view
  /// metrics instead: the keyboard height follows the on-screen keyboard
  /// frame by frame and is usually 0 on desktop.
  Stream<KeyboardMetrics> get metricsStream {
    if (!_useNativeChannels) {
      return _fallbackStream ??= _fallback.stream
          .map(_updateNotifier)
          .asBroadcastStream();
    }
    return _nativeStream ??= _eventChannel
        .receiveBroadcastStream()
        .map(
          (event) =>
              KeyboardMetrics.fromMap(Map<String, dynamic>.from(event as Map)),
        )
        .map(_updateNotifier)
        .asBroadcastStream();
  }

  KeyboardMetrics _updateNotifier(KeyboardMetrics metrics) {
    _metricsNotifier.value = metrics;
    return metrics;
  }

  /// ValueNotifier for keyboard metrics.
  ///
  /// Use this with [ValueListenableBuilder] for efficient widget rebuilds
  /// when keyboard metrics change.
  ///
  /// The notifier is initialized with [KeyboardMetrics.hidden]. The first
  /// access starts listening for keyboard changes on every platform, so the
  /// notifier (and [KeyboardPadding] / [AnimatedKeyboardPadding], which read
  /// it) stays up to date without subscribing to [metricsStream] yourself.
  ValueNotifier<KeyboardMetrics> get metricsNotifier {
    _ensureNotifierSubscription();
    return _metricsNotifier;
  }

  void _ensureNotifierSubscription() {
    if (_notifierSubscription != null) return;
    _notifierSubscription = metricsStream.listen(
      null,
      onError: (Object error) =>
          debugPrint('SmartKeyboardInsets: keyboard event error: $error'),
    );
  }

  /// Gets the current keyboard metrics on demand.
  ///
  /// This method queries the platform for the current keyboard state
  /// without subscribing to the stream.
  ///
  /// On web, macOS, Windows and Linux it returns the current view metrics.
  ///
  /// Returns [KeyboardMetrics.hidden] if the platform query fails.
  Future<KeyboardMetrics> getCurrentMetrics() async {
    if (!_useNativeChannels) return _fallback.read();
    try {
      final result = await _methodChannel.invokeMethod<Map<dynamic, dynamic>>(
        'getCurrentMetrics',
      );
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
