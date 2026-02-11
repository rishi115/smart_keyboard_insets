import 'package:flutter/widgets.dart';

import 'smart_keyboard_insets.dart';

/// A widget that automatically applies bottom padding based on keyboard state.
///
/// When the keyboard is visible, this widget applies bottom padding equal to
/// the keyboard height. When the keyboard is hidden, it applies bottom padding
/// equal to the safe area bottom inset.
///
/// This widget uses [ValueListenableBuilder] internally, so it only rebuilds
/// when keyboard metrics actually change.
///
/// Example usage:
/// ```dart
/// KeyboardPadding(
///   child: Column(
///     children: [
///       Expanded(child: MessageList()),
///       ComposerWidget(),
///     ],
///   ),
/// )
/// ```
class KeyboardPadding extends StatelessWidget {
  /// The child widget to apply padding to.
  final Widget child;

  /// Creates a [KeyboardPadding] widget.
  ///
  /// The [child] parameter is required and represents the widget that will
  /// receive bottom padding based on keyboard state.
  const KeyboardPadding({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<KeyboardMetrics>(
      valueListenable: SmartKeyboardInsets.instance.metricsNotifier,
      builder: (context, metrics, child) {
        final bottomPadding = metrics.isKeyboardVisible
            ? metrics.keyboardHeight
            : metrics.safeAreaBottom;
        return Padding(
          padding: EdgeInsets.only(bottom: bottomPadding),
          child: child,
        );
      },
      child: child,
    );
  }
}
