# Changelog

## 0.2.0

- **Fix:** `KeyboardPadding`, `AnimatedKeyboardPadding` and `metricsNotifier` now update on their own on Android and iOS. Previously they stayed at 0 unless something was listening to `metricsStream`.
- Example app: switching between the keyboard and the sticker panel no longer overflows
- Real unit and widget tests, and GitHub Actions CI

## 0.1.1

- README: demo GIF, comparison with `MediaQuery.viewInsets`, and badges
- Added a pub.dev screenshot
- Example app: hide the debug banner

## 0.1.0

- Changed Android package from `com.example.smart_keyboard_insets` to `com.rishi115.smart_keyboard_insets`
- Filled in LICENSE copyright holder and year
- Added library-level documentation for `keyboard_metrics`, `keyboard_padding`, and `animated_keyboard_padding`

## 0.0.1

- Initial release
- `KeyboardMetrics` data class with keyboard height, safe area bottom, and visibility state
- `SmartKeyboardInsets` API with Stream, ValueNotifier, and one-time query support
- `KeyboardPadding` widget for automatic bottom padding
- `AnimatedKeyboardPadding` widget for smooth animated transitions
- Android support with ViewTreeObserver and WindowInsets
- iOS support with keyboard notifications and safeAreaInsets
- Example chat app demonstrating usage
