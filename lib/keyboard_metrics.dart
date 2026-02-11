/// Immutable data class representing keyboard state metrics.
///
/// This class contains information about the current keyboard state including
/// its height, the safe area bottom inset, and visibility status.
///
/// Use [KeyboardMetrics.fromMap] to create instances from platform channel data,
/// and [KeyboardMetrics.hidden] for the default state when the keyboard is not visible.
class KeyboardMetrics {
  /// The height of the keyboard in logical pixels.
  ///
  /// This value is 0.0 when the keyboard is hidden.
  final double keyboardHeight;

  /// The bottom safe area inset in logical pixels.
  ///
  /// This represents the area at the bottom of the screen that should be
  /// avoided to prevent content from being obscured by system UI elements
  /// like the navigation bar or home indicator.
  final double safeAreaBottom;

  /// Whether the keyboard is currently visible.
  final bool isKeyboardVisible;

  /// Creates a new [KeyboardMetrics] instance.
  const KeyboardMetrics({
    required this.keyboardHeight,
    required this.safeAreaBottom,
    required this.isKeyboardVisible,
  });

  /// Creates a [KeyboardMetrics] instance from a platform channel map.
  ///
  /// This factory constructor handles null values and type conversion,
  /// providing sensible defaults when data is missing.
  factory KeyboardMetrics.fromMap(Map<String, dynamic> map) {
    return KeyboardMetrics(
      keyboardHeight: (map['keyboardHeight'] as num?)?.toDouble() ?? 0.0,
      safeAreaBottom: (map['safeAreaBottom'] as num?)?.toDouble() ?? 0.0,
      isKeyboardVisible: map['isKeyboardVisible'] as bool? ?? false,
    );
  }

  /// Default metrics representing a hidden keyboard state.
  ///
  /// Use this constant when initializing state or when the keyboard
  /// is not visible.
  static const KeyboardMetrics hidden = KeyboardMetrics(
    keyboardHeight: 0.0,
    safeAreaBottom: 0.0,
    isKeyboardVisible: false,
  );

  /// Converts this instance to a map suitable for platform channel serialization.
  Map<String, dynamic> toMap() {
    return {
      'keyboardHeight': keyboardHeight,
      'safeAreaBottom': safeAreaBottom,
      'isKeyboardVisible': isKeyboardVisible,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KeyboardMetrics &&
          runtimeType == other.runtimeType &&
          keyboardHeight == other.keyboardHeight &&
          safeAreaBottom == other.safeAreaBottom &&
          isKeyboardVisible == other.isKeyboardVisible;

  @override
  int get hashCode =>
      Object.hash(keyboardHeight, safeAreaBottom, isKeyboardVisible);

  @override
  String toString() =>
      'KeyboardMetrics(keyboardHeight: $keyboardHeight, safeAreaBottom: $safeAreaBottom, isKeyboardVisible: $isKeyboardVisible)';
}
