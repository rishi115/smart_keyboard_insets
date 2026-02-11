import 'package:flutter/widgets.dart';

import 'smart_keyboard_insets.dart';

/// A widget that animates bottom padding transitions based on keyboard state.
///
/// This widget is similar to [KeyboardPadding] but provides smooth animated
/// transitions when the keyboard opens or closes. Use this widget when you
/// want your UI to animate smoothly with the keyboard.
///
/// When the keyboard is visible, this widget animates bottom padding to the
/// keyboard height. When the keyboard is hidden, it animates bottom padding
/// to the safe area bottom inset.
///
/// Example usage:
/// ```dart
/// AnimatedKeyboardPadding(
///   duration: Duration(milliseconds: 300),
///   curve: Curves.easeInOut,
///   child: Column(
///     children: [
///       Expanded(child: MessageList()),
///       ComposerWidget(),
///     ],
///   ),
/// )
/// ```
class AnimatedKeyboardPadding extends StatelessWidget {
  /// The child widget to apply animated padding to.
  final Widget child;

  /// The duration of the padding animation.
  ///
  /// Defaults to 250 milliseconds.
  final Duration duration;

  /// The curve to use for the padding animation.
  ///
  /// Defaults to [Curves.easeOut].
  final Curve curve;

  /// Creates an [AnimatedKeyboardPadding] widget.
  ///
  /// The [child] parameter is required and represents the widget that will
  /// receive animated bottom padding based on keyboard state.
  ///
  /// The [duration] parameter controls how long the animation takes.
  /// Defaults to 250 milliseconds.
  ///
  /// The [curve] parameter controls the animation easing.
  /// Defaults to [Curves.easeOut].
  const AnimatedKeyboardPadding({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 250),
    this.curve = Curves.easeOut,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<KeyboardMetrics>(
      valueListenable: SmartKeyboardInsets.instance.metricsNotifier,
      builder: (context, metrics, child) {
        final bottomPadding = metrics.isKeyboardVisible
            ? metrics.keyboardHeight
            : metrics.safeAreaBottom;
        return AnimatedPadding(
          duration: duration,
          curve: curve,
          padding: EdgeInsets.only(bottom: bottomPadding),
          child: child,
        );
      },
      child: child,
    );
  }
}
